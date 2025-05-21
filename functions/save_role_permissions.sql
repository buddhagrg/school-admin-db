DROP FUNCTION IF EXISTS save_role_permissions(int, int, jsonb);
CREATE OR REPLACE FUNCTION save_role_permissions(_school_id INT, _role_id INT, _data JSONB)
RETURNS TABLE(status boolean, message TEXT, description TEXT)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    _parent_id INT;
    _parent_permission_type VARCHAR;
    _parent_permission_path VARCHAR;
    _permission_obj JSONB;
    _sub_permission_id INT;
    _sub_permission_type VARCHAR;
BEGIN
    IF (SELECT static_role FROM roles WHERE school_id = _school_id AND id = _role_id) = 'ADMIN' THEN
        RETURN QUERY
        SELECT false, 'Permissions for admin role cannot be assigned because admin always has full access to all permissions.', NULL::TEXT;
        RETURN;
    END IF;

    DELETE FROM role_permissions
    WHERE school_id = _school_id AND role_id = _role_id;

    FOR _permission_obj IN SELECT jsonb_array_elements(_data) LOOP
        _parent_id := (_permission_obj ->> 'id')::INT;

        PERFORM 1 FROM permissions WHERE id = _parent_id AND (parent_path IS NULL OR parent_path = '');
        IF NOT FOUND THEN
            CONTINUE;
        END IF;

        SELECT path, type INTO _parent_permission_path, _parent_permission_type
        FROM permissions WHERE id = _parent_id;

        INSERT INTO role_permissions(school_id, role_id, permission_id, type)
        VALUES(_school_id, _role_id, _parent_id, _parent_permission_type);

        FOR _sub_permission_id IN SELECT jsonb_array_elements_text(_permission_obj -> 'subPermissions')::INT LOOP
            PERFORM 1 FROM permissions WHERE id = _sub_permission_id AND parent_path = _parent_permission_path;
            IF NOT FOUND THEN
                CONTINUE;
            END IF;

            SELECT type INTO _sub_permission_type FROM permissions WHERE id = _sub_permission_id;

            INSERT INTO role_permissions(school_id, role_id, permission_id, type)
            VALUES(_school_id, _role_id, _sub_permission_id, _sub_permission_type);
        END LOOP;
    END LOOP;

    RETURN QUERY
    SELECT true, 'Role permissions saved successfully', NULL::TEXT;
    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT false, 'Unable to save role permissions', SQLERRM::TEXT;
END
$BODY$;