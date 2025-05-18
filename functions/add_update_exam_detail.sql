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