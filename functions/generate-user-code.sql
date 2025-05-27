DROP FUNCTION IF EXISTS generate_unique_user_code(int);
CREATE OR REPLACE FUNCTION generate_unique_user_code(_school_id INT)
RETURNS TEXT
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _new_user_code TEXT;
    _try_count INT := 0;
    _school_code VARCHAR;
BEGIN
    SELECT school_code INTO _school_code
    FROM schools WHERE school_id = _school_id;

    FOR i IN 1..5 LOOP
        _new_user_code := _school_code || '-' || TO_CHAR(NOW(), 'YYYY') || '-' ||
                            LPAD(FLOOR(RANDOM()*10000)::TEXT, 4, '0');
        
        PERFORM 1 FROM users WHERE user_code = _new_user_code;
        IF NOT FOUND THEN
            RETURN _new_user_code;
        END IF;
    END LOOP;

    RAISE EXCEPTION 'Could not generate unique user code after 5 attempts';
END;
$BODY$;