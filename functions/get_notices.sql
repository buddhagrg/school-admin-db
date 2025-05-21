DROP FUNCTION IF EXISTS public.get_notices(INTEGER, INTEGER, VARCHAR, DATE, DATE, INTEGER, boolean);
CREATE OR REPLACE FUNCTION get_notices(
    _user_id INTEGER,
    _role_id INTEGER DEFAULT NULL,
    _status VARCHAR(30) DEFAULT NULL,
    _from_date DATE DEFAULT NULL,
    _to_date DATE DEFAULT NULL,
    _filter_limit INTEGER DEFAULT NULL,
    _filter_approved_notice boolean DEFAULT FALSE
)
RETURNS TABLE (
    id INTEGER,
    title VARCHAR(100),
    description VARCHAR(400),
    "recipientType" CHAR(2),
    "recipientRoleId" INT,
    "recipientFirstField" INT,
    "authorId" INTEGER,
    "publishedDate" TIMESTAMP,
    "createdDate" TIMESTAMP,
    "updatedDate" TIMESTAMP,
    author VARCHAR(100),
    "reviewerName" VARCHAR(100),
    "reviewedDate" TIMESTAMP,
    status VARCHAR(100),
    "statusId" VARCHAR(20),
    audience TEXT
)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _sql TEXT;
    _user_role_id INTEGER;
    _user_static_role VARCHAR;
    _user_school_id INTEGER;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM users u WHERE u.id = _user_id) THEN
        RAISE EXCEPTION 'User does not exist';
    END IF;

    SELECT u.school_id
    INTO _user_school_id
    FROM users u
    WHERE u.id = _user_id;
    IF _user_school_id IS NULL THEN
        RAISE EXCEPTION 'School does not exist';
    END IF;

    SELECT u.role_id
    INTO _user_role_id
    FROM users u
    WHERE u.id = _user_id;
    IF _user_role_id IS NULL THEN
        RAISE EXCEPTION 'User role does not exist';
    END IF;

    SELECT r.static_role
    INTO _user_static_role
    FROM roles r
    WHERE r.school_id = _user_school_id AND r.id = _user_role_id;
    IF _user_static_role IS NULL THEN
        RAISE EXCEPTION 'User static role does not exist';
    END IF;

    _sql := $sql$
        SELECT
            t1.id,
            t1.title,
            t1.description,
            t1.recipient_type AS "recipientType",
            t1.recipient_role_id AS "recipientRoleId",
            t1.recipient_first_field AS "recipientFirstField",
            t1.author_id AS "authorId",
            t1.published_date as "publishedDate",
            t1.created_date AS "createdDate",
            t1.updated_date AS "updatedDate",
            t2.name AS author,
            t4.name AS "reviewerName",
            t1.reviewed_date AS "reviewedDate",
            t3.name AS status,
            t1.notice_status_code AS "statusId",
            CASE
                WHEN t1.recipient_type = 'SP' THEN
                    CASE
                        WHEN t6.static_role = 'TEACHER' THEN
                            CASE
                                WHEN t1.recipient_first_field IS NULL THEN 'All Teachers'
                                ELSE 'Teachers from' || ' "' || COALESCE(t7.name, '') || '" ' || 'department'
                            END
                        WHEN t6.static_role = 'STUDENT' THEN
                            CASE
                                WHEN t1.recipient_first_field IS NULL THEN 'All Students'
                                ELSE 'Students from' || ' "' || COALESCE(t8.name, '') || '" ' || 'class'
                            END
                    ELSE 'Unknown Recipient'
                    END
            ELSE 'Everyone'
            END AS audience
        FROM notices t1
        JOIN users t2 ON t2.id = t1.author_id
        JOIN notice_status t3 ON t3.code = t1.notice_status_code
        LEFT JOIN users t4 ON t4.id = t1.reviewer_id
        LEFT JOIN roles t6 ON t6.id = t1.recipient_role_id
        LEFT JOIN departments t7 ON t7.id = t1.recipient_first_field
        LEFT JOIN classes t8 ON t8.id = t1.recipient_first_field
        WHERE
            ($6 IS NULL OR t1.notice_status_code = $6)
            AND(
                ($7 IS NULL AND $8 IS NULL)
                OR t1.created_date BETWEEN $7 AND $8
            )
            AND ($10 IS NULL OR t1.recipient_role_id = $10)
            AND t1.school_id = $1
            AND (
                $2 = 'ADMIN'
                AND (
                    $5 IS FALSE
                    OR t1.notice_status_code = 'PUBLISHED'
                )
                OR (
                    $2 != 'ADMIN'
                        AND (
                            t1.author_id = $3
                            OR (
                                t1.notice_status_code = 'PUBLISHED'
                                AND (
                                    t1.recipient_type = 'EV'
                                    OR (
                                        t1.recipient_type = 'SP'
                                        AND (
                                            (
                                                $2 = 'TEACHER'
                                                AND t6.static_role = 'TEACHER'
                                                AND (
                                                    t1.recipient_first_field IS NULL
                                                    OR EXISTS (
                                                        SELECT 1
                                                        FROM user_profiles u
                                                        JOIN users t5 ON t5.id = u.user_id
                                                        WHERE u.school_id = t1.school_id
                                                            AND u.department_id = t1.recipient_first_field
                                                            AND t5.id = $3
                                                            AND t5.role_id = $4
                                                    )
                                                )
                                            )
                                            OR (
                                                $2 = 'STUDENT'
                                                AND t6.static_role = 'STUDENT'
                                                AND (
                                                    t1.recipient_first_field IS NULL
                                                    OR EXISTS (
                                                        SELECT 1
                                                        FROM user_profiles u
                                                        JOIN users t5 ON t5.id = u.user_id
                                                        WHERE u.school_id = t1.school_id
                                                            AND u.class_id = t1.recipient_first_field
                                                            AND t5.id = $3
                                                            AND t5.role_id = $4
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
            $sql$;
        
        _sql := _sql || ' ORDER BY t1.created_date DESC ';
        IF $9 IS NOT NULL THEN
            _sql := _sql || ' LIMIT ' || $9;
        END IF;

        RETURN QUERY EXECUTE _sql USING
            _user_school_id,
            _user_static_role,
            _user_id,
            _user_role_id,
            _filter_approved_notice,
            _status,
            _from_date,
            _to_date,
            _filter_limit,
            _role_id;
END;
$BODY$;