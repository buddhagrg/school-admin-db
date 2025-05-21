DROP FUNCTION IF EXISTS public.get_user_leave_history(int, int);

CREATE OR REPLACE FUNCTION public.get_user_leave_history(_school_id INT, _user_id INT)
RETURNS TABLE(
    id INT,
    policy VARCHAR(50),
    "policyId" INT,
    "fromDate" DATE,
    "toDate" DATE,
    note VARCHAR(100),
    "statusId" VARCHAR(30),
    status VARCHAR(50),
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
    SELECT
        t1.id,
        t2.name,
        t1.leave_policy_id,
        t1.from_date,
        t1.to_date,
        t1.note,
        t1.leave_status_code,
        t3.name,
        t1.submitted_date,
        t1.updated_date,
        t1.reviewed_date,
        t4.name,
        t5.name,
        t1.reviewer_note,
        EXTRACT(DAY FROM age(t1.to_date + INTERVAL '1 day', t1.from_date))
    FROM user_leaves t1
    JOIN leave_policies t2 ON t2.id = t1.leave_policy_id
    JOIN leave_status t3 ON t3.code = t1.leave_status_code
    LEFT JOIN users t4 ON t4.id = t1.reviewer_id
    JOIN users t5 ON t5.id = t1.user_id
    WHERE t1.user_id = _user_id
        And t1.school_id = _school_id
    ORDER BY submitted_date DESC
    LIMIT 5;
END
$BODY$;