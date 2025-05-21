DROP FUNCTION IF EXISTS public.refund_invoice;
CREATE OR REPLACE FUNCTION refund_invoice(payload JSONB)
RETURNS TABLE (status boolean, message TEXT, description TEXT)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _school_id INTEGER;
    _refund_amount NUMERIC(10, 2);
    _invoice_id INTEGER;
    _invoice_status VARCHAR(15);
    _invoice_paid_amount NUMERIC(10, 2);
    _invoice_user_id INTEGER;
    _initiator INTEGER;
    _refund_method INTEGER;
BEGIN
    _school_id := (payload->>'schoolId');
    _refund_amount := COALESCE((payload->>'refundAmt')::NUMERIC(10, 2), 0);
    _invoice_id := (payload->>'invoiceId');
    _initiator := (payload->>'initiator');
    _refund_method := (payload->>'refundMethod');

    IF NOT EXISTS(
        SELECT 1
        FROM invoices
        WHERE school_id = _school_id AND id = _invoice_id
    ) THEN
        RETURN QUERY
        SELECT false, 'Invoice does not exist', NULL:: TEXT;
        RETURN;
    END IF;

    SELECT status, COALESCE(paid_amt, 0), user_id
    INTO _invoice_status, _invoice_paid_amount, _invoice_user_id
    FROM invoices
    WHERE school_id = _school_id AND id = _invoice_id;

    IF _invoice_status != 'PAID' OR _refund_amount IS NULL THEN
        RETURN QUERY
        SELECT
            false,
            'Refund denied. Invoice must be ''PAID'' for refund process',
            NULL:: TEXT;
        RETURN;
    END IF;

    IF _refund_amount > _invoice_paid_amount THEN
        RETURN QUERY
        SELECT
            false,
            'Refund denied. Refund amount can not be greater than paid invoice paid amount.',
            NULL::TEXT;
        RETURN;
    END IF;

    UPDATE invoices
    SET
        refunded_amt = COALESCE(refunded_amt, 0) + _refund_amount,
        status = 'REFUNDED',
        updated_date  = NOW()
    WHERE school_id = _school_id AND id = _invoice_id;

    RETURN QUERY
    SELECT true, 'Refund success', NULL::TEXT;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT false, 'Unable to refund the invoice', SQLERRM;
END
$BODY$;