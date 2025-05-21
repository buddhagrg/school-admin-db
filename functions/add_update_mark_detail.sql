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
        SELECT false, 'Denied. Academic year is not setup properly.', NULL::TEXT;
        RETURN;
    END IF;

    IF NOT EXISTS(SELECT 1 FROM exams WHERE id = _exam_id) THEN
        RETURN QUERY
        SELECT false, 'Exam does not exist', NULL::TEXT;
        RETURN;
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
        RETURN;
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