DROP FUNCTION IF EXISTS public.get_admin_dashboard_data(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION get_admin_dashboard_data(_school_id INTEGER, _user_id INTEGER)
RETURNS JSONB
LANGUAGE plpgsql
AS $BODY$
DECLARE
    _student_count_total INTEGER;
    _student_count_previous_year INTEGER;
    _student_value_comparison INTEGER;
    _student_perc_comparison FLOAT;

    _teacher_count_total INTEGER;
    _teacher_count_previous_year INTEGER;
    _teacher_value_comparison INTEGER;
    _teacher_perc_comparison FLOAT;

    _parent_count_total INTEGER;
    _parent_count_previous_year INTEGER;
    _parent_value_comparison INTEGER;
    _parent_perc_comparison FLOAT;

    _notice_data JSONB;
    _celebration_data JSONB;
    _one_month_leave_data JSONB;

    _filter_approved_notice boolean DEFAULT true;
    _notice_filter_limit INTEGER DEFAULT 5;
BEGIN
    PERFORM 1 FROM users WHERE school_id = _school_id AND id = _user_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'User not found';
    END IF;

    --student
    SELECT COUNT(*)
    INTO _student_count_total
    FROM users t1
    JOIN user_profiles t2 ON t2.user_id = t1.id
    JOIN roles t3 ON t3.id = t1.role_id
    WHERE t3.static_role = 'STUDENT'
        AND t1.school_id = _school_id;

    SELECT COUNT(*)
    INTO _student_count_previous_year
    FROM users t1
    JOIN user_profiles t2 ON t2.user_id = t1.id
    JOIN roles t3 ON t3.id = t1.role_id
    WHERE t3.static_role = 'STUDENT'
        AND t1.school_id = _school_id
        AND EXTRACT(YEAR FROM t2.join_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1;

    _student_value_comparison := _student_count_total - _student_count_previous_year;
    IF _student_count_previous_year = 0 THEN
        _student_perc_comparison := 0;
    ELSE
        _student_perc_comparison := (_student_value_comparison::FLOAT / _student_count_previous_year) * 100;
    END IF;

    --teacher
    SELECT COUNT(*)
    INTO _teacher_count_total
    FROM users t1
    JOIN user_profiles t2 ON t2.user_id = t1.id
    JOIN roles t3 ON t3.id = t1.role_id
    WHERE t3.static_role = 'TEACHER'
        AND t1.school_id = _school_id;

    SELECT COUNT(*)
    INTO _teacher_count_previous_year
    FROM users t1
    JOIN user_profiles t2 ON t2.user_id = t1.id
    JOIN roles t3 ON t3.id = t1.role_id
    WHERE t3.static_role = 'TEACHER'
        AND t1.school_id = _school_id
        AND EXTRACT(YEAR FROM t2.join_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1;

    _teacher_value_comparison := _teacher_count_total - _teacher_count_previous_year;
    IF _teacher_count_previous_year = 0 THEN
        _teacher_perc_comparison := 0;
    ELSE
        _teacher_perc_comparison := (_teacher_value_comparison::FLOAT / _teacher_count_previous_year) * 100;
    END IF;

    --parents
    SELECT COUNT(*)
    INTO _parent_count_total
    FROM users t1
    JOIN user_profiles t2 ON t2.user_id = t1.id
    JOIN roles t3 ON t3.id = t1.role_id
    WHERE t3.static_role = 'PARENT'
        AND t1.school_id = _school_id;

    SELECT COUNT(*)
    INTO _parent_count_previous_year
    FROM users t1
    JOIN user_profiles t2 ON t2.user_id = t1.id
    JOIN roles t3 ON t3.id = t1.role_id
    WHERE t3.static_role = 'PARENT'
        AND t1.school_id = _school_id
        AND EXTRACT(YEAR FROM t2.join_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1;

    _parent_value_comparison := _parent_count_total - _parent_count_previous_year;
    IF _parent_count_previous_year = 0 THEN
        _parent_perc_comparison := 0;
    ELSE
        _parent_perc_comparison := (_parent_value_comparison::FLOAT / _parent_count_previous_year) * 100;
    END IF;


    SELECT COALESCE(JSON_AGG(row_to_json(t)), '[]'::json) INTO _notice_data
    FROM get_notices(
        _user_id => _user_id,
        _filter_limit => _notice_filter_limit,
        _filter_approved_notice => _filter_approved_notice
    ) AS t;

    SELECT COALESCE(JSON_AGG(row_to_json(t)), '[]'::json) INTO _celebration_data
    FROM public.get_celebrations(_school_id) AS t;

    SELECT COALESCE(JSON_AGG(row_to_json(t)), '[]'::json) INTO _one_month_leave_data
    FROM public.get_users_out_this_month(_school_id) AS t;

    -- build and return the final JSON object
    RETURN JSON_BUILD_OBJECT(
        'students', JSON_BUILD_OBJECT(
            'totalCount', _student_count_total,
            'totalCountPreviousYear', _student_count_previous_year,
            'percentDifference', _student_perc_comparison
        ),
        'teachers', JSON_BUILD_OBJECT(
            'totalCount', _teacher_count_total,
            'totalCountPreviousYear', _teacher_count_previous_year,
            'percentDifference', _teacher_perc_comparison
        ),
        'parents', JSON_BUILD_OBJECT(
            'totalCount', _parent_count_total,
            'totalCountPreviousYear', _parent_count_previous_year,
            'percentDifference', _parent_perc_comparison
        ),
        'notices', _notice_data,
        'celebrations', _celebration_data,
        'oneMonthLeave', _one_month_leave_data
    );
END;
$BODY$;
