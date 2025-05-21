DROP FUNCTION IF EXISTS public.delete_period_order;
CREATE OR REPLACE FUNCTION delete_period_order(payload jsonb)
RETURNS TABLE (status boolean, message TEXT, description TEXT)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _school_id INTEGER;
    _academic_period_id INTEGER;
    _deleted_order_id INTEGER;
    _academic_level_id INTEGER;
BEGIN
    _school_id := (payload->>'schoolId');
    _academic_period_id := (payload->>'academicPeriodId');
    _academic_level_id := (payload->>'academicLevelId');

    IF NOT EXISTS(
        SELECT 1
        FROM academic_periods
        WHERE school_id = _school_id
            AND id = _academic_period_id
            AND academic_level_id = _academic_level_id
    ) THEN
        RETURN QUERY
        SELECT false, 'Period does not exist', NULL::TEXT;
        RETURN;
    END IF;

    DELETE FROM academic_periods
    WHERE school_id = _school_id
        AND id = _academic_period_id
        AND academic_level_id = _academic_level_id
    RETURNING sort_order INTO _deleted_order_id;

    IF NOT EXISTS(
        SELECT 1
        FROM academic_periods
        WHERE school_id = _school_id
            AND academic_level_id = _academic_level_id
            AND sort_order > _deleted_order_id
    ) THEN
        RETURN QUERY
        SELECT true, 'Period deleted successfully', NULL::TEXT;
        RETURN;
    END IF;


    UPDATE academic_periods
    SET sort_order = -sort_order
    WHERE school_id = _school_id
        AND academic_level_id = _academic_level_id
        AND sort_order > _deleted_order_id;    

    UPDATE academic_periods
    SET sort_order = ABS(sort_order) - 1
    WHERE school_id = _school_id
        AND academic_level_id = _academic_level_id
        AND sort_order < 0;
    
    RETURN QUERY
    SELECT true, 'Period deleted successfully', NULL::TEXT;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT false, 'Unable to delete period', SQLERRM::TEXT;
END
$BODY$;