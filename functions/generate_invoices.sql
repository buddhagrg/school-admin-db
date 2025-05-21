DROP FUNCTION IF EXISTS public.generate_invoices;
CREATE OR REPLACE FUNCTION generate_invoices(payload JSONB)
RETURNS TABLE(status boolean, message TEXT, description TEXT)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _school_id INTEGER;
    _initiator INT;
    _invoices JSONB;
    _invoice_user_id INTEGER;
    _items JSONB;
    _new_invoice_number JSONB;
    _new_invoice_id INTEGER;
    _invoice_amount NUMERIC(10, 2) DEFAULT 0;
    _invoice_outstanding_amount NUMERIC(10, 2) DEFAULT 0;
    _invoice_discount NUMERIC(10, 2) DEFAULT 0;
    _invoice_item_fee_structure_id INTEGER;
    _invoice_item_fee_amount NUMERIC(10, 2) DEFAULT 0;
    _invoice_item_discount_amount NUMERIC(10, 2) DEFAULT 0;
    _invoice JSONB;
    _item JSONB;
    _active_academic_year_id INTEGER;
    _active_fiscal_year_id INTEGER;
    _academic_period_id INTEGER;
    _max_period_id INTEGER;
    _max_period_invoice_status VARCHAR(15);
BEGIN
    _school_id := (payload->>'schoolId')::INT;
    _invoices := (payload->>'action')::JSONB;
    _initiator := (payload->>'initiator')::JSONB;
    _academic_period_id := (payload->>'academicPeriodId')::JSONB;

    SELECT id
    INTO _active_fiscal_year_id
    FROM fiscal_years
    WHERE school_id = _school_id AND is_active = true;

    SELECT id
    INTO _active_academic_year_id
    FROM academic_years
    WHERE school_id = _school_id AND is_active = true;

    IF _active_fiscal_year_id IS NULL OR _active_academic_year_id IS NULL THEN
        RETURN QUERY
        SELECT false, 'Denied. Either Fiscal year or Academic year is not setup properly.', NULL::TEXT;
        RETURN;
    END IF;

    FOR _invoice IN (SELECT * FROM _invoices)
    LOOP
        _invoice_user_id := _invoice->>'userId';
        _items := _invoice->>'items';

        -- validate user existence
        IF NOT EXISTS(
            SELECT 1
            FROM users
            WHERE id = _invoice_user_id AND school_id = _school_id
        ) THEN
            RAISE NOTICE 'Invalid user_id (%) for invoice', _invoice_user_id;
            CONTINUE;
        END IF;

        SELECT COALESCE(academic_period_id, 0), status
        INTO _max_period_id, _max_period_invoice_status
        FROM invoices
        WHERE school_id = _school_id
            AND user_id = _invoice_user_id
            AND academic_year_id = _active_academic_year_id
        ORDER BY academic_period_id DESC
        LIMIT 1;

        IF (_academic_period_id < _max_period_id) OR
            (_academic_period_id = _max_period_id AND _max_period_invoice_status != 'CANCELLED')
        THEN
            RAISE NOTICE 'Denied. Invoice already generated for given period.';
            CONTINUE;
        END IF;

        IF _max_period_id - _academic_period_id != 1 THEN
            RAISE NOTICE 'Denied. Invoice generation period gap can not be more than one.';
            CONTINUE;
        END IF;

        -- insert invoice and get new invoice id
        INSERT INTO invoices(
            school_id,
            academic_year_id,
            fiscal_year_id,
            academic_period_id,
            initiator,
            description,
            user_id,
            due_date,
            status
        ) VALUES(
            _school_id,
            _active_academic_year_id,
            _active_fiscal_year_id,
            _academic_period_id,
            _initiator,
            _invoice->>'description',
            _invoice_user_id,
            _invoice->>'dueDate',
            'ISSUED'
        ) RETURNING id INTO _new_invoice_id;

        -- insert invoice items
        FOR _item IN (SELECT * FROM _items)
        LOOP
            SELECT fee_structure_id, amount, discounted_amt
            INTO _invoice_item_fee_structure_id, _invoice_item_fee_amount, _invoice_discount
            FROM student_fees
            WHERE id = (_item->>'studentFeeId');

            INSERT INTO invoice_items(
                school_id ,
                invoice_id,
                fee_structure_id,
                student_fee_id,
                description,
                amount,
                quantity,
                total_amount,
                total_discount
            ) VALUES(
                _school_id,
                _new_invoice_id,
                _invoice_item_fee_structure_id,
                _item->>'studentFeeId',
                _item->>'description',
                _invoice_item_fee_amount,
                _item->>'quantity',
                (_item->>'quantity') * _invoice_item_fee_amount - _invoice_item_discount_amount,
                _invoice_item_discount_amount * (_item->>'quantity')::INTEGER
            );
        END LOOP;

        -- generate invoice number
        _new_invoice_number := CONCAT(
            'INV-',
            TO_CHAR(CURRENT_DATE, 'YYYYMM'),
            '-', _new_invoice_id,
            '-', _school_id
        );

        SELECT COALESCE(SUM(total_amount), 0)
        INTO _invoice_amount
        FROM invoice_items
        WHERE invoice_id = _new_invoice_id;

        SELECT COALESCE(SUM(total_discount), 0)
        INTO _invoice_discount
        FROM invoice_items
        WHERE invoice_id = _new_invoice_id;

        _invoice_outstanding_amount := _invoice_amount - _invoice_discount;

        -- update invoice number and amount
        UPDATE invoices SET
            invoice_number = _new_invoice_number,
            amount = _invoice_outstanding_amount,
            outstanding_amt = _invoice_outstanding_amount
        WHERE id = _new_invoice_id;
    END LOOP;

    RETURN QUERY
    SELECT true, 'Invoice generated successfully', NULL::TEXT;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT false, 'Unable to generate invoice', SQLERRM;
END
$BODY$;