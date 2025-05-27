DROP FUNCTION IF EXISTS staff_add_update(JSONB);
CREATE OR REPLACE FUNCTION public.staff_add_update(data jsonb)
RETURNS TABLE("userId" INTEGER, status boolean, message TEXT, description TEXT) 
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _operation_type VARCHAR(10);
    _user_id INTEGER DEFAULT NULL::INT;
    _name TEXT;
    _role_id INTEGER;
    _static_role VARCHAR;
    _gender TEXT;
    _marital_status TEXT;
    _phone TEXT;
    _email TEXT;
    _dob DATE;
    _join_date DATE;
    _qualification TEXT;
    _experience TEXT;
    _current_address TEXT;
    _permanent_address TEXT;
    _guardian_name TEXT;
    _guardian_email TEXT;
    _guardian_phone TEXT;
    _guardian_relationship TEXT;
    _has_system_access BOOLEAN;
    _reporter_id INTEGER;
    _school_id INTEGER;
    _user_code TEXT;
    _blood_group CHAR(2);
    _department_id INT;
BEGIN
    _user_id := COALESCE((data ->>'userId')::INTEGER, NULL);
    _operation_type := CASE WHEN _user_id IS NULL THEN 'add' ELSE 'update' END;
    _name := COALESCE(data->>'name', NULL);
    _role_id := COALESCE((data->>'roleId')::INTEGER, NULL);
    _gender := COALESCE(data->>'gender', NULL);
    _marital_status := COALESCE(data->>'maritalStatus', NULL);
    _phone := COALESCE(data->>'phone', NULL);
    _email := COALESCE(data->>'email', NULL);
    _dob := COALESCE((data->>'dob')::DATE, NULL);
    _join_date := COALESCE((data->>'joinDate')::DATE, NULL);
    _qualification := COALESCE(data->>'qualification', NULL);
    _experience := COALESCE(data->>'experience', NULL);
    _current_address := COALESCE(data->>'currentAddress', NULL);
    _permanent_address := COALESCE(data->>'permanentAddress', NULL);
    _guardian_name := COALESCE(data->>'guardianName', NULL);
    _guardian_email := COALESCE(data->>'guardianEmail', NULL);
    _guardian_phone := COALESCE(data->>'guardianPhone', NULL);
    _guardian_relationship := COALESCE(data->>'guardianRelationship', NULL);
    _has_system_access := COALESCE((data->>'hasSystemAccess')::BOOLEAN, false);
    _reporter_id := NULLIF((data->>'reporterId'), '');
    _school_id := COALESCE((data->>'schoolId')::INTEGER, NULL);
    _blood_group := COALESCE((data->>'bloodGroup')::CHAR(2), NULL);
    _department_id := COALESCE((data->>'departmentId')::INT, NULL);

    IF _school_id IS NULL THEN
        RETURN QUERY
        SELECT NULL::INTEGER, false, 'School Id may not be empty', NULL::TEXT;
        RETURN;
    END IF;

    IF _role_id IS NULL THEN
        RETURN QUERY
        SELECT NULL::INTEGER, false, 'Role may not be empty', NULL::TEXT;
        RETURN;
    END IF;

    SELECT static_role
    INTO _static_role
    FROM roles
    WHERE id = _role_id And school_id = _school_id;
    
    IF _static_role = 'STUDENT' THEN
        RETURN QUERY
        SELECT NULL::INTEGER, false, 'Student cannot be staff', NULL::TEXT;
        RETURN;
    END IF;

    IF NOT EXISTS(SELECT 1 FROM users WHERE id = _user_id) THEN

        IF EXISTS(SELECT 1 FROM users WHERE email = _email) THEN
            RETURN QUERY
            SELECT NULL::INTEGER, false, 'Email already exists', NULL::TEXT;
            RETURN;
        END IF;

        _user_code := public.generate_unique_user_code(_school_id);

        INSERT INTO users (user_code, name, email, role_id, created_date, reporter_id, school_id, has_system_access)
        VALUES (_user_code, _name, _email, _role_id, now(), _reporter_id, _school_id, _has_system_access)
        RETURNING id INTO _user_id;

        INSERT INTO user_profiles
        (user_id, gender, marital_status, phone, dob, join_date, qualification, experience, current_address, permanent_address, guardian_name, guardian_email, guardian_phone, school_id, blood_group, guardian_relationship, department_id)
        VALUES
        (_user_id, _gender, _marital_status, _phone, _dob, _join_date, _qualification, _experience, _current_address, _permanent_address, _guardian_name, _guardian_email, _guardian_phone, _school_id, _blood_group, _guardian_relationship, _department_id);

        RETURN QUERY
        SELECT _user_id, true, 'Staff added successfully', NULL;
        RETURN;
    END IF;


    --update user tables
    UPDATE users
    SET
        name = _name,
        email = _email,
        role_id = _role_id,
        has_system_access = _has_system_access,
        reporter_id = _reporter_id,
        updated_date = now()
    WHERE id = _user_id AND school_id = _school_id;

    UPDATE user_profiles
    SET
        gender = _gender,
        marital_status = _marital_status,
        phone = _phone,
        dob = _dob,
        join_date = _join_date,
        qualification = _qualification,
        experience = _experience,
        current_address = _current_address,
        permanent_address = _permanent_address, 
        guardian_name = _guardian_name,
        guardian_email = _guardian_email,
        guardian_phone = _guardian_phone,
        guardian_relationship = _guardian_relationship,
        blood_group = _blood_group,
        department_id = _department_id
    WHERE user_id = _user_id AND school_id = _school_id;

    RETURN QUERY
    SELECT _user_id, true, 'Staff updated successfully', NULL;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT _user_id::INTEGER, false, 'Unable to ' || _operation_type || ' staff', SQLERRM;
END;
$BODY$;
