INSERT INTO permissions(
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
('Dashoard', '', NULL, NULL, 1, 'menu', NULL, '2'),
('Get dashboard data', 'api/v1/dashboard', NULL, '', NULL, 'api', 'GET', '2'),

('Academic Structure', 'academic_parent', NULL, NULL, 2, 'menu', NULL, '2'),
('Manage Levels & Periods', 'academic/levels/periods', NULL, 'academic_parent', 1, 'menu-screen', NULL, '2'),
('Manage Level Classes', 'academic/levels/classes', NULL, 'academic_parent', 2, 'menu-screen', NULL, '2'),
('Define Period Dates', 'academic/periods/dates', NULL, 'academic_parent', 3, 'menu-screen', NULL, '2'),
('Academic Years', 'academic/years', NULL, 'academic_parent', 4, 'menu-screen', NULL, '2'),
('Get all academic levels with periods', 'api/v1/academic/levels/periods', NULL, 'academic_parent', NULL, 'api', 'GET', '2'),
('Reorder periods of academic level', 'api/v1/academic/levels/:id/periods/reorder', NULL, 'academic_parent', NULL, 'api', 'PUT', '2'),
('Get all academic levels', 'api/v1/academic/levels', NULL, 'academic_parent', NULL, 'api', 'GET', '2'),
('Edit academic level', 'api/v1/academic/levels/:id', NULL, 'academic_parent', NULL, 'api', 'PUT', '2'),
('Delete academic level', 'api/v1/academic/levels/:id', NULL, 'academic_parent', NULL, 'api', 'DELETE', '2'),
('Get all academic periods', 'api/v1/academic/periods', NULL, 'academic_parent', NULL, 'api', 'GET', '2'),
('Add academic period', 'api/v1/academic/levels/:id/periods', NULL, 'academic_parent', NULL, 'api', 'POST', '2'),
('Edit academic period', 'api/v1/academic/periods/:id', NULL, 'academic_parent', NULL, 'api', 'PUT', '2'),
('Delete academic period', 'api/v1/academic/periods/:id', NULL, 'academic_parent', NULL, 'api', 'DELETE', '2'),
('Get all levels with classes', 'api/v1/academic/levels/classes', NULL, 'academic_parent', NULL, 'api', 'GET', '2'),
('Link class to level', 'api/v1/academic/levels/:id/classes', NULL, 'academic_parent', NULL, 'api', 'PUT', '2'),
('Delete class from level', 'api/v1/academic/levels/:id/classes', NULL, 'academic_parent', NULL, 'api', 'DELETE', '2'),
('Get all academic periods with dates', 'api/v1/academic/levels/:id/periods/dates', NULL, 'academic_parent', NULL, 'api', 'GET', '2'),
('Define periods dates', 'api/v1/academic/periods/dates', NULL, 'academic_parent', NULL, 'api', 'POST', '2'),

('Class Management', 'class_mgmt_parent', NULL, NULL, 3, 'menu', NULL, '2'),
('Manage Classes', 'classes/sections', NULL, 'class_mgmt_parent', 1, 'menu-screen', NULL, '2'),
('Manage Class teachers', 'classes/teachers', NULL, 'class_mgmt_parent', 2, 'menu-screen', NULL, '2'),
('Get all classes with sections', 'api/v1/classes/sections', NULL, 'class_mgmt_parent', NULL, 'api', 'GET', '2'),
('Get all classes', 'api/v1/classes', NULL, 'class_mgmt_parent', NULL, 'api', 'GET', '2'),
('Add new class', 'api/v1/classes', NULL, 'class_mgmt_parent', NULL, 'api', 'POST', '2'),
('Edit class', 'api/v1/classes/:id', NULL, 'class_mgmt_parent', NULL, 'api', 'PUT', '2'),
('Edit class status', 'api/v1/classes/:id/status', NULL, 'class_mgmt_parent', NULL, 'api', 'PATCH', '2'),
('Add new section', 'api/v1/classes/:id/sections', NULL, 'class_mgmt_parent', NULL, 'api', 'POST', '2'),
('Edit section', 'api/v1/classes/:id/sections/:sectionId', NULL, 'class_mgmt_parent', NULL, 'api', 'PUT', '2'),
('Edit section status', 'api/v1/classes/:id/sections/:sectionId/status', NULL, 'class_mgmt_parent', NULL, 'api', 'PATCH', '2'),
('Get classes with teacher', 'api/v1/classes/teachers', NULL, 'class_mgmt_parent', NULL, 'api', 'GET', '2'),
('Add class teacher', 'api/v1/classes/:id/teachers', NULL, 'class_mgmt_parent', NULL, 'api', 'PUT', '2'),
('Delete class teacher', 'api/v1/classes/:id/teachers/:teacherId', NULL, 'class_mgmt_parent', NULL, 'api', 'DELETE', '2'),

('User Management', 'user_mgmt_parent', NULL, NULL, 4, 'menu', NULL, '2'),
('Manage Roles & Permissions', 'users/roles-permissions', NULL, 'user_mgmt_parent', 1, 'menu-screen', NULL, '2'),
('Add New Student', 'users/students/add', NULL, 'user_mgmt_parent', 2, 'menu-screen', NULL, '2'),
('Add New Staff', 'users/staff/add', NULL, 'user_mgmt_parent', 3, 'menu-screen', NULL, '2'),
('Manage Users', 'users/manage', NULL, 'user_mgmt_parent', 4, 'menu-screen', NULL, '2'),
('View Student', 'users/students/:id', NULL, 'user_mgmt_parent', NULL, 'screen', NULL, '2'),
('Edit Student', 'users/students/edit/:id', NULL, 'user_mgmt_parent', NULL, 'screen', NULL, '2'),
('View Staff', 'users/staff/:id', NULL, 'user_mgmt_parent', NULL, 'screen', NULL, '2'),
('Edit Staff', 'users/staff/edit/:id', NULL, 'user_mgmt_parent', NULL, 'screen', NULL, '2'),
('Get all users', 'api/v1/users', NULL, 'user_mgmt_parent', NULL, 'api', 'GET', '2'),
('Edit user status', 'api/v1/users/:id/status', NULL, 'user_mgmt_parent', NULL, 'api', 'PATCH', '2'),
('Switch user role', 'api/v1/users/:id/switch-role', NULL, 'user_mgmt_parent', NULL, 'api', 'PATCH', '2'),
('Get all roles', 'api/v1/users/roles', NULL, 'user_mgmt_parent', NULL, 'api', 'GET', '2'),
('Add new role', 'api/v1/users/roles', NULL, 'user_mgmt_parent', NULL, 'api', 'POST', '2'),
('Edit role', 'api/v1/users/roles/:id', NULL, 'user_mgmt_parent', NULL, 'api', 'PUT', '2'),

('Edit role status', 'api/v1/roles/:id/status', NULL, 'user_mgmt_parent', NULL, 'api', 'PATCH', '2'),
('Get permissions of role', 'api/v1/roles/:id/permissions', NULL, 'user_mgmt_parent', NULL, 'api', 'GET', '2'),
('Add permissions to role', 'api/v1/roles/:id/permissions', NULL, 'user_mgmt_parent', NULL, 'api', 'POST', '2'),
('Delete permissions of role', 'api/v1/roles/:id/permissions', NULL, 'user_mgmt_parent', NULL, 'api', 'DELETE', '2'),
('Get users of role', 'api/v1/roles/:id/users', NULL, 'user_mgmt_parent', NULL, 'api', 'GET', '2'),
('Add new student', 'api/v1/students', NULL, 'user_mgmt_parent', NULL, 'api', 'POST', '2'),
('Get student', 'api/v1/students/:id', NULL, 'user_mgmt_parent', NULL, 'api', 'GET', '2'),
('Edit student', 'api/v1/students/:id', NULL, 'user_mgmt_parent', NULL, 'api', 'PUT', '2'),
--('Get fees due of student', 'api/v1/students/:id/fees/due', NULL, 'user_mgmt_parent', NULL, 'api', 'GET', '2'),
('Add new staff', 'api/v1/staff', NULL, 'user_mgmt_parent', NULL, 'api', 'POST', '2'),
('Get staff', 'api/v1/staff/:id', NULL, 'user_mgmt_parent', NULL, 'api', 'GET', '2'),
('Edit staff', 'api/v1/staff/:id', NULL, 'user_mgmt_parent', NULL, 'api', 'PUT', '2'),

('Leave Management', 'leave_mgmt_parent', NULL, NULL, 5, 'menu', NULL, '2'),
('Manage Leave Policies', 'leaves/policies', NULL, 'leave_mgmt_parent', 1, 'menu-screen', NULL, '2'),
('Approve/Reject Leave Request', 'leaves/review', NULL, 'leave_mgmt_parent', 2, 'menu-screen', NULL, '2'),
('Add leave policy', 'api/v1/leaves/policies', NULL, 'leave_mgmt_parent', NULL, 'api', 'POST', '2'),
('Get all leave policies', 'api/v1/leaves/policies', NULL, 'leave_mgmt_parent', NULL, 'api', 'GET', '2'),
('Get my leave policies', 'api/v1/leaves/policies/my', NULL, 'leave_mgmt_parent', NULL, 'api', 'GET', '2'),
('Edit leave policy', 'api/v1/leaves/policies/:id', NULL, 'leave_mgmt_parent', NULL, 'api', 'PUT', '2'),
('Edit leave policy status', 'api/v1/leaves/policies/:id/status', NULL, 'leave_mgmt_parent', NULL, 'api', 'PATCH', '2'),
('Add users to policy', 'api/v1/leaves/policies/:id/users', NULL, 'leave_mgmt_parent', NULL, 'api', 'PUT', '2'),
('Get policy users', 'api/v1/leaves/policies/:id/users', NULL, 'leave_mgmt_parent', NULL, 'api', 'GET', '2'),
('Remove user from policy', 'api/v1/leaves/policies/:id/users', NULL, 'leave_mgmt_parent', NULL, 'api', 'DELETE', '2'),
('Get eligible users for leave policy', 'api/v1/leaves/policies/eligible-users', NULL, 'leave_mgmt_parent', NULL, 'api', 'GET', '2'),
('Get leave request history', 'api/v1/leaves/requests', NULL, 'leave_mgmt_parent', NULL, 'api', 'GET', '2'),
('Create new leave request', 'api/v1/leaves/requests', NULL, 'leave_mgmt_parent', NULL, 'api', 'POST', '2'),
('Edit leave request', 'api/v1/leaves/requests/:id', NULL, 'leave_mgmt_parent', NULL, 'api', 'PUT', '2'),
('Delete leave request', 'api/v1/leaves/requests/:id', NULL, 'leave_mgmt_parent', NULL, 'api', 'DELETE', '2'),
('Edit leave request status', 'api/v1/leaves/requests/pending/:id/status', NULL, 'leave_mgmt_parent', NULL, 'api', 'PATCH', '2'),

('Notices & Announcements', 'notice_announcement_parent', NULL, NULL, 6, 'menu', NULL, '2'),
('View All Notices', 'notices', NULL, 'notice_announcement_parent', 1, 'menu-screen', NULL, '2'),
('Add Notice', 'notices/add', NULL, 'notice_announcement_parent', 2, 'menu-screen', NULL, '2'),
('Manage Pending Notices', 'notices/review', NULL, 'notice_announcement_parent', 3, 'menu-screen', NULL, '2'),
('View Notice', 'notices/:id', NULL, 'notice_announcement_parent', NULL, 'screen', NULL, '2'),
('Edit Notice', 'notices/edit/:id', NULL, 'notice_announcement_parent', NULL, 'screen', NULL, '2'),
('Get all approved notices', 'api/v1/notices', NULL, 'notice_announcement_parent', NULL, 'api', 'GET', '2'),
('Get all pending notices', 'api/v1/notices/pending', NULL, 'notice_announcement_parent', NULL, 'api', 'GET', '2'),
('Get notice recipients', 'api/v1/notices/recipients', NULL, 'notice_announcement_parent', NULL, 'api', 'GET', '2'),
('Edit notice status', 'api/v1/notices/:id/status', NULL, 'notice_announcement_parent', NULL, 'api', 'PATCH', '2'),
('Get notice', 'api/v1/notices/:id', NULL, 'notice_announcement_parent', NULL, 'api', 'GET', '2'),
('Add new notice', 'api/v1/notices', NULL, 'notice_announcement_parent', NULL, 'api', 'POST', '2'),
('Edit notice', 'api/v1/notices/:id', NULL, 'notice_announcement_parent', NULL, 'api', 'PUT', '2'),

('Manage Departments', 'departments', NULL, NULL, 7, 'menu', NULL, '2'),
('Get all departments', 'api/v1/departments', NULL, 'departments', NULL, 'api', 'GET', '2'),
('Add new department', 'api/v1/departments', NULL, 'departments', NULL, 'api', 'POST', '2'),
('Get department', 'api/v1/departments/:id', NULL, 'departments', NULL, 'api', 'GET', '2'),
('Edit department', 'api/v1/departments/:id', NULL, 'departments', NULL, 'api', 'PUT', '2'),
('Delete department', 'api/v1/departments/:id', NULL, 'departments', NULL, 'api', 'DELETE', '2'),

('Fee Management', 'fees_parent', NULL, NULL, 8, 'menu', NULL, '2'),
('Manage Fiscal Years', 'fiscal-years', NULL, 'fees_parent', 1, 'menu-screen', NULL, '2'),

('Attendance Management', 'attendance_parent', NULL, NULL, 9, 'menu', NULL, '2'),
('Record Staff Attendance', 'attendances/staff', NULL, 'attendance_parent', 1, 'menu-screen', NULL, '2'),
('Record Students Attendance', 'attendances/students', NULL, 'attendance_parent', 2, 'menu-screen', NULL, '2'),
('Get Students Attendance Record', 'attendances/students/record', NULL, 'attendance_parent', 3, 'menu-screen', NULL, '2'),
('Get Staff Attendance Record', 'attendances/staff/record', NULL, 'attendance_parent', 4, 'menu-screen', NULL, '2'),

('Settings', 'settings_parent', NULL, NULL, 10, 'menu', NULL, '2'),
('Configure School Setting', 'schools/configure', NULL, 'settings_parent', 1, 'menu-screen', NULL, '2'),
('Get school', 'api/v1/schools/:id', NULL, 'settings_parent', NULL, 'api', 'GET', '12'),
('Edit school', 'api/v1/schools/:id', NULL, 'settings_parent', NULL, 'api', 'PUT', '12'),

('Get my account detail', 'account', NULL, NULL, NULL, 'screen', NULL, '12'),
('Get teachers', 'api/v1/teachers', NULL, NULL, NULL, 'api', 'GET', '2'),
('Resend email verification', 'api/v1/auth/resend-email-verification', NULL, NULL, NULL, 'api', 'POST', '2'),
('Resend password setup link', 'api/v1/auth/resend-pwd-setup-link', NULL, NULL, NULL, 'api', 'POST', '2'),
('Reset password', 'api/v1/auth/reset-pwd', NULL, NULL, NULL, 'api', 'POST', '2'),

--super admin menus
('Super Admin Dashboard', '', NULL, NULL, NULL, 'screen', NULL, '1'),
('Schools', 'schools', 'school.svg', NULL, 1, 'menu-screen', NULL, '1'),
('Get All Schools', 'api/v1/schools', NULL, 'schools', NULL, 'api', 'GET', '1'),
('Add new school', 'api/v1/schools', NULL, 'schools', NULL, 'api', 'POST', '1'),
('Edit School', 'api/v1/schools/:id', NULL, 'schools', NULL, 'api', 'PUT', '1'),
('Delete School', 'api/v1/schools/:id', NULL, 'schools', NULL, 'api', 'DELETE', '1'),
('Permissions', 'permissions', 'role.svg', NULL, 2, 'menu-screen', NULL, '1'),
('Get all permissions', 'api/v1/permissions', NULL, 'permissions', NULL, 'api', 'GET', '1'),
('Add new permission', 'api/v1/permissions', NULL, 'permissions', NULL, 'api', 'POST', '1'),
('Edit permission', 'api/v1/permissions/:id', NULL, 'permissions', NULL, 'api', 'PUT', '1'),
('Delete permission', 'api/v1/permissions/:id', NULL, 'permissions', NULL, 'api', 'DELETE', '1')
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
INSERT INTO users(name, email, role_id, school_id, has_system_access, is_email_verified, password)
VALUES('Demo Super Admin', 'super-admin@school-admin.xyz', (SELECT currval('roles_id_seq')), -1, true, true, '$argon2id$v=19$m=65536,t=3,p=4$J3Wu/+7/M/6uYD9mM1qHUw$ifiXbdwBNzsBS2HKNteUtSkzFJk/92lQXFPAwObX+II');

-- school admin
INSERT INTO roles(static_role_id, name, is_editable, school_id)
VALUES(2, 'admin', false, -1)
RETURNING id;

-- plain_pwd=iamadmin
INSERT INTO users(name, email, role_id, school_id, has_system_access, is_email_verified, password)
VALUES('Demo School Admin', 'admin@school-admin.xyz', (SELECT currval('roles_id_seq')), -1, true, true, '$argon2id$v=19$m=65536,t=3,p=4$mZxqMB+b+KHqSa8apH8lkA$nAh/hjqfhY5AmNSsczjwl7gOOysBCyBGQoio9nwaJ1U');


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
    ('LP', 'Late Present'),
    ('AB', 'Absent'),
    ('EL', 'Early Leave');

INSERT INTO roles(static_role_id, name, is_editable, school_id)
VALUES
(3, 'Teacher', false, -1),
(4, 'Student', false, -1);