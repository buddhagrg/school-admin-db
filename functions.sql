-- staff add/update
DROP FUNCTION IF EXISTS staff_add_update(JSONB);
CREATE OR REPLACE FUNCTION public.staff_add_update(data jsonb)
RETURNS TABLE("userId" INTEGER, status boolean, message TEXT, description TEXT) 
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _operationType VARCHAR(10);

    _userId INTEGER;
    _name TEXT;
    _roleId INTEGER;
    _staticRoleId INTEGER;
    _gender TEXT;
    _maritalStatus TEXT;
    _phone TEXT;
    _email TEXT;
    _dob DATE;
    _joinDate DATE;
    _qualification TEXT;
    _experience TEXT;
    _currentAddress TEXT;
    _permanentAddress TEXT;
    _fatherName TEXT;
    _motherName TEXT;
    _emergencyPhone TEXT;
    _systemAccess BOOLEAN;
    _reporterId INTEGER;
    _schoolId INTEGER;
BEGIN
    _userId := COALESCE((data ->>'userId')::INTEGER, NULL);
    _name := COALESCE(data->>'name', NULL);
    _roleId := COALESCE((data->>'role')::INTEGER, NULL);
    _gender := COALESCE(data->>'gender', NULL);
    _maritalStatus := COALESCE(data->>'maritalStatus', NULL);
    _phone := COALESCE(data->>'phone', NULL);
    _email := COALESCE(data->>'email', NULL);
    _dob := COALESCE((data->>'dob')::DATE, NULL);
    _joinDate := COALESCE((data->>'joinDate')::DATE, NULL);
    _qualification := COALESCE(data->>'qualification', NULL);
    _experience := COALESCE(data->>'experience', NULL);
    _currentAddress := COALESCE(data->>'currentAddress', NULL);
    _permanentAddress := COALESCE(data->>'permanentAddress', NULL);
    _fatherName := COALESCE(data->>'fatherName', NULL);
    _motherName := COALESCE(data->>'motherName', NULL);
    _emergencyPhone := COALESCE(data->>'emergencyPhone', NULL);
    _systemAccess := COALESCE((data->>'systemAccess')::BOOLEAN, NULL);
    _reporterId := COALESCE((data->>'reporterId')::INTEGER, NULL);
    _schoolId := COALESCE((data->>'schoolId')::INTEGER, NULL);

    IF _userId IS NULL THEN
        _operationType := 'add';
    ELSE
        _operationType := 'update';
    END IF;

    IF _schoolId IS NULL THEN
        RETURN QUERY
        SELECT NULL::INTEGER, false, 'School Id may not be empty', NULL::TEXT;
    END IF;

    IF _roleId IS NULL THEN
        RETURN QUERY
        SELECT NULL::INTEGER, false, 'Role may not be empty', NULL::TEXT;
    END IF;

    SELECT static_role_id INTO _staticRoleId FROM roles WHERE id = _roleId And school_id = _schoolId;
    
    IF _staticRoleId = 4 THEN
        RETURN QUERY
        SELECT NULL::INTEGER, false, 'Student cannot be staff', NULL::TEXT;
    END IF;

    IF NOT EXISTS(SELECT 1 FROM users WHERE id = _userId) THEN

        IF EXISTS(SELECT 1 FROM users WHERE email = _email) THEN
            RETURN QUERY
            SELECT NULL::INTEGER, false, 'Email already exists', NULL::TEXT;
        END IF;

        INSERT INTO users (name,email,role_id,created_date,reporter_id, school_id)
        VALUES (_name,_email,_roleId,now(),_reporterId,_schoolId) RETURNING id INTO _userId;

        INSERT INTO user_profiles
        (user_id, gender, marital_status, phone,dob,join_date,qualification,experience,current_address,permanent_address,father_name,mother_name,emergency_phone, school_id)
        VALUES
        (_userId,_gender,_maritalStatus,_phone,_dob,_joinDate,_qualification,_experience,_currentAddress,_permanentAddress,_fatherName,_motherName,_emergencyPhone, _schoolId);

        RETURN QUERY
        SELECT _userId, true, 'Staff added successfully', NULL;
    END IF;


    --update user tables
    UPDATE users
    SET
        name = _name,
        email = _email,
        role_id = _roleId,
        is_active = _systemAccess,
        reporter_id = _reporterId,
        updated_date = now()
    WHERE id = _userId AND school_id = _schoolId;

    UPDATE user_profiles
    SET
        gender = _gender,
        marital_status = _maritalStatus,
        phone = _phone,
        dob = _dob,
        join_date = _joinDate,
        qualification = _qualification,
        experience = _experience,
        current_address = _currentAddress,
        permanent_address = _permanentAddress, 
        father_name = _fatherName,
        mother_name = _motherName,
        emergency_phone = _emergencyPhone
    WHERE user_id = _userId AND school_id = _schoolId;

    RETURN QUERY
    SELECT _userId, true, 'Staff updated successfully', NULL;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT _userId::INTEGER, false, 'Unable to ' || _operationType || ' staff', SQLERRM;
END;
$BODY$;


--student add/update
DROP FUNCTION IF EXISTS student_add_update(JSONB);
CREATE OR REPLACE FUNCTION public.student_add_update(data jsonb)
RETURNS TABLE("userId" INTEGER, status boolean, message TEXT, description TEXT) 
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _operationType VARCHAR(10);
    _reporterId INTEGER;

    _userId INTEGER;
    _name TEXT;
    _roleId INTEGER;
    _gender TEXT;
    _phone TEXT;
    _email TEXT;
    _dob DATE;
    _currentAddress TEXT;
    _permanentAddress TEXT;
    _fatherName TEXT;
    _fatherPhone TEXT;
    _motherName TEXT;
    _motherPhone TEXT;
    _guardianName TEXT;
    _guardianPhone TEXT;
    _relationOfGuardian TEXT;
    _systemAccess BOOLEAN;
    _classId TEXT;
    _sectionId TEXT;
    _admissionDt DATE;
    _roll INTEGER;
    _schoolId INTEGER;
BEGIN
    _userId := COALESCE((data ->>'userId')::INTEGER, NULL);
    _name := COALESCE(data->>'name', NULL);
    _gender := COALESCE(data->>'gender', NULL);
    _phone := COALESCE(data->>'phone', NULL);
    _email := COALESCE(data->>'email', NULL);
    _dob := COALESCE((data->>'dob')::DATE, NULL);
    _currentAddress := COALESCE(data->>'currentAddress', NULL);
    _permanentAddress := COALESCE(data->>'permanentAddress', NULL);
    _fatherName := COALESCE(data->>'fatherName', NULL);
    _fatherPhone := COALESCE(data->>'fatherPhone', NULL);
    _motherName := COALESCE(data->>'motherName', NULL);
    _motherPhone := COALESCE(data->>'motherPhone', NULL);
    _guardianName := COALESCE(data->>'guardianName', NULL);
    _guardianPhone := COALESCE(data->>'guardianPhone', NULL);
    _relationOfGuardian := COALESCE(data->>'relationOfGuardian', NULL);
    _systemAccess := COALESCE((data->>'systemAccess')::BOOLEAN, NULL);
    _classId := COALESCE(data->>'class', NULL);
    _sectionId := COALESCE(data->>'section', NULL);
    _admissionDt := COALESCE((data->>'admissionDate')::DATE, NULL);
    _roll := COALESCE((data->>'roll')::INTEGER, NULL);
    _schoolId := COALESCE((data->>'schoolId')::INTEGER, NULL);

    IF _userId IS NULL THEN
        _operationType := 'add';
    ELSE
        _operationType := 'update';
    END IF;

    IF _schoolId IS NULL THEN
        RETURN QUERY
        SELECT NULL::INTEGER, false, 'School Id may not be empty', NULL::TEXT;
    END IF;

    SELECT id INTO _roleId FROM roles WHERE school_id = _schoolId AND static_role_id = 4;

    SELECT teacher_id
    INTO _reporterId
    FROM class_teachers
    WHERE class_id = _classId AND section_id = _sectionId;

    IF _reporterId IS NULL THEN
        SELECT t1.id
        INTO _reporterId
        FROM users t1
        JOIN roles t2 ON t2.id = t1.role_id
        WHERE t2.static_role_id = 2 AND t2.school_id = _schoolId
        ORDER BY id ASC
        LIMIT 1;
    END IF;

    IF NOT EXISTS(SELECT 1 FROM users WHERE id = _userId) THEN
        IF EXISTS(SELECT 1 FROM users WHERE email = _email) THEN
            RETURN QUERY
            SELECT NULL::INTEGER, false, 'Email already exists', NULL::TEXT;
        END IF;

        INSERT INTO users (name,email,role_id,created_date,reporter_id, school_id)
        VALUES (_name,_email,_roleId,now(),_reporterId, _schoolId) RETURNING id INTO _userId;

        INSERT INTO user_profiles
        (user_id,gender,phone,dob,admission_date,class_id,section_id,roll,current_address,permanent_address,father_name,father_phone,mother_name,mother_phone,guardian_name,guardian_phone,relation_of_guardian, school_id)
        VALUES
        (_userId,_gender,_phone,_dob,_admissionDt,_classId,_sectionId,_roll,_currentAddress,_permanentAddress,_fatherName,_fatherPhone,_motherName,_motherPhone,_guardianName,_guardianPhone,_relationOfGuardian, _schoolId);

        INSERT INTO student_academic_record(school_id, student_id, academic_year_id, class_id, section_id, roll_number)
        VALUES(_schoolId, _userId, (SELECT id FROM academic_years WHERE is_active = TRUE AND school_id = _schoolId), _classId, _sectionId, _roll);

        RETURN QUERY
        SELECT _userId, true, 'Student added successfully', NULL;
    END IF;

    --update user tables
    UPDATE users
    SET
        name = _name,
        email = _email,
        role_id = _roleId,
        is_active = _systemAccess,
        updated_date = now()
    WHERE id = _userId AND school_id = _schoolId;

    UPDATE user_profiles
    SET
        gender = _gender,
        phone = _phone,
        dob = _dob,
        admission_date = _admissionDt,
        class_id = _classId,
        section_id  =_sectionId,
        roll = _roll,
        current_address = _currentAddress,
        permanent_address = _permanentAddress, 
        father_name = _fatherName,
        father_phone = _fatherPhone,
        mother_name = _motherName,
        mother_phone = _motherPhone,
        guardian_name = _guardianName,
        guardian_phone = _guardianPhone,
        relation_of_guardian = _relationOfGuardian
    WHERE user_id = _userId AND school_id = _schoolId;

    RETURN QUERY
    SELECT _userId, true , 'Student updated successfully', NULL;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT NULL::INTEGER, false, 'Unable to ' || _operationType || ' student', SQLERRM;
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

    _notices_data JSONB;
    _leave_policies_data JSONB;
    _leave_histories_data JSONB;
    _celebrations_data JSONB;
    _one_month_leave_data JSONB;
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
    INTO _notices_data
    FROM (
        SELECT *
        FROM get_notices(_user_id) AS t
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
    INTO _leave_policies_data
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
    INTO _leave_histories_data
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
    INTO _celebrations_data
    FROM _celebrations AS t;

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
        WHERE t2.status = 2
        AND t1.school_id = _user_school_id
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
        'notices', _notices_data,
        'leavePolicies', _leave_policies_data,
        'leaveHistory', _leave_histories_data,
        'celebrations', _celebrations_data,
        'oneMonthLeave', _one_month_leave_data
    );
END;
$BODY$;


-- get notices
DROP FUNCTION IF EXISTS public.get_notices(INTEGER);
CREATE OR REPLACE FUNCTION get_notices(_user_id INTEGER)
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
    _user_school_id INTEGER;
BEGIN    
    IF NOT EXISTS (SELECT 1 FROM users u WHERE u.id = _user_id) THEN
        RAISE EXCEPTION 'User does not exist';
    END IF;

    SELECT school_id INTO _user_school_id FROM users u WHERE u.id = _user_id;
    IF _user_school_id IS NULL THEN
        RAISE EXCEPTION 'School does not exist';
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
        NULL AS "whoHasAccess"
    FROM notices t1
    LEFT JOIN users t2 ON t1.author_id = t2.id
    LEFT JOIN notice_status t3 ON t1.status = t3.id
    LEFT JOIN users t4 ON t1.reviewer_id = t4.id
    JOIN roles t6 ON t6.id = t1.recipient_role_id  
    WHERE (
        t6.static_role_id = 2
        AND t1.school_id = _user_school_id
        AND (
            t1.author_id = _user_id
            OR (
                t1.status != 1
                AND t1.author_id != _user_id
            )
        )
    )
    OR (
        t6.static_role_id != 2
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
                                    t6.static_role_id = 3
                                    AND (
                                        t1.recipient_first_field IS NULL
                                        OR EXISTS (
                                            SELECT 1
                                            FROM user_profiles u
                                            JOIN users t5 ON u.user_id = t5.id
                                            WHERE u.department_id = t1.recipient_first_field
                                            AND t5.id = _user_id AND t5.role_id = _user_role_id
                                        )
                                    )
                                )
                                OR (
                                    t6.static_role_id = 4
                                    AND (
                                        t1.recipient_first_field IS NULL
                                        OR EXISTS (
                                            SELECT 1
                                            FROM user_profiles u
                                            JOIN users t5 ON u.user_id = t5.id
                                            WHERE u.class_id = t1.recipient_first_field
                                            AND t5.id = _user_id AND t5.role_id = _user_role_id
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
    _operationType CHAR(1);
    _operationTypeDescription VARCHAR(5);
    _schoolId INTEGER;
    _classId INTEGER;
    _sectionId INTEGER;
    _examId INTEGER;
    _examDetails JSONB;
    _exam JSONB;
BEGIN
    _operationType := (data->>'action')::CHAR(1);
    _schoolId := (data->>'schoolId')::INTEGER;
    _classId := (data->>'classId')::INTEGER;
    _sectionId := (data->>'sectionId')::INTEGER;
    _examId := (data->>'examId')::INTEGER;
    _examDetails := (data->>'examDetails')::JSONB;

    IF NOT EXISTS(SELECT 1 FROM exams WHERE id = _examId) THEN
        RETURN QUERY
        SELECT false, 'Exam does not exist', NULL::TEXT;
    END IF;

    IF _operationType = 'a' THEN
        _operationTypeDescription = 'add';

        FOR _exam IN SELECT * FROM jsonb_array_elements(_examDetails)
        LOOP
            IF NOT EXISTS(
                SELECT 1 FROM subjects
                WHERE id = (_exam->>'subjectId')::INTEGER
                    AND school_id = _schoolId
                    AND class_id = _classId
                    AND (_sectionId IS NULL OR section_id = _sectionId)
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
                _schoolId::INT,
                _classId::INT,
                _sectionId::INT,
                _type,
                _examId::INT,
                _examId || '_child',
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
        _operationTypeDescription = 'update';

        FOR _exam IN SELECT * FROM jsonb_array_elements(_examDetails)
        LOOP
            IF NOT EXISTS(
                SELECT 1 FROM exams
                WHERE id = (_exam->>'id')::INT
                    AND school_id = _schoolId                
                    AND class_id = _classId
                    AND (_sectionId IS NULL OR section_id = _sectionId)
                    AND type = _type
                    AND parent_exam_id = _examId
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
            WHERE school_id = _schoolId AND id = (_exam->>'id')::INT;
        END LOOP;

        RETURN QUERY
        SELECT true, 'Exam detail updated successsfully', NULL::TEXT;
    END IF;   
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT false, 'Unable to ' || _operationTypeDescription || ' exam detail', SQLERRM;
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
    _operationType CHAR(1);
    _operationTypeDescription VARCHAR(5);
    _schoolId INTEGER;
    _classId INTEGER;
    _sectionId INTEGER;
    _examId INTEGER;
    _markDetails JSONB;
    _totalMarksObtained NUMERIC(5, 2);
    _gradePoint NUMERIC(5, 2);
    _mark JSONB;
    _subjectTotalMarksForGivenExam NUMERIC(5, 2);
    _activeAcademicYearId INTEGER;
BEGIN
    _operationType := (data->>'action')::CHAR(1);
    _schoolId := (data->>'schoolId')::INTEGER;
    _classId := (data->>'classId')::INTEGER;
    _sectionId := (data->>'sectionId')::INTEGER;
    _examId := (data->>'examId')::INTEGER;
    _markDetails := (data->>'markDetails')::JSONB;

    SELECT id
    INTO _activeAcademicYearId
    FROM academic_years
    WHERE school_id = _schoolId AND is_active = true;

    IF _activeAcademicYearId IS NULL THEN
        RETURN QUERY
        SELECT false, "Denied. Academic year is not setup properly.", NULL::TEXT;
    END IF;

    IF NOT EXISTS(SELECT 1 FROM exams WHERE id = _examId) THEN
        RETURN QUERY
        SELECT false, 'Exam does not exist', NULL::TEXT;
    END IF;

    IF _operationType = 'a' THEN
        _operationTypeDescription = 'add';

        FOR _mark IN SELECT * FROM jsonb_array_elements(_markDetails)
        LOOP
            IF NOT EXISTS(
                SELECT 1 FROM users
                WHERE id = (_mark->>'userId')::INTEGER
                    AND school_id = _schoolId
                    AND class_id = _classId
                    AND (_sectionId IS NULL OR section_id = _sectionId)
            )THEN
                RAISE NOTICE 'Skipping entry: % (User does not exist)', _mark;
                CONTINUE;
            END IF;

            IF NOT EXISTS(
                SELECT 1 FROM subjects
                WHERE id = (_mark->>'subjectId')::INTEGER
                    AND school_id = _schoolId
                    AND class_id = _classId
                    AND (_sectionId IS NULL OR section_id = _sectionId)
            )THEN
                RAISE NOTICE 'Skipping entry: % (subjectId does not belong to the class/section)', _mark;
                CONTINUE;
            END IF;

            _totalMarksObtained := (_mark->>'theoryMarksObtained')::NUMERIC(5, 2) + (_mark->>'practicalMarksObtained')::NUMERIC(5, 2);

            SELECT COALESCE(total_marks, 0)
            INTO _subjectTotalMarksForGivenExam
            FROM exams
            WHERE type = _type
                AND school_id = _schoolId
                AND parent_exam_id = _examId
                AND subject_id = (_mark->>'subjectId')::INT;

            _gradePoint := (_totalMarksObtained / _subjectTotalMarksForGivenExam ) * 4;

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
                _schoolId::INT,
                _activeAcademicYearId,
                _classId::INT,
                _sectionId::INT,
                _examId::INT,
                (_mark->>'userId')::INT,
                (_mark->>'subjectId')::DATE,
                (_mark->>'theoryMarksObtained')::NUMERIC(5, 2),
                (_mark->>'practicalMarksObtained')::NUMERIC(5, 2),
                _totalMarksObtained,
                _gradePoint
            );
        END LOOP;
        
        RETURN QUERY
        SELECT true, 'Mark detail added successsfully', NULL::TEXT;
    ELSE
        _operationTypeDescription = 'update';

        FOR _mark IN SELECT * FROM jsonb_array_elements(_markDetails)
        LOOP
            IF NOT EXISTS(
                SELECT 1 FROM users
                WHERE id = (_mark->>'userId')::INTEGER
                    AND school_id = _schoolId
                    AND class_id = _classId
                    AND (_sectionId IS NULL OR section_id = _sectionId)
            )THEN
                RAISE NOTICE 'Skipping entry: % (User does not exist)', _mark;
                CONTINUE;
            END IF;

            _totalMarksObtained := (_mark->>'theoryMarksObtained')::NUMERIC(5, 2) + (_mark->>'practicalMarksObtained')::NUMERIC(5, 2);

            SELECT COALESCE(total_marks, 0)
            INTO _subjectTotalMarksForGivenExam
            FROM exams
            WHERE id = (_mark->>'id')::INT;

            _gradePoint := (_totalMarksObtained / _subjectTotalMarksForGivenExam ) * 4;

            UPDATE marks
            SET theory_marks_obtained = (_mark->>'theoryMarksObtained')::NUMERIC(5, 2),
                practical_marks_obtained = (_mark->>'practicalMarksObtained')::NUMERIC(5, 2),
                total_marks_obtained = _totalMarksObtained,
                grade = _gradePoint,
                updated_date = NOW()
            WHERE id = (_mark->>'id')::INT AND school_id = _schoolId;
        END LOOP;

        RETURN QUERY
        SELECT true, 'Mark detail updated successsfully', NULL::TEXT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT false, 'Unable to ' || _operationTypeDescription || ' mark detail', SQLERRM;
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
    _schoolId INTEGER;
    _initiator INT;
    _invoices JSONB;
    _discountAmt NUMERIC(10, 2);
    _invoiceUserId INTEGER;
    _items JSONB;
    _newInvoiceNumber JSONB;
    _newInvoiceId INTEGER;
    _invoiceItemId INTEGER;
    _invoiceAmount NUMERIC(10, 2) DEFAULT 0;
    _invoiceOutstandingAmt NUMERIC(10, 2) DEFAULT 0;
    _invoiceDiscount NUMERIC(10, 2) DEFAULT 0;
    _invoiceItemFeeStructureId INTEGER;
    _invoiceItemFeeAmt NUMERIC(10, 2) DEFAULT 0;
    _invoiceItemDiscountAmt NUMERIC(10, 2) DEFAULT 0;
    _invoice JSONB;
    _item JSONB;
    _activeAcademicYearId INTEGER;
    _activeFiscalYearId INTEGER;
    _academicPeriodId INTEGER;
    _maxPeriodId INTEGER;
    _maxPeriodInvoiceStatus VARCHAR(15);
BEGIN
    _schoolId := (payload->>'schoolId')::INT;
    _invoices := (payload->>'action')::JSONB;
    _initiator := (payload->>'initiator')::JSONB;
    _academicPeriodId := (payload->>'academicPeriodId')::JSONB;

    SELECT id
    INTO _activeFiscalYearId
    FROM fiscal_years
    WHERE school_id = _schoolId AND is_active = true;

    SELECT id
    INTO _activeAcademicYearId
    FROM academic_years
    WHERE school_id = _schoolId AND is_active = true;

    IF _activeFiscalYearId IS NULL OR _activeAcademicYearId IS NULL THEN
        RETURN QUERY
        SELECT false, 'Denied. Either Fiscal year or Academic year is not setup properly.', NULL::TEXT;
    END IF;

    FOR _invoice IN (SELECT * FROM _invoices)
    LOOP
        _invoiceUserId := _invoice->>'userId';
        _items := _invoice->>'items';

        -- validate user existence
        IF NOT EXISTS(SELECT 1 FROM users WHERE id = _invoiceUserId AND school_id = _schoolId) THEN
            RAISE NOTICE 'Invalid user_id (%) for invoice', _invoiceUserId;
            CONTINUE;
        END IF;

        SELECT COALESCE(academic_period_id, 0), status
        INTO _maxPeriodId, _maxPeriodInvoiceStatus
        FROM invoices
        WHERE school_id = _schoolId
            AND user_id = _invoiceUserId
            AND academic_year_id = _activeAcademicYearId
        ORDER BY academic_period_id DESC
        LIMIT 1;

        IF (_academicPeriodId < _maxPeriodId) OR
            (_academicPeriodId = _maxPeriodId AND _maxPeriodInvoiceStatus != 'CANCELLED')
        THEN
            RAISE NOTICE 'Denied. Invoice already generated for given period.';
            CONTINUE;
        END IF;

        IF _maxPeriodId - _academicPeriodId != 1 THEN
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
            _schoolId,
            _activeAcademicYearId,
            _activeFiscalYearId,
            _academicPeriodId,
            _initiator,
            _invoice->>'description',
            _invoiceUserId,
            _invoice->>'dueDate',
            'ISSUED'
        ) RETURNING id INTO _newInvoiceId;

        -- insert invoice items
        FOR _item IN (SELECT * FROM _items)
        LOOP
            SELECT fee_structure_id, amount, discounted_amt
            INTO _invoiceItemFeeStructureId, _invoiceItemFeeAmt, _invoiceDiscount
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
                _schoolId,
                _newInvoiceId,
                _invoiceItemFeeStructureId,
                _item->>'studentFeeId',
                _item->>'description',
                _invoiceItemFeeAmt,
                _item->>'quantity',
                (_item->>'quantity') * _invoiceItemFeeAmt - _invoiceItemDiscountAmt,
                _invoiceItemDiscountAmt * (_item->>'quantity')::INTEGER
            );
        END LOOP;

        -- generate invoice number
        _newInvoiceNumber := CONCAT(
            'INV-',
            TO_CHAR(CURRENT_DATE, 'YYYYMM'),
            '-', _newInvoiceId,
            '-', _schoolId
        );

        SELECT COALESCE(SUM(total_amount), 0)
        FROM invoice_items
        WHERE invoice_id = _newInvoiceId
        INTO _invoiceAmount;

        SELECT COALESCE(SUM(total_discount), 0)
        FROM invoice_items
        WHERE invoice_id = _newInvoiceId
        INTO _invoiceDiscount;

        _invoiceOutstandingAmt := _invoiceAmount - _invoiceDiscount;

        -- update invoice number and amount
        UPDATE invoices SET
            invoice_number = _newInvoiceNumber,
            amount = _invoiceOutstandingAmt,
            outstanding_amt = _invoiceOutstandingAmt
        WHERE id = _newInvoiceId;
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
    _schoolId INTEGER;
    _invoiceId INTEGER;
    _paymentAmount NUMERIC(10, 2) DEFAULT 0;
    _invoiceStatus VARCHAR(15);
    _invoiceOutstandingAmt NUMERIC(10, 2);
    _creditAmt NUMERIC(10, 2);
    _finalOutstandingAmt NUMERIC(10, 2);
    _finalInvoiceStatus VARCHAR(15);
    _invoiceUserId INTEGER;
    _initiator INTEGER;
    _paymentMethod INTEGER;
    _activeFiscalYearId INTEGER;
    _activeAcademicYearId INTEGER;
BEGIN
    _schoolId := (payload->>'schoolId');
    _invoiceId := (payload->>'invoiceId');
    _paymentAmount := (payload->>'paymentAmount')::NUMERIC(10, 2);
    _initiator := (payload->>'initiator');
    _paymentMethod := (payload->>'paymentMethod');

    SELECT id
    INTO _activeFiscalYearId
    FROM fiscal_years
    WHERE school_id = _schoolId AND is_active = true;

    SELECT id
    INTO _activeAcademicYearId
    FROM academic_years
    WHERE school_id = _schoolId AND is_active = true;

    IF _activeFiscalYearId IS NULL OR _activeAcademicYearId IS NULL THEN
        RETURN QUERY
        SELECT false, 'Denied. Either Fiscal year or Academic year is not setup properly.', NULL::TEXT;
    END IF;

    IF NOT EXISTS(SELECT 1 FROM invoices WHERE school_id = _schoolId AND id = _invoiceId) THEN
        RETURN QUERY
        SELECT false, 'Invoice does not exist', NULL::TEXT;
    END IF;

    SELECT COALESCE(outstanding_amt, 0), user_id, status
    INTO _invoiceOutstandingAmt, _invoiceUserId, _invoiceStatus
    FROM invoices WHERE id = _invoiceId;

    IF _invoiceStatus IS NULL OR _invoiceStatus NOT IN ('ISSUED', 'PARTIALLY_PAID') THEN
        RETURN QUERY
        SELECT
            false,
            'Payment Denied.  Invoice status should be either ''ISSUED'' or ''PARTIALLY_PAID'', but it is: %' || _invoiceStatus,
            NULL::TEXT;
    END IF;

    IF _paymentAmount > _invoiceOutstandingAmt THEN
        _finalOutstandingAmt := 0;
        _finalInvoiceStatus := 'PAID';
        _creditAmt := _paymentAmount - _invoiceOutstandingAmt;
    ELSIF _paymentAmount = _invoiceOutstandingAmt THEN
        _finalOutstandingAmt := 0;
        _finalInvoiceStatus := 'PAID';
        _creditAmt := 0;
    ELSE
        _finalOutstandingAmt := _invoiceOutstandingAmt - _paymentAmount;
        _finalInvoiceStatus := 'PARTIALLY_PAID';
        _creditAmt := 0;
    END IF;

    UPDATE invoices
    SET
        paid_amt = COALESCE(paid_amt, 0) + _paymentAmount,
        outstanding_amt = _finalOutstandingAmt,
        status = _finalInvoiceStatus
    WHERE id = _invoiceId;

    INSERT INTO transactions(school_id, academic_year_id, fiscal_year_id, user_id, initiator, type, status, invoice_id, amount, payment_method)
    VALUES(_schoolId, _activeAcademicYearId, _activeFiscalYearId, _invoiceUserId, _initiator, 'CREDIT', 'SUCCESS', _invoiceId, _paymentAmount, _paymentMethod);

    IF _creditAmt > 0 THEN
        INSERT INTO credits(school_id, user_id, amount)
        VALUES(_schoolId, _invoiceUserId, _creditAmt)
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
    _schoolId INTEGER;
    _refundAmt NUMERIC(10, 2);
    _invoiceId INTEGER;
    _invoiceStatus VARCHAR(15);
    _invoicePaidAmt NUMERIC(10, 2);
    _invoiceUserId INTEGER;
    _initiator INTEGER;
    _refundMethod INTEGER;
BEGIN
    _schoolId := (payload->>'schoolId');
    _refundAmt := COALESCE((payload->>'refundAmt')::NUMERIC(10, 2), 0);
    _invoiceId := (payload->>'invoiceId');
    _initiator := (payload->>'initiator');
    _refundMethod := (payload->>'refundMethod');

    IF NOT EXISTS(SELECT 1 FROM invoices WHERE school_id = _schoolId AND id = _invoiceId) THEN
        RETURN QUERY
        SELECT false, 'Invoice does not exist', NULL:: TEXT;
    END IF;

    SELECT status, COALESCE(paid_amt, 0), user_id
    INTO _invoiceStatus, _invoicePaidAmt, _invoiceUserId
    FROM invoices
    WHERE school_id = _schoolId AND id = _invoiceId;

    IF _invoiceStatus != 'PAID' OR _refundAmt IS NULL THEN
        RETURN QUERY
        SELECT
            false,
            'Refund denied. Invoice must be ''PAID'' for refund process',
            NULL:: TEXT;
    END IF;

    IF _refundAmt > _invoicePaidAmt THEN
        RETURN QUERY
        SELECT
            false,
            'Refund denied. Refund amount can not be greater than paid invoice paid amount.',
            NULL::TEXT;
    END IF;

    UPDATE invoices
    SET
        refunded_amt = COALESCE(refunded_amt, 0) + _refundAmt,
        status = 'REFUNDED',
        updated_date  = NOW()
    WHERE school_id = _schoolId AND id = _invoiceId;

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
    _feeDetails JSONB;
    _item JSONB;
    _schoolId INTEGER;
    _initiator INTEGER;
    _studentId INTEGER;
    _activeAcademicYearId INTEGER;
    _activeFiscalYearId INTEGER;
BEGIN
    _schoolId := (payload->>'schoolId');
    _initiator := (payload->>'initiator');
    _studentId := (payload->>'studentId');
    _feeDetails := (payload->>'feeDetails');

    SELECT id
    INTO _activeAcademicYearId
    FROM academic_years
    WHERE school_id = _schoolId AND is_active = TRUE;

    SELECT id
    INTO _activeFiscalYearId
    FROM fiscal_years
    WHERE school_id = _schoolId AND is_active = TRUE;

    IF _activeAcademicYearId IS NULL OR _activeFiscalYearId IS NULL THEN
        RETURN QUERY
        SELECT false, 'Denied. Either Fiscal year or Academic year is not setup properly.', NULL::TEXT;
    END IF;

    FOR _item IN (SELECT * FROM _feeDetails)
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
            _schoolId,
            _activeAcademicYearId,
            _activeFiscalYearId,
            _studentId,
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
    _schoolId INTEGER;
    _academicPeriodId INTEGER;
    _academicLevelId INTEGER;
    _deletedOrderId INTEGER;
BEGIN
    _schoolId := (payload->>'schoolId');
    _academicPeriodId := (payload->>'academicPeriodId');

    IF NOT EXISTS(SELECT 1 FROM academic_periods WHERE school_id = _schoolId AND id = _academicPeriodId) THEN
        RETURN QUERY
        SELECT false, 'Period does not exist', NULL::TEXT;
    END IF;

    SELECT academic_level_id INTO _academicLevelId
    FROM academic_periods
    WHERE school_id = _schoolId AND id = _academicPeriodId;

    DELETE FROM academic_periods
    WHERE school_id = _schoolId AND id = _academicPeriodId
    RETURNING order_id INTO _deletedOrderId;

    IF NOT EXISTS(
        SELECT 1 FROM academic_periods
        WHERE school_id = _schoolId
            AND academic_level_id = _academicLevelId
            AND order_id > _deletedOrderId
    ) THEN
        RETURN QUERY
        SELECT true, 'Period deleted successfully', NULL::TEXT;
    END IF;


    UPDATE academic_periods
    SET order_id = -order_id
    WHERE school_id = _schoolId
        AND academic_level_id = _academicLevelId
        AND order_id > _deletedOrderId;    

    UPDATE academic_periods
    SET order_id = ABS(order_id) - 1
    WHERE school_id = _schoolId
        AND academic_level_id = _academicLevelId
        AND order_id < 0;
    
    RETURN QUERY
    SELECT true, 'Period deleted successfully', NULL::TEXT;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT false, 'Unable to delete period', SQLERRM::TEXT;
END
$BODY$;
