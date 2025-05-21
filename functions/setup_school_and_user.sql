DROP FUNCTION IF EXISTS public.setup_school_and_user(INTEGER, VARCHAR);
CREATE OR REPLACE FUNCTION setup_school_and_user(_demo_id INTEGER, _hashed_password VARCHAR)
RETURNS TABLE(status boolean, message TEXT, description TEXT)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _user_id INTEGER;
    _user_email VARCHAR;
    _school_name VARCHAR;
    _user_name VARCHAR;
    _role_id INTEGER;
    _school_id INTEGER;
    _user_code TEXT;
BEGIN
    PERFORM public.generate_school_ids(true);

    UPDATE school_ids
    SET state = 'RESERVED'
    WHERE school_id = (
        SELECT school_id FROM school_ids WHERE state = 'FREE' LIMIT 1
    )
    RETURNING school_id INTO _school_id;

    IF _school_id IS NULL THEN
        RETURN QUERY
        SELECT false, 'Could not find unique school id', NULL::TEXT;
        RETURN;
    END IF;

    IF NOT EXISTS(SELECT id FROM demo_requests) THEN
        RETURN QUERY
        SELECT false, 'Demo ID not found', NULL::TEXT;
        RETURN;
    END IF;

    SELECT email, school_name, contact_person
    INTO _user_email, _school_name, _user_name
    FROM demo_requests
    WHERE id = _demo_id;

    IF _user_email IS NULL OR _school_name IS NULL OR _user_name IS NULL THEN
        RETURN QUERY
        SELECT false, 'Missing required information: school name and user name/email', NULL::TEXT;
        RETURN;
    END IF;

    INSERT INTO schools(school_id, name, email, school_code, is_active)
    VALUES(_school_id, _school_name, _user_email, (SELECT LEFT(UPPER(_school_name), 4)), true);

    WITH inserted_users AS(
        INSERT INTO roles(name, static_role, is_editable, school_id)
        SELECT name, role, false, _school_id
        FROM static_school_user_roles
        RETURNING *  
    )
    SELECT id INTO _role_id
    FROM inserted_users
    WHERE static_role = 'ADMIN';

    _user_code := public.generate_unique_user_code(_school_id);

    INSERT INTO users(school_id, user_code, name, email, role_id, password, is_email_verified, has_system_access)
    VALUES(_school_id, _user_code, _user_name, _user_email, _role_id, _hashed_password, true, true)
    RETURNING id INTO _user_id;

    UPDATE schools
    SET admin_id = _user_id
    WHERE school_id = _school_id;

    UPDATE demo_requests
    SET demo_requests_status_code = 'ACCOUNT_ACTIVE'
    WHERE id = _demo_id AND demo_requests_status_code = 'PWD_SETUP_INVITE_SENT';

    DELETE FROM school_ids
    WHERE school_id = _school_id;

    RETURN QUERY
    SELECT true, 'Password setup successful. Please log in to continue.', NULL::TEXT;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT false, 'Unable to setup password', SQLERRM::TEXT;
END
$BODY$;