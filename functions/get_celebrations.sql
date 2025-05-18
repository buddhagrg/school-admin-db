DROP FUNCTION IF EXISTS public.get_celebrations(int);

CREATE OR REPLACE FUNCTION public.get_celebrations(_school_id INT)
RETURNS TABLE(type CHAR(1), "user" VARCHAR(100), event TEXT, "eventDate" DATE)
LANGUAGE plpgsql
AS $BODY$
BEGIN
    RETURN QUERY
        WITH _month_dates AS (
            SELECT 
            DATE_TRUNC('month', NOW())::DATE AS month_start_date,
            (DATE_TRUNC('month', NOW()) + INTERVAL '1 month' - INTERVAL '1 microsecond')::DATE AS month_end_date
        ),
        _celebrations AS (
            SELECT
                'B'::CHAR(1),
                t1.name,
                'Birthday',
                t2.dob
            FROM users t1
            JOIN user_profiles t2 ON t1.id = t2.user_id
            CROSS JOIN _month_dates t3
            WHERE t2.dob IS NOT NULL
                AND t1.school_id = _school_id
                AND (
                    t2.dob + (EXTRACT(YEAR FROM age(now(), t2.dob)) + 1) * INTERVAL '1 year'
                    BETWEEN t3.month_start_date AND t3.month_end_date
                )

            UNION ALL

            SELECT
                'A'::CHAR(1),
                t1.name,
                CASE WHEN (EXTRACT(YEAR FROM age(now(), t2.join_date)) + 1) = 1 THEN
                    '1 Year Anniversary'
                ELSE (EXTRACT(YEAR FROM age(now(), t2.join_date)) + 1) || ' Years Anniversary'
                END,
                (COALESCE(t2.join_date, now())::DATE + INTERVAL '1 year')::DATE
            FROM users t1
            JOIN user_profiles t2 ON t1.id = t2.user_id
            JOIN roles t3 ON t3.id = t1.role_id
            CROSS JOIN _month_dates t4
            WHERE t1.school_id = _school_id
                AND t2.join_date IS NOT NULL 
                AND (
                    (t2.join_date + (EXTRACT(YEAR FROM age(now(), t2.join_date)) + 1 ) * INTERVAL '1 year')
                    BETWEEN t4.month_start_date AND t4.month_end_date
                )
        )
        SELECT * FROM _celebrations LIMIT 5;
END
$BODY$;