DROP FUNCTION IF EXISTS public.get_users_out_this_month(int);

CREATE OR REPLACE FUNCTION public.get_users_out_this_month(_school_id INT)
RETURNS TABLE(
    id INT,
    policy VARCHAR(50),
    "policyId" INT,
    "fromDate" DATE,
    "toDate" DATE,
    note VARCHAR(100),
    "statusId" VARCHAR(30),
    status TEXT,
    "submittedDate" TIMESTAMP,
    "updatedDate" TIMESTAMP,
    "reviewedDate" TIMESTAMP,
    reviewer VARCHAR(100),
    "user" VARCHAR(100),
    "reviewerNote" VARCHAR(100),
    duration NUMERIC
)
LANGUAGE plpgsql
AS $BODY$
BEGIN
    RETURN QUERY
    WITH _month_dates AS (
        SELECT 
        DATE_TRUNC('month', NOW())::DATE AS month_start_date,
        (DATE_TRUNC('month', NOW()) + INTERVAL '1 month' - INTERVAL '1 microsecond')::DATE AS month_end_date
    )
    SELECT
        t1.id,
        t2.name AS policy,
        t1.leave_policy_id AS "policyId",
        t1.from_date AS "fromDate",
        t1.to_date AS "toDate",
        t1.note,
        t1.leave_status_code AS "statusId",
        'APPROVED' AS status,
        t1.submitted_date AS "submittedDate",
        t1.updated_date AS "updatedDate",
        t1.reviewed_date AS "reviewedDate",
        t3.name AS reviewer,
        t4.name AS user,
        t1.reviewer_note AS "reviewerNote",
        EXTRACT(DAY FROM age(t1.to_date + INTERVAL '1 day', t1.from_date)) AS duration
    FROM user_leaves t1
    JOIN leave_policies t2 ON t2.id = t1.leave_policy_id
    JOIN users t3 ON t3.id = t1.reviewer_id
    JOIN users t4 ON t4.id = t1.user_id
    JOIN _month_dates t5
    ON
        t1.from_date <= t5.month_end_date
        AND t1.to_date >= t5.month_start_date
    WHERE t1.leave_status_code = 'APPROVED' AND t1.school_id = _school_id
    LIMIT 5;
END
$BODY$;