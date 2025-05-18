DROP FUNCTION IF EXISTS public.pay_invoice;
CREATE OR REPLACE FUNCTION pay_invoice(payload JSONB)
RETURNS TABLE (status boolean, message TEXT, description TEXT)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _school_id INTEGER;
    _invoice_id INTEGER;
    _payment_amount NUMERIC(10, 2) DEFAULT 0;
    _invoice_status VARCHAR(15);
    _invoice_outstanding_amount NUMERIC(10, 2);
    _credit_amount NUMERIC(10, 2);
    _final_outstanding_amount NUMERIC(10, 2);
    _final_invoice_status VARCHAR(15);
    _invoice_user_id INTEGER;
    _initiator INTEGER;
    _payment_method INTEGER;
    _active_fiscal_year_id INTEGER;
    _active_academic_year_id INTEGER;
BEGIN
    _school_id := (payload->>'schoolId');
    _invoice_id := (payload->>'invoiceId');
    _payment_amount := (payload->>'paymentAmount')::NUMERIC(10, 2);
    _initiator := (payload->>'initiator');
    _payment_method := (payload->>'paymentMethod');

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
    END IF;

    IF NOT EXISTS(
        SELECT 1
        FROM invoices
        WHERE school_id = _school_id AND id = _invoice_id
    ) THEN
        RETURN QUERY
        SELECT false, 'Invoice does not exist', NULL::TEXT;
    END IF;

    SELECT COALESCE(outstanding_amt, 0), user_id, status
    INTO _invoice_outstanding_amount, _invoice_user_id, _invoice_status
    FROM invoices
    WHERE id = _invoice_id;

    IF _invoice_status IS NULL OR _invoice_status NOT IN ('ISSUED', 'PARTIALLY_PAID') THEN
        RETURN QUERY
        SELECT
            false,
            'Payment Denied.  Invoice status should be either ''ISSUED'' or ''PARTIALLY_PAID'', but it is: %' || _invoice_status,
            NULL::TEXT;
    END IF;

    IF _payment_amount > _invoice_outstanding_amount THEN
        _final_outstanding_amount := 0;
        _final_invoice_status := 'PAID';
        _credit_amount := _payment_amount - _invoice_outstanding_amount;
    ELSIF _payment_amount = _invoice_outstanding_amount THEN
        _final_outstanding_amount := 0;
        _final_invoice_status := 'PAID';
        _credit_amount := 0;
    ELSE
        _final_outstanding_amount := _invoice_outstanding_amount - _payment_amount;
        _final_invoice_status := 'PARTIALLY_PAID';
        _credit_amount := 0;
    END IF;

    UPDATE invoices
    SET
        paid_amt = COALESCE(paid_amt, 0) + _payment_amount,
        outstanding_amt = _final_outstanding_amount,
        status = _final_invoice_status
    WHERE id = _invoice_id;

    INSERT INTO transactions(school_id, academic_year_id, fiscal_year_id, user_id, initiator, type, status, invoice_id, amount, payment_method)
    VALUES(_school_id, _active_academic_year_id, _active_fiscal_year_id, _invoice_user_id, _initiator, 'CREDIT', 'SUCCESS', _invoice_id, _payment_amount, _payment_method);

    IF _credit_amount > 0 THEN
        INSERT INTO credits(school_id, user_id, amount)
        VALUES(_school_id, _invoice_user_id, _credit_amount)
        ON CONFLICT(school_id, user_id)
        DO UPDATE SET
            amount = COALESCE(credits.amount, 0) + EXCLUDED.amount,
            updated_date = NOW();
    END IF;

    RETURN QUERY
    SELECT true, 'Invoice paid successfully', NULL::TEXT;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT false, 'Unable to pay invoice', SQLERRM;
END
$BODY$;