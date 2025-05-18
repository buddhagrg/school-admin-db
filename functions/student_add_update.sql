DROP FUNCTION IF EXISTS student_add_update(JSONB);
CREATE OR REPLACE FUNCTION public.student_add_update(data jsonb)
RETURNS TABLE("userId" INTEGER, status boolean, message TEXT, description TEXT) 
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _operation_type VARCHAR(10);
    _reporter_id INTEGER;
    _active_academic_year_id INTEGER DEFAULT NULL;
    _user_id INTEGER;
    _name TEXT;
    _role_id INTEGER;
    _gender TEXT;
    _phone TEXT;
    _email TEXT;
    _dob DATE;
    _current_address TEXT;
    _permanent_address TEXT;
    _guardian_name TEXT;
    _guardian_phone TEXT;
    _guardian_email TEXT;
    _guardian_relationship TEXT;
    _has_system_access BOOLEAN;
    _class_id INTEGER;
    _section_id INTEGER;
    _join_date DATE;
    _roll INTEGER;
    _school_id INTEGER;
    _user_code TEXT;
    _blood_group CHAR(2);
BEGIN
    _user_id := COALESCE((data ->>'userId')::INTEGER, NULL);
    _name := COALESCE(data->>'name', NULL);
    _gender := COALESCE(data->>'gender', NULL);
    _phone := COALESCE(data->>'phone', NULL);
    _email := COALESCE(data->>'email', NULL);
    _dob := COALESCE((data->>'dob')::DATE, NULL);
    _current_address := COALESCE(data->>'currentAddress', NULL);
    _permanent_address := COALESCE(data->>'permanentAddress', NULL);
    _guardian_name := COALESCE(data->>'guardianName', NULL);
    _guardian_phone := COALESCE(data->>'guardianPhone', NULL);
    _guardian_email := COALESCE(data->>'guardianEmail', NULL);
    _guardian_relationship := COALESCE(data->>'guardianRelationship', NULL);
    _has_system_access := COALESCE((data->>'hasSystemAccess')::BOOLEAN, false);
    _class_id := COALESCE(data->>'classId', NULL);
    _section_id := COALESCE(data->>'sectionId', NULL);
    _join_date := COALESCE((data->>'admissionDate')::DATE, NULL);
    _roll := COALESCE((data->>'roll')::INTEGER, NULL);
    _school_id := COALESCE((data->>'schoolId')::INTEGER, NULL);
    _blood_group := COALESCE((data->>'bloodGroup')::CHAR(2), NULL);

    IF _user_id IS NULL THEN
        _operation_type := 'add';
    ELSE
        _operation_type := 'update';
    END IF;

    IF _school_id IS NULL THEN
        RETURN QUERY
        SELECT NULL::INTEGER, false, 'School Id may not be empty', NULL::TEXT;
    END IF;

    SELECT id
    INTO _role_id
    FROM roles
    WHERE school_id = _school_id AND static_role = 'STUDENT';

    SELECT id
    INTO _active_academic_year_id
    FROM academic_years
    WHERE is_active = TRUE AND school_id = _school_id;
    IF _active_academic_year_id IS NULL THEN
        RETURN QUERY
        SELECT NULL::INTEGER, false, 'Academic year not set up', NULL::TEXT;
    END IF;

    SELECT teacher_id
    INTO _reporter_id
    FROM class_teachers
    WHERE class_id = _class_id AND (section_id IS NULL OR section_id = _section_id);

    IF _reporter_id IS NULL THEN
        SELECT t1.id
        INTO _reporter_id
        FROM users t1
        JOIN roles t2 ON t2.id = t1.role_id
        WHERE t2.static_role = 'ADMIN' AND t2.school_id = _school_id
        ORDER BY id ASC
        LIMIT 1;
    END IF;

    IF NOT EXISTS(SELECT 1 FROM users WHERE id = _user_id) THEN
        IF EXISTS(SELECT 1 FROM users WHERE email = _email) THEN
            RETURN QUERY
            SELECT NULL::INTEGER, false, 'Email already exists', NULL::TEXT;
        END IF;

        _user_code := public.generate_unique_user_code(_school_id);

        INSERT INTO users (school_id, user_code, name, email, role_id, created_date, reporter_id, has_system_access)
        VALUES (_school_id, _user_code, _name, _email, _role_id, now(), _reporter_id, _has_system_access)
        RETURNING id INTO _user_id;

        INSERT INTO user_profiles
        (user_id, gender, phone, dob, join_date, class_id, section_id, roll, current_address, permanent_address, guardian_name, guardian_phone, guardian_email, school_id, blood_group, guardian_relationship)
        VALUES
        (_user_id, _gender, _phone, _dob, _join_date, _class_id, _section_id, _roll, _current_address, _permanent_address, _guardian_name, _guardian_phone, _guardian_email, _school_id, _blood_group, _guardian_relationship);

        INSERT INTO student_academic_record(school_id, student_id, academic_year_id, class_id, section_id, roll_number)
        VALUES(_school_id, _user_id, _active_academic_year_id, _class_id, _section_id, _roll);

        RETURN QUERY
        SELECT _user_id, true, 'Student added successfully', NULL;
    END IF;

    --update user tables
    UPDATE users
    SET
        name = _name,
        email = _email,
        role_id = _role_id,
        has_system_access = _has_system_access,
        updated_date = now()
    WHERE id = _user_id AND school_id = _school_id;

    UPDATE user_profiles
    SET
        gender = _gender,
        phone = _phone,
        dob = _dob,
        join_date = _join_date,
        class_id = _class_id,
        section_id  =_section_id,
        roll = _roll,
        current_address = _current_address,
        permanent_address = _permanent_address, 
        guardian_name = _guardian_name,
        guardian_phone = _guardian_phone,
        guardian_email = _guardian_email,
        guardian_relationship= _guardian_relationship,
        blood_group = _blood_group
    WHERE user_id = _user_id AND school_id = _school_id;

    RETURN QUERY
    SELECT _user_id, true , 'Student updated successfully', NULL;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT NULL::INTEGER, false, 'Unable to ' || _operation_type || ' student', SQLERRM;
END;
$BODY$;
