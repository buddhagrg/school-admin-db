DROP FUNCTION IF EXISTS public.assign_student_fees;
CREATE OR REPLACE FUNCTION assign_student_fees(payload JSONB)
RETURNS TABLE(status boolean, message TEXT, description TEXT)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _fee_details JSONB;
    _item JSONB;
    _school_id INTEGER;
    _initiator INTEGER;
    _student_id INTEGER;
    _active_academic_year_id INTEGER;
    _active_fiscal_year_id INTEGER;
BEGIN
    _school_id := (payload->>'schoolId');
    _initiator := (payload->>'initiator');
    _student_id := (payload->>'studentId');
    _fee_details := (payload->>'feeDetails');

    SELECT id
    INTO _active_academic_year_id
    FROM academic_years
    WHERE school_id = _school_id AND is_active = TRUE;

    SELECT id
    INTO _active_fiscal_year_id
    FROM fiscal_years
    WHERE school_id = _school_id AND is_active = TRUE;

    IF _active_academic_year_id IS NULL OR _active_fiscal_year_id IS NULL THEN
        RETURN QUERY
        SELECT false, 'Denied. Either Fiscal year or Academic year is not setup properly.', NULL::TEXT;
    END IF;

    FOR _item IN (SELECT * FROM _fee_details)
    LOOP
        INSERT INTO student_fees(
            school_id,
            academic_year_id,
            fiscal_year_id,
            student_id,
            initiator,
            academic_period_id,
            fee_structure_id,
            due_date,
            amount,
            discount_value,
            discount_type,
            outstanding_amt
        ) VALUES(
            _school_id,
            _active_academic_year_id,
            _active_fiscal_year_id,
            _student_id,
            _initiator,
            _item->>'academicPeriodId',
            _item->>'feeStructureId',
            _item->>'dueDate',
            _item->>'amount',
            _item->>'discountValue',
            _item->>'discountType',
            CASE
                WHEN (_item->>'discountType') = 'P' THEN
                (_item->>'amount') - ((COALESCE((_item->>'discountValue'),0) / 100) * (_item->>'amount'))
            ELSE
                (_item->>'amount') - COALESCE((_item->>'discountValue'),0)
            END
        )
        ON CONFLICT(school_id, academic_year_id, fiscal_year_id, student_id, fee_structure_id)
        DO UPDATE SET
            initiator = EXCLUDED.initiator,
            due_date = EXCLUDED.due_date,
            amount = EXCLUDED.amount,
            discount_value = EXCLUDED.discount_value,
            discount_type = EXCLUDED.discount_type,
            outstanding_amt = EXCLUDED.outstanding_amt,
            academic_period_id = EXCLUDED.academic_period_id;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT false, 'Unable to assign fees to student', SQLERRM::TEXT;
END
$BODY$;