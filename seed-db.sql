INSERT INTO access_controls(
    name,
    path,
    icon,
    parent_path,
    hierarchy_id,
    type,
    method,
    direct_allowed_role_id
)
VALUES
('Dashoard', '', NULL, NULL, 1, 'menu-screen', NULL, '2'),
('Get dashboard data', 'api/v1/dashboard', NULL, '', NULL, 'api', 'GET', '2'),

('Academic Level & Period', 'academic_parent', NULL, NULL, 2, 'menu-screen', NULL, '2'),
('Manage Levels & Periods', 'academic/manage', NULL, 'academic_parent', 1, 'menu-screen', NULL, '2'),
('Manage Level Classes', 'academic/level-class', NULL, 'academic_parent', 2, 'menu-screen', NULL, '2'),
('Assign Period Date', 'academic/period-date', NULL, 'academic_parent', 3, 'menu-screen', NULL, '2'),

('Classes & Sections', 'classes_parent', NULL, NULL, 3, 'menu-screen', NULL, '2'),
('Manage Classes', 'classes/manage', NULL, 'classes_parent', 1, 'menu-screen', NULL, '2'),
('Assign Class teacher', 'classes/teachers', NULL, 'classes_parent', 2, 'menu-screen', NULL, '2'),
('Classes Edit', 'classes/edit/:id', NULL, 'classes', NULL, 'screen', NULL, '2'),
('Class Teachers Edit', 'class-teachers/edit/:id', NULL, 'class-teachers', NULL, 'screen', NULL, '2'),
('Section Edit', 'sections/edit/:id', NULL, 'sections', NULL, 'screen', NULL, '2'),
('Get all classes', 'api/v1/classes', NULL, 'classes', NULL, 'api', 'GET', '2'),
('Get class detail', 'api/v1/classes/:id', NULL, 'classes', NULL, 'api', 'GET', '2'),
('Add new class', 'api/v1/classes', NULL, 'classes', NULL, 'api', 'POST', '2'),
('Update class detail', 'api/v1/classes/:id', NULL, 'classes', NULL, 'api', 'PUT', '2'),
('Delete class', 'api/v1/classes/:id', NULL, 'classes', NULL, 'api', 'DELETE', '2'),
('Get class with teacher details', 'api/v1/class-teachers', NULL, 'class-teachers', NULL, 'api', 'GET', '2'),
('Add class teacher', 'api/v1/class-teachers', NULL, 'class-teachers', NULL, 'api', 'POST', '2'),
('Get class teacher detail', 'api/v1/class-teachers/:id', NULL, 'class-teachers', NULL, 'api', 'GET', '2'),
('Update class teacher detail', 'api/v1/class-teachers/:id', NULL, 'class-teachers', NULL, 'api', 'PUT', '2'),
('Get all sections', 'api/v1/sections', NULL, 'sections', NULL, 'api', 'GET', '2'),
('Add new section', 'api/v1/sections', NULL, 'sections', NULL, 'api', 'POST', '2'),
('Get section detail', 'api/v1/sections/:id', NULL, 'sections', NULL, 'api', 'GET', '2'),
('Update section detail', 'api/v1/sections/:id', NULL, 'sections', NULL, 'api', 'PUT', '2'),
('Delete section', 'api/v1/sections/:id', NULL, 'sections', NULL, 'api', 'DELETE', '2'),

('User Management', 'user_mgmt_parent', NULL, NULL, 4, 'menu-screen', NULL, '2'),
('Add User', 'users/add', NULL, 'user_mgmt_parent', 1, 'menu-screen', NULL, '2'),
('Manage Users', 'users/manage', NULL, 'user_mgmt_parent', 2, 'menu-screen', NULL, '2'),
('Assign Roles & Permissions', 'users/role-and-permission', NULL, 'user_mgmt_parent', 3, 'menu-screen', NULL, '2'),
('View Student', 'students/:id', NULL, 'students_parent', NULL, 'screen', NULL, '2'),
('Edit Student', 'students/edit/:id', NULL, 'students_parent', NULL, 'screen', NULL, '2'),
('View Staffs', 'staffs/:id', NULL, 'staffs_parent', NULL, 'screen', NULL, '2'),
('Edit Staff', 'staffs/edit/:id', NULL, 'staffs_parent', NULL, 'screen', NULL, '2'),
('Get students', 'api/v1/students', NULL, 'students_parent', NULL, 'api', 'GET', '2'),
('Add new student', 'api/v1/students', NULL, 'students_parent', NULL, 'api', 'POST', '2'),
('Get student detail', 'api/v1/students/:id', NULL, 'students_parent', NULL, 'api', 'GET', '2'),
('Handle student status', 'api/v1/students/:id/status', NULL, 'students_parent', NULL, 'api', 'POST', '2'),
('Update student detail', 'api/v1/students/:id', NULL, 'students_parent', NULL, 'api', 'PUT', '2'),
('Get all staffs', 'api/v1/staffs', NULL, 'staffs_parent', NULL, 'api', 'GET', '2'),
('Add new staff', 'api/v1/staffs', NULL, 'staffs_parent', NULL, 'api', 'POST', '2'),
('Get staff detail', 'api/v1/staffs/:id', NULL, 'staffs_parent', NULL, 'api', 'GET', '2'),
('Update staff detail', 'api/v1/staffs/:id', NULL, 'staffs_parent', NULL, 'api', 'PUT', '2'),
('Handle staff status', 'api/v1/staffs/:id/status', NULL, 'staffs_parent', NULL, 'api', 'POST', '2'),
('Get all roles', 'api/v1/roles', NULL, 'roles-and-permissions', NULL, 'api', 'GET', '2'),
('Add new role', 'api/v1/roles', NULL, 'roles-and-permissions', NULL, 'api', 'POST', '2'),
('Switch user role', 'api/v1/roles/switch', NULL, 'roles-and-permissions', NULL, 'api', 'POST', '2'),
('Update role', 'api/v1/roles/:id', NULL, 'roles-and-permissions', NULL, 'api', 'PUT', '2'),
('Handle role status', 'api/v1/roles/:id/status', NULL, 'roles-and-permissions', NULL, 'api', 'POST', '2'),
('Get role detail', 'api/v1/roles/:id', NULL, 'roles-and-permissions', NULL, 'api', 'GET', '2'),
('Get role permissions', 'api/v1/roles/:id/permissions', NULL, 'roles-and-permissions', NULL, 'api', 'GET', '2'),
('Add role permissions', 'api/v1/roles/:id/permissions', NULL, 'roles-and-permissions', NULL, 'api', 'POST', '2'),
('Get role users', 'api/v1/roles/:id/users', NULL, 'roles-and-permissions', NULL, 'api', 'GET', '2'),

('Leave Management', 'leave_mgmt_parent', NULL, NULL, 5, 'menu-screen', NULL, '2'),
('Manage Leave Categories', 'leaves/manage', NULL, 'leave_mgmt_parent', 1, 'menu-screen', NULL, '2'),
('Approve/Reject Leave Request', 'leaves/review', NULL, 'leave_mgmt_parent', 2, 'menu-screen', NULL, '2'),
('Add leave policy', 'api/v1/leave/policies', NULL, 'leave_parent', NULL, 'api', 'POST', '2'),
('Get all leave policies', 'api/v1/leave/policies', NULL, 'leave_parent', NULL, 'api', 'GET', '2'),
('Get my leave policies', 'api/v1/leave/policies/me', NULL, 'leave_parent', NULL, 'api', 'GET', '2'),
('Update leave policy', 'api/v1/leave/policies/:id', NULL, 'leave_parent', NULL, 'api', 'PUT', '2'),
('Handle policy status', 'api/v1/leave/policies/:id/status', NULL, 'leave_parent', NULL, 'api', 'POST', '2'),
('Add user to policy', 'api/v1/leave/policies/:id/users', NULL, 'leave_parent', NULL, 'api', 'POST', '2'),
('Get policy users', 'api/v1/leave/policies/:id/users', NULL, 'leave_parent', NULL, 'api', 'GET', '2'),
('Remove user from policy', 'api/v1/leave/policies/:id/users', NULL, 'leave_parent', NULL, 'api', 'DELETE', '2'),
('Get policy eligible users', 'api/v1/leave/policies/eligible-users', NULL, 'leave_parent', NULL, 'api', 'GET', '2'),
('Get user leave history', 'api/v1/leave/request', NULL, 'leave_parent', NULL, 'api', 'GET', '2'),
('Create new leave request', 'api/v1/leave/request', NULL, 'leave_parent', NULL, 'api', 'POST', '2'),
('Update leave request', 'api/v1/leave/request/:id', NULL, 'leave_parent', NULL, 'api', 'PUT', '2'),
('Delete leave request', 'api/v1/leave/request/:id', NULL, 'leave_parent', NULL, 'api', 'DELETE', '2'),
('Get pending leave requests', 'api/v1/leave/pending', NULL, 'leave_parent', NULL, 'api', 'GET', '2'),
('Handle leave request status', 'api/v1/leave/pending/:id/status', NULL, 'leave_parent', NULL, 'api', 'POST', '2'),

('Notices & Announcements', 'notice_announcement_parent', NULL, NULL, 6, 'menu-screen', NULL, '2'),
('View All Notices', 'notices', NULL, 'notice_announcement_parent', 1, 'menu-screen', NULL, '2'),
('Add Notice', 'notices/add', NULL, 'notice_announcement_parent', 2, 'menu-screen', NULL, '2'),
('View Notice', 'notices/:id', NULL, 'notices_parent', NULL, 'screen', NULL, '2'),
('Edit Notice', 'notices/edit/:id', NULL, 'notices_parent', NULL, 'screen', NULL, '2'),
('Get notice recipient list', 'api/v1/notices/recipients/list', NULL, 'notices_parent', NULL, 'api', 'GET', '2'),
('Handle notice status', 'api/v1/notices/:id/status', NULL, 'notices_parent', NULL, 'api', 'POST', '2'),
('Get notice detail', 'api/v1/notices/:id', NULL, 'notices_parent', NULL, 'api', 'GET', '2'),
('Get all notices', 'api/v1/notices', NULL, 'notices_parent', NULL, 'api', 'GET', '2'),
('Add new notice', 'api/v1/notices', NULL, 'notices_parent', NULL, 'api', 'POST', '2'),
('Update notice detail', 'api/v1/notices/:id', NULL, 'notices_parent', NULL, 'api', 'PUT', '2'),

('Settings', 'settings_parent', NULL, NULL, 7, 'menu-screen', NULL, '2'),
('Configure School Setting', 'school', NULL, 'settings_parent', 1, 'menu-screen', NULL, '2'),
('Manage Departments', 'departments', NULL, 'settings_parent', 2, 'menu-screen', NULL, '2'),
('Edit Department', 'departments/edit/:id', NULL, 'departments', NULL, 'screen', NULL, '2'),
('Get all departments', 'api/v1/departments', NULL, 'departments', NULL, 'api', 'GET', '2'),
('Add new department', 'api/v1/departments', NULL, 'departments', NULL, 'api', 'POST', '2'),
('Get department detail', 'api/v1/departments/:id', NULL, 'departments', NULL, 'api', 'GET', '2'),
('Update department detail', 'api/v1/departments/:id', NULL, 'departments', NULL, 'api', 'PUT', '2'),
('Delete department', 'api/v1/departments/:id', NULL, 'departments', NULL, 'api', 'DELETE', '2'),

('Get my account detail', 'account', NULL, NULL, NULL, 'screen', NULL, '12'),
('Get permissions', 'api/v1/permissions', NULL, NULL, NULL, 'api', 'GET', '2'),
('Get teachers', 'api/v1/teachers', NULL, NULL, NULL, 'api', 'GET', '2'),
('Resend email verification', 'api/v1/auth/resend-email-verification', NULL, NULL, NULL, 'api', 'POST', '2'),
('Resend password setup link', 'api/v1/auth/resend-pwd-setup-link', NULL, NULL, NULL, 'api', 'POST', '2'),
('Reset password', 'api/v1/auth/reset-pwd', NULL, NULL, NULL, 'api', 'POST', '2'),

('Super Admin Dashboard', '', NULL, NULL, NULL, 'screen', NULL, '1'),
('Schools', 'schools', 'school.svg', NULL, 1, 'menu-screen', NULL, '1'),
('Get All Schools', 'api/v1/schools', NULL, 'schools', NULL, 'api', 'GET', '1'),
('Add Schools', 'api/v1/schools', NULL, 'schools', NULL, 'api', 'POST', '1'),
('Update School', 'api/v1/schools/:id', NULL, 'schools', NULL, 'api', 'PUT', '1'),
('Update School screen', 'schools/edit/:id', NULL, 'schools', NULL, 'api', 'PUT', '1'),
('Delete School', 'api/v1/schools/:id', NULL, 'schools', NULL, 'api', 'DELETE', '1'),
('Access controls', 'access-controls', 'role.svg', NULL, 2, 'menu-screen', NULL, '1'),
('Get All access controls', 'api/v1/access-controls', NULL, 'access-controls', NULL, 'api', 'GET', '1'),
('Add access control', 'api/v1/access-controls', NULL, 'access-controls', NULL, 'api', 'POST', '1'),
('Update access control', 'api/v1/access-controls/:id', NULL, 'access-controls', NULL, 'api', 'PUT', '1'),
('Delete access control', 'api/v1/access-controls/:id', NULL, 'access-controls', NULL, 'api', 'DELETE', '1')
ON CONFLICT DO NOTHING;



ALTER SEQUENCE leave_status_id_seq RESTART WITH 1;
INSERT INTO leave_status (name) VALUES
('On Review'),
('Approved'),
('Cancelled');

ALTER SEQUENCE notice_status_id_seq RESTART WITH 1;
INSERT INTO notice_status (name, alias)
VALUES ('Draft', 'Draft'),
('Submit for Review', 'Approval Pending'),
('Submit for Deletion', 'Delete Pending'),
('Reject', 'Rejected'),
('Approve', 'Approved'),
('Delete', 'Deleted');

-- system super admin
INSERT INTO schools(name, email, school_id, is_active, is_email_verified)
VALUES('DEMO SCHOOL', 'demo-school@school-admin.xyz', -1, true, true);

INSERT INTO roles(static_role_id, name, is_editable, school_id)
VALUES(1, 'Super Admin', false, -1)
RETURNING id;

-- plain_pwd=iamsuperadmin
INSERT INTO users(name, email, role_id, school_id, is_active, is_email_verified, password)
VALUES('Super Admin', 'super-admin@school-admin.xyz', (SELECT currval('roles_id_seq')), -1, true, true, '$argon2id$v=19$m=65536,t=3,p=4$J3Wu/+7/M/6uYD9mM1qHUw$ifiXbdwBNzsBS2HKNteUtSkzFJk/92lQXFPAwObX+II');

-- school admin
INSERT INTO roles(static_role_id, name, is_editable, school_id)
VALUES(2, 'admin', false, -1)
RETURNING id;

-- plain_pwd=iamadmin
INSERT INTO users(name, email, role_id, school_id, is_active, is_email_verified, password)
VALUES('School Admin', 'admin@school-admin.xyz', (SELECT currval('roles_id_seq')), -1, true, true, '$argon2id$v=19$m=65536,t=3,p=4$mZxqMB+b+KHqSa8apH8lkA$nAh/hjqfhY5AmNSsczjwl7gOOysBCyBGQoio9nwaJ1U');


INSERT INTO invoice_status(code, name, description)
VALUES
    ('DRAFT', 'Create Invoice', 'Invoice Drafted'),
    ('ISSUED', 'Issue Invoice', 'Unpaid'),
    ('PAID', 'Receive Payment', 'Paid'),
    ('PARTIALLY_PAID', 'Receive Partial Payment', 'Partial Payment Received'),
    ('REFUNDED', 'Refund Invoice', 'Payment refunded to the payer.'),
    ('DISPUTED', 'Raise Dispute', 'Dispute Raised'),
    ('CANCELLED', ' Cancel Invoice', 'Invoice Cancelled');

INSERT INTO attendance_status (code, description) 
VALUES
    ('PR', 'Present'),
    ('LA', 'Late'),
    ('AB', 'Absent'),
    ('PP', 'Partially Present');
