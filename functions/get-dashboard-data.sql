DROP FUNCTION IF EXISTS public.get_admin_dashboard_data(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION get_admin_dashboard_data(_school_id INTEGER, _user_id INTEGER)
RETURNS JSONB
LANGUAGE plpgsql
AS $BODY$
DECLARE
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

    SELECT COALESCE(JSON_AGG(row_to_json(t)), '[]'::json) INTO _notice_data
    FROM get_notices(
        _user_id => _user_id,
        _filter_approved_notice => _filter_approved_notice,
        _filter_limit => _notice_filter_limit
    ) AS t;

    SELECT COALESCE(JSON_AGG(row_to_json(t)), '[]'::json) INTO _celebration_data
    FROM public.get_celebrations(_school_id) AS t;

    SELECT COALESCE(JSON_AGG(row_to_json(t)), '[]'::json) INTO _one_month_leave_data
    FROM public.get_users_out_this_month(_school_id) AS t;

    -- build and return the final JSON object
    RETURN JSON_BUILD_OBJECT(
        'notices', _notice_data,
        'celebrations', _celebration_data,
        'oneMonthLeave', _one_month_leave_data
    );
END;
$BODY$;
