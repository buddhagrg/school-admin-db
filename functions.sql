-- staff add/update
DROP FUNCTION IF EXISTS staff_add_update(JSONB);
CREATE OR REPLACE FUNCTION public.staff_add_update(data jsonb)
RETURNS TABLE("userId" INTEGER, status boolean, message TEXT, description TEXT) 
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _operation_type VARCHAR(10);
    _user_id INTEGER;
    _name TEXT;
    _role_id INTEGER;
    _static_role_id INTEGER;
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
    _father_name TEXT;
    _mother_name TEXT;
    _emergency_phone TEXT;
    _has_system_access BOOLEAN;
    _reporter_id INTEGER;
    _school_id INTEGER;
BEGIN
    _user_id := COALESCE((data ->>'userId')::INTEGER, NULL);
    _name := COALESCE(data->>'name', NULL);
    _role_id := COALESCE((data->>'role')::INTEGER, NULL);
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
    _father_name := COALESCE(data->>'fatherName', NULL);
    _mother_name := COALESCE(data->>'motherName', NULL);
    _emergency_phone := COALESCE(data->>'emergencyPhone', NULL);
    _has_system_access := COALESCE((data->>'hasSystemAccess')::BOOLEAN, false);
    _reporter_id := COALESCE((data->>'reporterId')::INTEGER, NULL);
    _school_id := COALESCE((data->>'schoolId')::INTEGER, NULL);

    IF _user_id IS NULL THEN
        _operation_type := 'add';
    ELSE
        _operation_type := 'update';
    END IF;

    IF _school_id IS NULL THEN
        RETURN QUERY
        SELECT NULL::INTEGER, false, 'School Id may not be empty', NULL::TEXT;
    END IF;

    IF _role_id IS NULL THEN
        RETURN QUERY
        SELECT NULL::INTEGER, false, 'Role may not be empty', NULL::TEXT;
    END IF;

    SELECT static_role_id INTO _static_role_id FROM roles WHERE id = _role_id And school_id = _school_id;
    
    IF _static_role_id = 4 THEN
        RETURN QUERY
        SELECT NULL::INTEGER, false, 'Student cannot be staff', NULL::TEXT;
    END IF;

    IF NOT EXISTS(SELECT 1 FROM users WHERE id = _user_id) THEN

        IF EXISTS(SELECT 1 FROM users WHERE email = _email) THEN
            RETURN QUERY
            SELECT NULL::INTEGER, false, 'Email already exists', NULL::TEXT;
        END IF;

        INSERT INTO users (name, email, role_id, created_date, reporter_id, school_id, has_system_access)
        VALUES (_name, _email, _role_id, now(), _reporter_id, _school_id, _has_system_access) RETURNING id INTO _user_id;

        INSERT INTO user_profiles
        (user_id, gender, marital_status, phone, dob, join_date, qualification, experience, current_address, permanent_address, father_name, mother_name, emergency_phone, school_id)
        VALUES
        (_user_id, _gender, _marital_status, _phone, _dob, _join_date, _qualification, _experience, _current_address, _permanent_address, _father_name, _mother_name, _emergency_phone, _school_id);

        RETURN QUERY
        SELECT _user_id, true, 'Staff added successfully', NULL;
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
        father_name = _father_name,
        mother_name = _mother_name,
        emergency_phone = _emergency_phone
    WHERE user_id = _user_id AND school_id = _school_id;

    RETURN QUERY
    SELECT _user_id, true, 'Staff updated successfully', NULL;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT _user_id::INTEGER, false, 'Unable to ' || _operation_type || ' staff', SQLERRM;
END;
$BODY$;


--student add/update
DROP FUNCTION IF EXISTS student_add_update(JSONB);
CREATE OR REPLACE FUNCTION public.student_add_update(data jsonb)
RETURNS TABLE("userId" INTEGER, status boolean, message TEXT, description TEXT) 
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _operation_type VARCHAR(10);
    _reporter_id INTEGER;

    _user_id INTEGER;
    _name TEXT;
    _role_id INTEGER;
    _gender TEXT;
    _phone TEXT;
    _email TEXT;
    _dob DATE;
    _current_address TEXT;
    _permanent_address TEXT;
    _father_name TEXT;
    _father_phone TEXT;
    _mother_name TEXT;
    _mother_phone TEXT;
    _guardian_name TEXT;
    _guardian_phone TEXT;
    _relation_of_guardian TEXT;
    _has_system_access BOOLEAN;
    _class_id INTEGER;
    _section_id INTEGER;
    _admission_date DATE;
    _roll INTEGER;
    _school_id INTEGER;
BEGIN
    _user_id := COALESCE((data ->>'userId')::INTEGER, NULL);
    _name := COALESCE(data->>'name', NULL);
    _gender := COALESCE(data->>'gender', NULL);
    _phone := COALESCE(data->>'phone', NULL);
    _email := COALESCE(data->>'email', NULL);
    _dob := COALESCE((data->>'dob')::DATE, NULL);
    _current_address := COALESCE(data->>'currentAddress', NULL);
    _permanent_address := COALESCE(data->>'permanentAddress', NULL);
    _father_name := COALESCE(data->>'fatherName', NULL);
    _father_phone := COALESCE(data->>'fatherPhone', NULL);
    _mother_name := COALESCE(data->>'motherName', NULL);
    _mother_phone := COALESCE(data->>'motherPhone', NULL);
    _guardian_name := COALESCE(data->>'guardianName', NULL);
    _guardian_phone := COALESCE(data->>'guardianPhone', NULL);
    _relation_of_guardian := COALESCE(data->>'relationOfGuardian', NULL);
    _has_system_access := COALESCE((data->>'hasSystemAccess')::BOOLEAN, false);
    _class_id := COALESCE(data->>'class', NULL);
    _section_id := COALESCE(data->>'section', NULL);
    _admission_date := COALESCE((data->>'admissionDate')::DATE, NULL);
    _roll := COALESCE((data->>'roll')::INTEGER, NULL);
    _school_id := COALESCE((data->>'schoolId')::INTEGER, NULL);

    IF _user_id IS NULL THEN
        _operation_type := 'add';
    ELSE
        _operation_type := 'update';
    END IF;

    IF _school_id IS NULL THEN
        RETURN QUERY
        SELECT NULL::INTEGER, false, 'School Id may not be empty', NULL::TEXT;
    END IF;

    SELECT id INTO _role_id
    FROM roles
    WHERE school_id = _school_id
        AND static_role_id = 4;

    SELECT teacher_id
    INTO _reporter_id
    FROM class_teachers
    WHERE class_id = _class_id
        AND (section_id IS NULL OR section_id = _section_id);

    IF _reporter_id IS NULL THEN
        SELECT t1.id
        INTO _reporter_id
        FROM users t1
        JOIN roles t2 ON t2.id = t1.role_id
        WHERE t2.static_role_id = 2 AND t2.school_id = _school_id
        ORDER BY id ASC
        LIMIT 1;
    END IF;

    IF NOT EXISTS(SELECT 1 FROM users WHERE id = _user_id) THEN
        IF EXISTS(SELECT 1 FROM users WHERE email = _email) THEN
            RETURN QUERY
            SELECT NULL::INTEGER, false, 'Email already exists', NULL::TEXT;
        END IF;

        INSERT INTO users (name, email, role_id, created_date, reporter_id, school_id, has_system_access)
        VALUES (_name, _email, _role_id, now(), _reporter_id, _school_id, _has_system_access) RETURNING id INTO _user_id;

        INSERT INTO user_profiles
        (user_id, gender, phone, dob, admission_date, class_id, section_id, roll, current_address, permanent_address, father_name, father_phone, mother_name, mother_phone, guardian_name, guardian_phone, relation_of_guardian, school_id)
        VALUES
        (_user_id, _gender, _phone, _dob, _admission_date, _class_id, _section_id, _roll, _current_address, _permanent_address, _father_name, _father_phone, _mother_name, _mother_phone, _guardian_name, _guardian_phone, _relation_of_guardian, _school_id);

        INSERT INTO student_academic_record(school_id, student_id, academic_year_id, class_id, section_id, roll_number)
        VALUES(_school_id, _user_id, (SELECT id FROM academic_years WHERE is_active = TRUE AND school_id = _school_id), _class_id, _section_id, _roll);

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
        admission_date = _admission_date,
        class_id = _class_id,
        section_id  =_section_id,
        roll = _roll,
        current_address = _current_address,
        permanent_address = _permanent_address, 
        father_name = _father_name,
        father_phone = _father_phone,
        mother_name = _mother_name,
        mother_phone = _mother_phone,
        guardian_name = _guardian_name,
        guardian_phone = _guardian_phone,
        relation_of_guardian = _relation_of_guardian
    WHERE user_id = _user_id AND school_id = _school_id;

    RETURN QUERY
    SELECT _user_id, true , 'Student updated successfully', NULL;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT NULL::INTEGER, false, 'Unable to ' || _operation_type || ' student', SQLERRM;
END;
$BODY$;


-- get dashboard data
DROP FUNCTION IF EXISTS public.get_dashboard_data(INTEGER);
CREATE OR REPLACE FUNCTION get_dashboard_data(_user_id INTEGER)
RETURNS JSONB
LANGUAGE plpgsql
AS $BODY$
DECLARE
    _user_role_id INTEGER;
    _user_school_id INTEGER;

    _student_count_current_year INTEGER;
    _student_count_previous_year INTEGER;
    _student_value_comparison INTEGER;
    _student_perc_comparison FLOAT;

    _teacher_count_current_year INTEGER;
    _teacher_count_previous_year INTEGER;
    _teacher_value_comparison INTEGER;
    _teacher_perc_comparison FLOAT;

    _parent_count_current_year INTEGER;
    _parent_count_previous_year INTEGER;
    _parent_value_comparison INTEGER;
    _parent_perc_comparison FLOAT;

    _notice_data JSONB;
    _leave_policy_data JSONB;
    _leave_history_data JSONB;
    _celebration_data JSONB;
    _one_month_leave_data JSONB;

    _filter_verified_notice boolean DEFAULT true;
BEGIN
    -- user check
    IF NOT EXISTS(SELECT 1 FROM users u WHERE u.id = _user_id) THEN
        RAISE EXCEPTION 'User does not exist';
    END IF;

    SELECT t2.static_role_id
    INTO _user_role_id
    FROM users t1
    JOIN roles t2 ON t2.id = t1.role_id
    WHERE t1.id = _user_id;

    IF _user_role_id IS NULL THEN
        RAISE EXCEPTION 'Role does not exist';
    END IF;

    SELECT school_id FROM users u WHERE u.id = _user_id into _user_school_id;
    IF _user_school_id IS NULL THEN
        RAISE EXCEPTION 'School does not exist';
    END IF;

    --student
    IF _user_role_id = 2 THEN
        SELECT COUNT(*) INTO _student_count_current_year
        FROM users t1
        JOIN user_profiles t2 ON t1.id = t2.user_id
        JOIN roles t3 ON t3.id = t1.role_id
        WHERE t3.static_role_id = 4
        AND t1.school_id = _user_school_id
        AND EXTRACT(YEAR FROM t2.admission_date) = EXTRACT(YEAR FROM CURRENT_DATE);

        SELECT COUNT(*) INTO _student_count_previous_year
        FROM users t1
        JOIN user_profiles t2 ON t1.id = t2.user_id
        JOIN roles t3 ON t3.id = t1.role_id
        WHERE t3.static_role_id = 4
        AND t1.school_id = _user_school_id
        AND EXTRACT(YEAR FROM t2.admission_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1;

        _student_value_comparison := _student_count_current_year - _student_count_previous_year;
        IF _student_count_previous_year = 0 THEN
            _student_perc_comparison := 0;
        ELSE
            _student_perc_comparison := (_student_value_comparison::FLOAT / _student_count_previous_year) * 100;
        END IF;

        --teacher
        SELECT COUNT(*) INTO _teacher_count_current_year
        FROM users t1
        JOIN user_profiles t2 ON t1.id = t2.user_id
        JOIN roles t3 ON t3.id = t1.role_id
        WHERE t3.static_role_id = 3
        AND t1.school_id = _user_school_id
        AND EXTRACT(YEAR FROM t2.join_date) = EXTRACT(YEAR FROM CURRENT_DATE);

        SELECT COUNT(*) INTO _teacher_count_previous_year
        FROM users t1
        JOIN user_profiles t2 ON t1.id = t2.user_id
        JOIN roles t3 ON t3.id = t1.role_id
        WHERE t3.static_role_id = 3
        AND t1.school_id = _user_school_id
        AND EXTRACT(YEAR FROM t2.join_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1;

        _teacher_value_comparison := _teacher_count_current_year - _teacher_count_previous_year;
        IF _teacher_count_previous_year = 0 THEN
            _teacher_perc_comparison := 0;
        ELSE
            _teacher_perc_comparison := (_teacher_value_comparison::FLOAT / _teacher_count_previous_year) * 100;
        END IF;

        --parents
        SELECT COUNT(*) INTO _parent_count_current_year
        FROM users t1
        JOIN user_profiles t2 ON t1.id = t2.user_id
        JOIN roles t3 ON t3.id = t1.role_id
        WHERE t3.static_role_id = 5
        AND t1.school_id = _user_school_id
        AND EXTRACT(YEAR FROM t2.join_date) = EXTRACT(YEAR FROM CURRENT_DATE);

        SELECT COUNT(*) INTO _parent_count_previous_year
        FROM users t1
        JOIN user_profiles t2 ON t1.id = t2.user_id
        JOIN roles t3 ON t3.id = t1.role_id
        WHERE t3.static_role_id = 5
        AND t1.school_id = _user_school_id
        AND EXTRACT(YEAR FROM t2.join_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1;

        _parent_value_comparison := _parent_count_current_year - _parent_count_previous_year;
        IF _parent_count_previous_year = 0 THEN
            _parent_perc_comparison := 0;
        ELSE
            _parent_perc_comparison := (_parent_value_comparison::FLOAT / _parent_count_previous_year) * 100;
        END IF;
    ELSE
        _student_count_current_year := 0::INTEGER;
        _student_perc_comparison := 0::FLOAT;
        _student_value_comparison := 0::INTEGER;

        _teacher_count_current_year := 0::INTEGER;
        _teacher_perc_comparison := 0::FLOAT;
        _teacher_value_comparison := 0::INTEGER;

        _parent_count_current_year := 0::INTEGER;
        _parent_perc_comparison := 0::FLOAT;
        _parent_value_comparison := 0::INTEGER;
    END IF;

    -- get notices
    SELECT COALESCE(JSON_AGG(row_to_json(t)), '[]'::json)
    INTO _notice_data
    FROM (
        SELECT *
        FROM get_notices(_user_id, _filter_verified_notice) AS t
        LIMIT 5
    ) AS t;


    --leave polices
    WITH _leave_policies_query AS (
        SELECT
            t2.id,
            t2.name,
            COALESCE(SUM(
                CASE WHEN t3.status = 2 THEN
                    EXTRACT(DAY FROM age(t3.to_date + INTERVAL '1 day', t3.from_date))
                ELSE 0
                END
            ), 0) AS "totalDaysUsed"
        FROM user_leave_policy t1
        JOIN leave_policies t2 ON t1.leave_policy_id = t2.id
        LEFT JOIN user_leaves t3 ON t1.leave_policy_id = t3.leave_policy_id
        WHERE t1.user_id = _user_id AND t1.school_id = _user_school_id
        GROUP BY t2.id, t2.name
    )
    SELECT COALESCE(JSON_AGG(row_to_json(t)), '[]'::json)
    INTO _leave_policy_data
    FROM _leave_policies_query AS t;


    --leave history
    WITH _leave_history_query AS (
        SELECT
            t1.id,
            t2.name AS policy,
            t1.leave_policy_id AS "policyId",
            t1.from_date AS "from",
            t1.to_date AS "to",
            t1.note,
            t3.name AS status,
            t1.submitted_date AS "submitted",
            t1.updated_date AS "updated",
            t1.approved_date AS "approved",
            t4.name AS approver,
            t5.name AS user,
            EXTRACT(DAY FROM age(t1.to_date + INTERVAL '1 day', t1.from_date)) AS days
        FROM user_leaves t1
        JOIN leave_policies t2 ON t1.leave_policy_id = t2.id
        JOIN leave_status t3 ON t1.status = t3.id
        LEFT JOIN users t4 ON t1.approver_id = t4.id
        JOIN users t5 ON t1.user_id = t5.id
        WHERE (
            _user_role_id = 2
            And t1.school_id = _user_school_id
        ) OR (
            _user_role_id != 2
            AND t1.user_id = _user_id
            And t1.school_id = _user_school_id
        )
        ORDER BY submitted_date DESC
        LIMIT 5
    )
    SELECT COALESCE(JSON_AGG(row_to_json(t)), '[]'::json)
    INTO _leave_history_data
    FROM _leave_history_query AS t;


    --celebrations
    WITH _celebrations AS (
        SELECT 
            t1.id AS "userId", 
            t1.name AS user, 
            'Happy Birthday!' AS event, 
            t2.dob AS "eventDate"
        FROM users t1
        JOIN user_profiles t2 ON t1.id = t2.user_id
        WHERE t2.dob IS NOT NULL
        AND t1.school_id = _user_school_id
        AND (
            t2.dob + (EXTRACT(YEAR FROM age(now(), t2.dob)) + 1) * INTERVAL '1 year'
            BETWEEN now() AND now() + INTERVAL '90 days'
        )

        UNION ALL

        SELECT 
            t1.id AS "userId", 
            t1.name AS user, 
            'Happy ' ||
                CASE
                    WHEN t3.static_role_id = 4 THEN
                        EXTRACT(YEAR FROM age(now(), t2.admission_date))
                    ELSE
                        EXTRACT(YEAR FROM age(now(), t2.join_date))
                END || ' Anniversary!' AS event, 
            CASE
                WHEN t3.static_role_id = 4 THEN
                    t2.admission_date
                ELSE
                    t2.join_date
            END AS "eventDate"
        FROM users t1
        JOIN user_profiles t2 ON t1.id = t2.user_id
        JOIN roles t3 ON t3.id = t1.role_id
        WHERE 
        (
            t3.static_role_id = 4
            AND t1.school_id = _user_school_id
            AND t2.admission_date IS NOT NULL 
            AND age(now(), t2.admission_date) >= INTERVAL '1 year'
            AND (
                (t2.admission_date +
                (EXTRACT(YEAR FROM age(now(), t2.admission_date)) + 1 ) * INTERVAL '1 year')
                BETWEEN now() AND now() + '90 days'
            )
        )
        OR 
        (
            t3.static_role_id != 4
            AND t1.school_id = _user_school_id
            AND t2.join_date IS NOT NULL 
            AND age(now(), t2.join_date) >= INTERVAL '1 year'
            AND (
                (t2.join_date +
                (EXTRACT(YEAR FROM age(now(), t2.join_date)) + 1 ) * INTERVAL '1 year')
                BETWEEN now() AND now() + '90 days'
            )
        )
    )
    SELECT COALESCE(JSON_AGG(row_to_json(t) ORDER BY TO_CHAR(t."eventDate", 'MM-DD') ), '[]'::json)
    INTO _celebration_data
    FROM _celebrations AS t LIMIT 5;

    --who is out this week
    WITH _month_dates AS (
        SELECT 
            DATE_TRUNC('day', now()) AS day_start, 
            DATE_TRUNC('day', now()) + INTERVAL '30 days' AS day_end
    )
    SELECT COALESCE(JSON_AGG(row_to_json(t)), '[]'::json)
    INTO _one_month_leave_data
    FROM (
        SELECT
            t1.id AS "userId",
            t1.name AS user,
            t2.from_date AS "fromDate",
            t2.to_date AS "toDate",
            t3.name AS "leaveType"
        FROM users t1
        JOIN user_leaves t2 ON t1.id = t2.user_id
        JOIN leave_policies t3 ON t2.leave_policy_id = t3.id
        JOIN _month_dates t4
        ON
            t2.from_date <= t4.day_end
            AND t2.to_date >= t4.day_start
        WHERE t2.status = 2 AND t1.school_id = _user_school_id
        LIMIT 5
    )t;

    -- Build and return the final JSON object
    RETURN JSON_BUILD_OBJECT(
        'students', JSON_BUILD_OBJECT(
            'totalNumberCurrentYear', _student_count_current_year,
            'totalNumberPercInComparisonFromPrevYear', _student_perc_comparison,
            'totalNumberValueInComparisonFromPrevYear', _student_value_comparison
        ),
        'teachers', JSON_BUILD_OBJECT(
            'totalNumberCurrentYear', _teacher_count_current_year,
            'totalNumberPercInComparisonFromPrevYear', _teacher_perc_comparison,
            'totalNumberValueInComparisonFromPrevYear', _teacher_value_comparison
        ),
        'parents', JSON_BUILD_OBJECT(
            'totalNumberCurrentYear', _parent_count_current_year,
            'totalNumberPercInComparisonFromPrevYear', _parent_perc_comparison,
            'totalNumberValueInComparisonFromPrevYear', _parent_value_comparison
        ),
        'notices', _notice_data,
        'leavePolicies', _leave_policy_data,
        'leaveHistory', _leave_history_data,
        'celebrations', _celebration_data,
        'oneMonthLeave', _one_month_leave_data
    );
END;
$BODY$;


-- get notices
DROP FUNCTION IF EXISTS public.get_notices(INTEGER, boolean);
CREATE OR REPLACE FUNCTION get_notices(_user_id INTEGER, _filter_verified_notice boolean DEFAULT false)
RETURNS TABLE (
    id INTEGER,
    title VARCHAR(100),
    description VARCHAR(400),
    "authorId" INTEGER,
    "createdDate" TIMESTAMP,
    "updatedDate" TIMESTAMP,
    author VARCHAR(100),
    "reviewerName" VARCHAR(100),
    "reviewedDate" TIMESTAMP,
    status VARCHAR(100),
    "statusId" INTEGER,
    "whoHasAccess" TEXT
)
LANGUAGE plpgsql
AS $BODY$
DECLARE
    _user_role_id INTEGER;
    _user_static_roleId INTEGER;
    _user_school_id INTEGER;
BEGIN    
    IF NOT EXISTS (SELECT 1 FROM users u WHERE u.id = _user_id) THEN
        RAISE EXCEPTION 'User does not exist';
    END IF;

    SELECT u.school_id INTO _user_school_id
    FROM users u
    WHERE u.id = _user_id;
    IF _user_school_id IS NULL THEN
        RAISE EXCEPTION 'School does not exist';
    END IF;

    SELECT u.role_id INTO _user_role_id
    FROM users u
    WHERE u.id = _user_id;
    IF _user_role_id IS NULL THEN
        RAISE EXCEPTION 'User role does not exist';
    END IF;

    SELECT r.static_role_id INTO _user_static_roleId
    FROM roles r
    WHERE r.school_id = _user_school_id AND r.id = _user_role_id;
    IF _user_static_roleId IS NULL THEN
        RAISE EXCEPTION 'User static role does not exist';
    END IF;

    RETURN QUERY
    SELECT
        t1.id,
        t1.title,
        t1.description,
        t1.author_id AS "authorId",
        t1.created_date AS "createdDate",
        t1.updated_date AS "updatedDate",
        t2.name AS author,
        t4.name AS "reviewerName",
        t1.reviewed_date AS "reviewedDate",
        t3.alias AS "status",
        t1.status AS "statusId",
        CASE
            WHEN t1.recipient_type = 'SP' THEN
                CASE
                    WHEN t6.static_role_id = 3 THEN
                        CASE
                            WHEN t1.recipient_first_field IS NULL THEN 'All Teachers'
                            ELSE 'Teachers from' || ' "' || t7.name || '" ' || 'department'
                        END
                    WHEN t6.static_role_id = 4 THEN
                        CASE
                            WHEN t1.recipient_first_field IS NULL THEN 'All Students'
                            ELSE 'Students from' || ' "' || t8.name || '" ' || 'class'
                        END
                ELSE 'Unknown Recipient'
                END
            ELSE 'Everyone'
        END AS "whoHasAccess"
    FROM notices t1
    JOIN users t2 ON t1.author_id = t2.id
    JOIN notice_status t3 ON t1.status = t3.id
    LEFT JOIN users t4 ON t1.reviewer_id = t4.id
    LEFT JOIN roles t6 ON t6.id = t1.recipient_role_id
    LEFT JOIN departments t7 ON t7.id = t1.recipient_first_field
    LEFT JOIN classes t8 ON t8.id = t1.recipient_first_field
    WHERE
    (
        _user_static_roleId = 2
        AND t1.school_id = _user_school_id
        AND (
            _filter_verified_notice = false
            OR t1.status = 5
        )
    )
    OR (
        _user_static_roleId != 2
        AND t1.school_id = _user_school_id
        AND (
            t1.status != 6
            AND (
                t1.author_id = _user_id
                OR (
                    t1.status = 5
                    AND (
                        t1.recipient_type = 'EV'
                        OR (
                            t1.recipient_type = 'SP'
                            AND (
                                (
                                    _user_static_roleId = 3
                                    AND t6.static_role_id = 3
                                    AND (
                                        t1.recipient_first_field IS NULL
                                        OR EXISTS (
                                            SELECT 1
                                            FROM user_profiles u
                                            JOIN users t5 ON u.user_id = t5.id
                                            WHERE u.school_id = t1.school_id
                                                AND u.department_id = t1.recipient_first_field
                                                AND t5.id = _user_id
                                                AND t5.role_id = _user_role_id
                                        )
                                    )
                                )
                                OR (
                                    _user_static_roleId = 4
                                    AND t6.static_role_id = 4
                                    AND (
                                        t1.recipient_first_field IS NULL
                                        OR EXISTS (
                                            SELECT 1
                                            FROM user_profiles u
                                            JOIN users t5 ON u.user_id = t5.id
                                            WHERE u.school_id = t1.school_id
                                                AND u.class_id = t1.recipient_first_field
                                                AND t5.id = _user_id
                                                AND t5.role_id = _user_role_id
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    )
    ORDER BY t1.created_date DESC;
END;
$BODY$;


-- add/update exam detail
DROP FUNCTION IF EXISTS public.add_update_exam_detail;
CREATE OR REPLACE FUNCTION add_update_exam_detail(data JSONB)
RETURNS TABLE(status boolean, message TEXT, description TEXT)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _type CHAR(1) DEFAULT 'S';
    _operation_type CHAR(1);
    _operation_type_description VARCHAR(5);
    _school_id INTEGER;
    _class_id INTEGER;
    _section_id INTEGER;
    _exam_id INTEGER;
    _exam_details JSONB;
    _exam JSONB;
BEGIN
    _operation_type := (data->>'action')::CHAR(1);
    _school_id := (data->>'schoolId')::INTEGER;
    _class_id := (data->>'classId')::INTEGER;
    _section_id := (data->>'sectionId')::INTEGER;
    _exam_id := (data->>'examId')::INTEGER;
    _exam_details := (data->>'examDetails')::JSONB;

    IF NOT EXISTS(SELECT 1 FROM exams WHERE id = _exam_id) THEN
        RETURN QUERY
        SELECT false, 'Exam does not exist', NULL::TEXT;
    END IF;

    IF _operation_type = 'a' THEN
        _operation_type_description = 'add';

        FOR _exam IN SELECT * FROM jsonb_array_elements(_exam_details)
        LOOP
            IF NOT EXISTS(
                SELECT 1 FROM subjects
                WHERE id = (_exam->>'subjectId')::INTEGER
                    AND school_id = _school_id
                    AND class_id = _class_id
                    AND (_section_id IS NULL OR section_id = _section_id)
            )THEN
                RAISE NOTICE 'Skipping entry: % (subject Id does not belong to the class/section)', _exam;
                CONTINUE;
            END IF;

            INSERT INTO exams(
                school_id,
                class_id,
                section_id,
                type,
                parent_exam_id,
                name,
                subject_id,
                exam_date,
                start_time,
                end_time,
                total_marks,
                theory_passing_marks,
                practical_passing_marks
            )
            VALUES (
                _school_id::INT,
                _class_id::INT,
                _section_id::INT,
                _type,
                _exam_id::INT,
                _exam_id || '_child',
                (_exam->>'subjectId')::INT,
                (_exam->>'examDate')::DATE,
                (_exam->>'startTime')::TIME,
                (_exam->>'endTime')::TIME,
                (_exam->>'totalMarks')::NUMERIC(5, 2),
                (_exam->>'theoryPassingMarks')::NUMERIC(5, 2),
                (_exam->>'practicalPassingMarks')::NUMERIC(5, 2)
            );
        END LOOP;
        
        RETURN QUERY
        SELECT true, 'Exam detail added successsfully', NULL::TEXT;
    ELSE
        _operation_type_description = 'update';

        FOR _exam IN SELECT * FROM jsonb_array_elements(_exam_details)
        LOOP
            IF NOT EXISTS(
                SELECT 1 FROM exams
                WHERE id = (_exam->>'id')::INT
                    AND school_id = _school_id                
                    AND class_id = _class_id
                    AND (_section_id IS NULL OR section_id = _section_id)
                    AND type = _type
                    AND parent_exam_id = _exam_id
            ) THEN
                RAISE NOTICE 'Skipping entry: % (Invalid exam details)', _exam;
                CONTINUE;
            END IF;

            UPDATE exams
            SET exam_date = (_exam->>'examDate')::DATE,
                start_time = (_exam->>'startTime')::TIME,
                end_time = (_exam->>'endTime')::TIME,
                total_marks = (_exam->>'totalMarks')::NUMERIC(5 ,2),
                theory_passing_marks = (_exam->>'theoryPassingMarks')::NUMERIC(5 ,2),
                practical_passing_marks = (_exam->>'practicalPassingMarks')::NUMERIC(5 ,2)
            WHERE school_id = _school_id AND id = (_exam->>'id')::INT;
        END LOOP;

        RETURN QUERY
        SELECT true, 'Exam detail updated successsfully', NULL::TEXT;
    END IF;   
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT false, 'Unable to ' || _operation_type_description || ' exam detail', SQLERRM;
END;
$BODY$;


-- add/update mark detail
DROP FUNCTION IF EXISTS public.add_update_mark_detail;
CREATE OR REPLACE FUNCTION add_update_mark_detail(data JSONB)
RETURNS TABLE(status boolean, message TEXT, description TEXT)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _type CHAR(1) DEFAULT 'S';
    _operation_type CHAR(1);
    _operation_type_description VARCHAR(5);
    _school_id INTEGER;
    _class_id INTEGER;
    _section_id INTEGER;
    _exam_id INTEGER;
    _mark_details JSONB;
    _total_marks_obtained NUMERIC(5, 2);
    _grade_point NUMERIC(5, 2);
    _mark JSONB;
    _subject_total_marks_for_given_exam NUMERIC(5, 2);
    _active_academic_year_id INTEGER;
BEGIN
    _operation_type := (data->>'action')::CHAR(1);
    _school_id := (data->>'schoolId')::INTEGER;
    _class_id := (data->>'classId')::INTEGER;
    _section_id := (data->>'sectionId')::INTEGER;
    _exam_id := (data->>'examId')::INTEGER;
    _mark_details := (data->>'markDetails')::JSONB;

    SELECT id
    INTO _active_academic_year_id
    FROM academic_years
    WHERE school_id = _school_id AND is_active = true;

    IF _active_academic_year_id IS NULL THEN
        RETURN QUERY
        SELECT false, "Denied. Academic year is not setup properly.", NULL::TEXT;
    END IF;

    IF NOT EXISTS(SELECT 1 FROM exams WHERE id = _exam_id) THEN
        RETURN QUERY
        SELECT false, 'Exam does not exist', NULL::TEXT;
    END IF;

    IF _operation_type = 'a' THEN
        _operation_type_description = 'add';

        FOR _mark IN SELECT * FROM jsonb_array_elements(_mark_details)
        LOOP
            IF NOT EXISTS(
                SELECT 1 FROM users
                WHERE id = (_mark->>'userId')::INTEGER
                    AND school_id = _school_id
                    AND class_id = _class_id
                    AND (_section_id IS NULL OR section_id = _section_id)
            )THEN
                RAISE NOTICE 'Skipping entry: % (User does not exist)', _mark;
                CONTINUE;
            END IF;

            IF NOT EXISTS(
                SELECT 1 FROM subjects
                WHERE id = (_mark->>'subjectId')::INTEGER
                    AND school_id = _school_id
                    AND class_id = _class_id
                    AND (_section_id IS NULL OR section_id = _section_id)
            )THEN
                RAISE NOTICE 'Skipping entry: % (subjectId does not belong to the class/section)', _mark;
                CONTINUE;
            END IF;

            _total_marks_obtained := (_mark->>'theoryMarksObtained')::NUMERIC(5, 2) + (_mark->>'practicalMarksObtained')::NUMERIC(5, 2);

            SELECT COALESCE(total_marks, 0)
            INTO _subject_total_marks_for_given_exam
            FROM exams
            WHERE type = _type
                AND school_id = _school_id
                AND parent_exam_id = _exam_id
                AND subject_id = (_mark->>'subjectId')::INT;

            _grade_point := (_total_marks_obtained / _subject_total_marks_for_given_exam ) * 4;

            INSERT INTO marks(
                school_id,
                academic_year_id,
                class_id,
                section_id,
                exam_id,
                user_id,
                subject_id,
                theory_marks_obtained,
                practical_marks_obtained,
                total_marks_obtained,
                grade
            )
            VALUES (
                _school_id::INT,
                _active_academic_year_id,
                _class_id::INT,
                _section_id::INT,
                _exam_id::INT,
                (_mark->>'userId')::INT,
                (_mark->>'subjectId')::DATE,
                (_mark->>'theoryMarksObtained')::NUMERIC(5, 2),
                (_mark->>'practicalMarksObtained')::NUMERIC(5, 2),
                _total_marks_obtained,
                _grade_point
            );
        END LOOP;
        
        RETURN QUERY
        SELECT true, 'Mark detail added successsfully', NULL::TEXT;
    ELSE
        _operation_type_description = 'update';

        FOR _mark IN SELECT * FROM jsonb_array_elements(_mark_details)
        LOOP
            IF NOT EXISTS(
                SELECT 1 FROM users
                WHERE id = (_mark->>'userId')::INTEGER
                    AND school_id = _school_id
                    AND class_id = _class_id
                    AND (_section_id IS NULL OR section_id = _section_id)
            )THEN
                RAISE NOTICE 'Skipping entry: % (User does not exist)', _mark;
                CONTINUE;
            END IF;

            _total_marks_obtained := (_mark->>'theoryMarksObtained')::NUMERIC(5, 2) + (_mark->>'practicalMarksObtained')::NUMERIC(5, 2);

            SELECT COALESCE(total_marks, 0)
            INTO _subject_total_marks_for_given_exam
            FROM exams
            WHERE id = (_mark->>'id')::INT;

            _grade_point := (_total_marks_obtained / _subject_total_marks_for_given_exam ) * 4;

            UPDATE marks
            SET theory_marks_obtained = (_mark->>'theoryMarksObtained')::NUMERIC(5, 2),
                practical_marks_obtained = (_mark->>'practicalMarksObtained')::NUMERIC(5, 2),
                total_marks_obtained = _total_marks_obtained,
                grade = _grade_point,
                updated_date = NOW()
            WHERE id = (_mark->>'id')::INT AND school_id = _school_id;
        END LOOP;

        RETURN QUERY
        SELECT true, 'Mark detail updated successsfully', NULL::TEXT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT false, 'Unable to ' || _operation_type_description || ' mark detail', SQLERRM;
END;
$BODY$;

-- invoice generate sample
-- {
--   "schoolId": 1,
--   "initiator": 3, -- one who is creating the invoice
--   "invoices": [
--     {
--       "userId": 101,
--       "description": "Monthly tuition fee for John Doe",
--       "dueDate": "2024-12-31",
--       "items": [
--         { "feeId": 1, "description": 'transport fee', "quantity": 1, amount: 33 },
--         { "feeId": 2, "description": 'tuition fee', "quantity": 1, amount: 55 }
--       ]
--     }
--   ]
-- }


-- generate invoices
DROP FUNCTION IF EXISTS public.generate_invoices;
CREATE OR REPLACE FUNCTION generate_invoices(payload JSONB)
RETURNS TABLE(status boolean, message TEXT, description TEXT)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _school_id INTEGER;
    _initiator INT;
    _invoices JSONB;
    _invoice_user_id INTEGER;
    _items JSONB;
    _new_invoice_number JSONB;
    _new_invoice_id INTEGER;
    _invoice_amount NUMERIC(10, 2) DEFAULT 0;
    _invoice_outstanding_amount NUMERIC(10, 2) DEFAULT 0;
    _invoice_discount NUMERIC(10, 2) DEFAULT 0;
    _invoice_item_fee_structure_id INTEGER;
    _invoice_item_fee_amount NUMERIC(10, 2) DEFAULT 0;
    _invoice_item_discount_amount NUMERIC(10, 2) DEFAULT 0;
    _invoice JSONB;
    _item JSONB;
    _active_academic_year_id INTEGER;
    _active_fiscal_year_id INTEGER;
    _academic_period_id INTEGER;
    _max_period_id INTEGER;
    _max_period_invoice_status VARCHAR(15);
BEGIN
    _school_id := (payload->>'schoolId')::INT;
    _invoices := (payload->>'action')::JSONB;
    _initiator := (payload->>'initiator')::JSONB;
    _academic_period_id := (payload->>'academicPeriodId')::JSONB;

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

    FOR _invoice IN (SELECT * FROM _invoices)
    LOOP
        _invoice_user_id := _invoice->>'userId';
        _items := _invoice->>'items';

        -- validate user existence
        IF NOT EXISTS(SELECT 1 FROM users WHERE id = _invoice_user_id AND school_id = _school_id) THEN
            RAISE NOTICE 'Invalid user_id (%) for invoice', _invoice_user_id;
            CONTINUE;
        END IF;

        SELECT COALESCE(academic_period_id, 0), status
        INTO _max_period_id, _max_period_invoice_status
        FROM invoices
        WHERE school_id = _school_id
            AND user_id = _invoice_user_id
            AND academic_year_id = _active_academic_year_id
        ORDER BY academic_period_id DESC
        LIMIT 1;

        IF (_academic_period_id < _max_period_id) OR
            (_academic_period_id = _max_period_id AND _max_period_invoice_status != 'CANCELLED')
        THEN
            RAISE NOTICE 'Denied. Invoice already generated for given period.';
            CONTINUE;
        END IF;

        IF _max_period_id - _academic_period_id != 1 THEN
            RAISE NOTICE 'Denied. Invoice generation period gap can not be more than one.';
            CONTINUE;
        END IF;

        -- insert invoice and get new invoice id
        INSERT INTO invoices(
            school_id,
            academic_year_id,
            fiscal_year_id,
            academic_period_id,
            initiator,
            description,
            user_id,
            due_date,
            status
        ) VALUES(
            _school_id,
            _active_academic_year_id,
            _active_fiscal_year_id,
            _academic_period_id,
            _initiator,
            _invoice->>'description',
            _invoice_user_id,
            _invoice->>'dueDate',
            'ISSUED'
        ) RETURNING id INTO _new_invoice_id;

        -- insert invoice items
        FOR _item IN (SELECT * FROM _items)
        LOOP
            SELECT fee_structure_id, amount, discounted_amt
            INTO _invoice_item_fee_structure_id, _invoice_item_fee_amount, _invoice_discount
            FROM student_fees
            WHERE id = (_item->>'studentFeeId');

            INSERT INTO invoice_items(
                school_id ,
                invoice_id,
                fee_structure_id,
                student_fee_id,
                description,
                amount,
                quantity,
                total_amount,
                total_discount
            ) VALUES(
                _school_id,
                _new_invoice_id,
                _invoice_item_fee_structure_id,
                _item->>'studentFeeId',
                _item->>'description',
                _invoice_item_fee_amount,
                _item->>'quantity',
                (_item->>'quantity') * _invoice_item_fee_amount - _invoice_item_discount_amount,
                _invoice_item_discount_amount * (_item->>'quantity')::INTEGER
            );
        END LOOP;

        -- generate invoice number
        _new_invoice_number := CONCAT(
            'INV-',
            TO_CHAR(CURRENT_DATE, 'YYYYMM'),
            '-', _new_invoice_id,
            '-', _school_id
        );

        SELECT COALESCE(SUM(total_amount), 0)
        FROM invoice_items
        WHERE invoice_id = _new_invoice_id
        INTO _invoice_amount;

        SELECT COALESCE(SUM(total_discount), 0)
        FROM invoice_items
        WHERE invoice_id = _new_invoice_id
        INTO _invoice_discount;

        _invoice_outstanding_amount := _invoice_amount - _invoice_discount;

        -- update invoice number and amount
        UPDATE invoices SET
            invoice_number = _new_invoice_number,
            amount = _invoice_outstanding_amount,
            outstanding_amt = _invoice_outstanding_amount
        WHERE id = _new_invoice_id;
    END LOOP;

    RETURN QUERY
    SELECT true, 'Invoice generated successfully', NULL::TEXT;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT false, 'Unable to generate invoice', SQLERRM;
END
$BODY$;


-- pay invoice
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

    IF NOT EXISTS(SELECT 1 FROM invoices WHERE school_id = _school_id AND id = _invoice_id) THEN
        RETURN QUERY
        SELECT false, 'Invoice does not exist', NULL::TEXT;
    END IF;

    SELECT COALESCE(outstanding_amt, 0), user_id, status
    INTO _invoice_outstanding_amount, _invoice_user_id, _invoice_status
    FROM invoices WHERE id = _invoice_id;

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



-- refund invoice
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

    IF NOT EXISTS(SELECT 1 FROM invoices WHERE school_id = _school_id AND id = _invoice_id) THEN
        RETURN QUERY
        SELECT false, 'Invoice does not exist', NULL:: TEXT;
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
    END IF;

    IF _refund_amount > _invoice_paid_amount THEN
        RETURN QUERY
        SELECT
            false,
            'Refund denied. Refund amount can not be greater than paid invoice paid amount.',
            NULL::TEXT;
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
            CASE WHEN (_item->>'discountType') = 'P' THEN
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

DROP FUNCTION IF EXISTS public.delete_period_order;
CREATE OR REPLACE FUNCTION delete_period_order(payload jsonb)
RETURNS TABLE (status boolean, message TEXT, description TEXT)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _school_id INTEGER;
    _academic_period_id INTEGER;
    _academic_level_id INTEGER;
    _deleted_order_id INTEGER;
BEGIN
    _school_id := (payload->>'schoolId');
    _academic_period_id := (payload->>'academicPeriodId');

    IF NOT EXISTS(SELECT 1 FROM academic_periods WHERE school_id = _school_id AND id = _academic_period_id) THEN
        RETURN QUERY
        SELECT false, 'Period does not exist', NULL::TEXT;
    END IF;

    SELECT academic_level_id INTO _academic_level_id
    FROM academic_periods
    WHERE school_id = _school_id AND id = _academic_period_id;

    DELETE FROM academic_periods
    WHERE school_id = _school_id AND id = _academic_period_id
    RETURNING sort_order INTO _deleted_order_id;

    IF NOT EXISTS(
        SELECT 1 FROM academic_periods
        WHERE school_id = _school_id
            AND academic_level_id = _academic_level_id
            AND sort_order > _deleted_order_id
    ) THEN
        RETURN QUERY
        SELECT true, 'Period deleted successfully', NULL::TEXT;
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
