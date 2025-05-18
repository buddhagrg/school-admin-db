
DROP FUNCTION IF EXISTS public.generate_school_ids(BOOLEAN);
CREATE OR REPLACE FUNCTION generate_school_ids(_execute_fn BOOLEAN)
RETURNS void
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    i INT;
BEGIN
    IF _execute_fn THEN
        FOR i IN 1..5 LOOP
            INSERT INTO school_ids(school_id, state)
            SELECT FLOOR(100000 + RANDOM() * 900000)::INT, 'FREE'
            ON CONFLICT(school_id) DO NOTHING;
        END LOOP;
    END IF;
END
$BODY$;