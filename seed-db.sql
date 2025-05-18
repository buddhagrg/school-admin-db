INSERT INTO permissions(
    name,
    path,
    icon,
    parent_path,
    hierarchy_id,
    type,
    method,
    direct_allowed_role
)
VALUES
('Dashboard', 'dashboard', NULL, NULL, 1, 'menu', NULL, 'ADMIN'),
('Get dashboard data', 'v1/dashboard', NULL, 'dashboard', NULL, 'api', 'GET', 'ADMIN'),

('Academic Structure', 'academic-structure', NULL, NULL, 2, 'menu', NULL, 'ADMIN'),
('Levels & Periods', 'academic-structure/levels-periods', NULL, 'academic-structure', 1, 'menu-screen', NULL, 'ADMIN'),
('Academic Years', 'academic-structure/years', NULL, 'academic-structure', 2, 'menu-screen', NULL, 'ADMIN'),
('Departments', 'academic-structure/departments', NULL, 'academic-structure', 3, 'menu-screen', NULL, 'ADMIN'),
('Reorder academic periods', 'v1/academic/levels/:id/periods/reorder', NULL, 'academic-structure', NULL, 'api', 'PUT', 'ADMIN'),
('Get all academic levels', 'v1/academic/levels', NULL, 'academic-structure', NULL, 'api', 'GET', 'ADMIN'),
('Edit academic level', 'v1/academic/levels/:id', NULL, 'academic-structure', NULL, 'api', 'PUT', 'ADMIN'),
('Delete academic level', 'v1/academic/levels/:id', NULL, 'academic-structure', NULL, 'api', 'DELETE', 'ADMIN'),
('Get all academic periods', 'v1/academic/levels/:id/periods', NULL, 'academic-structure', NULL, 'api', 'GET', 'ADMIN'),
('Add academic period', 'v1/academic/levels/:id/periods', NULL, 'academic-structure', NULL, 'api', 'POST', 'ADMIN'),
('Edit academic period', 'v1/academic/levels/:id/periods/:periodId', NULL, 'academic-structure', NULL, 'api', 'PUT', 'ADMIN'),
('Delete academic period', 'v1/academic/levels/:id/periods/:periodId', NULL, 'academic-structure', NULL, 'api', 'DELETE', 'ADMIN'),
('Get all departments', 'v1/departments', NULL, 'academic-structure', NULL, 'api', 'GET', 'ADMIN'),
('Add new department', 'v1/departments', NULL, 'academic-structure', NULL, 'api', 'POST', 'ADMIN'),
('Edit department', 'v1/departments/:id', NULL, 'academic-structure', NULL, 'api', 'PUT', 'ADMIN'),
('Delete department', 'v1/departments/:id', NULL, 'academic-structure', NULL, 'api', 'DELETE', 'ADMIN'),

('Class Management', 'class-management', NULL, NULL, 3, 'menu', NULL, 'ADMIN'),
('Classes & Sections', 'class-management/classes-sections', NULL, 'class-management', 1, 'menu-screen', NULL, 'ADMIN'),
('Class Teachers', 'class-management/classes-teachers', NULL, 'class-management', 2, 'menu-screen', NULL, 'ADMIN'),
('Get all classes with sections', 'v1/classes/sections', NULL, 'class-management', NULL, 'api', 'GET', 'ADMIN'),
('Get all classes', 'v1/classes', NULL, 'class-management', NULL, 'api', 'GET', 'ADMIN'),
('Add new class', 'v1/classes', NULL, 'class-management', NULL, 'api', 'POST', 'ADMIN'),
('Edit class', 'v1/classes/:id', NULL, 'class-management', NULL, 'api', 'PUT', 'ADMIN'),
('Add new section', 'v1/classes/:id/sections', NULL, 'class-management', NULL, 'api', 'POST', 'ADMIN'),
('Edit section', 'v1/classes/:id/sections/:sectionId', NULL, 'class-management', NULL, 'api', 'PUT', 'ADMIN'),
('Get classes with teacher', 'v1/classes/teachers', NULL, 'class-management', NULL, 'api', 'GET', 'ADMIN'),
('Add class teacher', 'v1/classes/:id/teachers', NULL, 'class-management', NULL, 'api', 'PUT', 'ADMIN'),
('Delete class teacher', 'v1/classes/:id/teachers/:teacherId', NULL, 'class-management', NULL, 'api', 'DELETE', 'ADMIN'),

('User Management', 'user-management', NULL, NULL, 4, 'menu', NULL, 'ADMIN'),
('Students', 'user-management/students', NULL, 'user-management', 1, 'menu-screen', NULL, 'ADMIN'),
('Staff', 'user-management/staff', NULL, 'user-management', 2, 'menu-screen', NULL, 'ADMIN'),
('Roles & Permissions', 'user-management/roles-permissions', NULL, 'user-management', 3, 'menu-screen', NULL, 'ADMIN'),
('Get all students', 'v1/students', NULL, 'user-management', NULL, 'api', 'GET', 'ADMIN'),
('Add new student', 'v1/students', NULL, 'user-management', NULL, 'api', 'POST', 'ADMIN'),
('Get student', 'v1/students/:id', NULL, 'user-management', NULL, 'api', 'GET', 'ADMIN'),
('Edit student', 'v1/students/:id', NULL, 'user-management', NULL, 'api', 'PUT', 'ADMIN'),
('Get all staff', 'v1/staff', NULL, 'user-management', NULL, 'api', 'GET', 'ADMIN'),
('Add new staff', 'v1/staff', NULL, 'user-management', NULL, 'api', 'POST', 'ADMIN'),
('Get staff', 'v1/staff/:id', NULL, 'user-management', NULL, 'api', 'GET', 'ADMIN'),
('Edit staff', 'v1/staff/:id', NULL, 'user-management', NULL, 'api', 'PUT', 'ADMIN'),
('Get all roles', 'v1/roles', NULL, 'user-management', NULL, 'api', 'GET', 'ADMIN'),
('Add new role', 'v1/roles', NULL, 'user-management', NULL, 'api', 'POST', 'ADMIN'),
('Edit role detail', 'v1/roles/:id', NULL, 'user-management', NULL, 'api', 'PUT', 'ADMIN'),
('Get role permissions', 'v1/roles/:id/permissions', NULL, 'user-management', NULL, 'api', 'GET', 'ADMIN'),
('Add role permissions', 'v1/roles/:id/permissions', NULL, 'user-management', NULL, 'api', 'POST', 'ADMIN'),
('Get role users', 'v1/roles/:id/users', NULL, 'user-management', NULL, 'api', 'GET', 'ADMIN'),

('Leave Management', 'leave-management', NULL, NULL, 5, 'menu', NULL, 'ADMIN'),
('Leave Policies', 'leave-management/policies', NULL, 'leave-management', 1, 'menu-screen', NULL, 'ADMIN'),
('Request Leave', 'leave-management/request', NULL, 'leave-management', 2, 'menu-screen', NULL, 'ADMIN'),
('Review Requests', 'leave-management/review', NULL, 'leave-management', 3, 'menu-screen', NULL, 'ADMIN'),
('Add leave policy', 'v1/leaves/policies', NULL, 'leave-management', NULL, 'api', 'POST', 'ADMIN'),
('Get all leave policies', 'v1/leaves/policies', NULL, 'leave-management', NULL, 'api', 'GET', 'ADMIN'),
('Get my leave policies', 'v1/leaves/policies/my', NULL, 'leave-management', NULL, 'api', 'GET', 'ADMIN'),
('Edit leave policy', 'v1/leaves/policies/:id', NULL, 'leave-management', NULL, 'api', 'PUT', 'ADMIN'),
('Add users to policy', 'v1/leaves/policies/:id/users', NULL, 'leave-management', NULL, 'api', 'PUT', 'ADMIN'),
('Get policy users', 'v1/leaves/policies/:id/users', NULL, 'leave-management', NULL, 'api', 'GET', 'ADMIN'),
('Remove user from policy', 'v1/leaves/policies/:id/users', NULL, 'leave-management', NULL, 'api', 'DELETE', 'ADMIN'),
('Get eligible users for leave policy', 'v1/leaves/policies/eligible-users', NULL, 'leave-management', NULL, 'api', 'GET', 'ADMIN'),
('Get leave request history', 'v1/leaves/requests', NULL, 'leave-management', NULL, 'api', 'GET', 'ADMIN'),
('Create new leave request', 'v1/leaves/requests', NULL, 'leave-management', NULL, 'api', 'POST', 'ADMIN'),
('Edit leave request', 'v1/leaves/requests/:id', NULL, 'leave-management', NULL, 'api', 'PUT', 'ADMIN'),
('Delete leave request', 'v1/leaves/requests/:id', NULL, 'leave-management', NULL, 'api', 'DELETE', 'ADMIN'),

('Notices', 'notice-management', NULL, NULL, 6, 'menu', NULL, 'ADMIN'),
('All Notices', 'notices', NULL, 'notice-management', 1, 'menu-screen', NULL, 'ADMIN'),
('Get all notices', 'v1/notices', NULL, 'notice-management', NULL, 'api', 'GET', 'ADMIN'),
('Get notice recipients', 'v1/notices/recipients', NULL, 'notice-management', NULL, 'api', 'GET', 'ADMIN'),
('Add new notice', 'v1/notices', NULL, 'notice-management', NULL, 'api', 'POST', 'ADMIN'),
('Edit notice', 'v1/notices/:id', NULL, 'notice-management', NULL, 'api', 'PUT', 'ADMIN'),
('Delete notice', 'v1/notices/:id', NULL, 'notice-management', NULL, 'api', 'DELETE', 'ADMIN'),
('Review notice', 'v1/notices/:id/review', NULL, 'notice-management', NULL, 'api', 'PATCH', 'ADMIN'),
('Publish notice', 'v1/notices/:id/publish', NULL, 'notice-management', NULL, 'api', 'PATCH', 'ADMIN'),

('Account', 'account', NULL, NULL, 7, 'screen', NULL, 'SYSTEM_ADMIN_AND_ADMIN'),
('Get Account Detail', 'account', NULL, 'account', 1, 'screen', NULL, 'SYSTEM_ADMIN_AND_ADMIN'),
('Resend email verification', 'v1/auth/resend-email-verification', NULL, 'account', NULL, 'api', 'POST', 'ADMIN'),
('Resend password setup link', 'v1/auth/resend-pwd-setup-link', NULL, 'account', NULL, 'api', 'POST', 'ADMIN'),
('Reset password', 'v1/auth/reset-pwd', NULL, 'account', NULL, 'api', 'POST', 'ADMIN'),

('System Configuration', 'system-config', NULL, NULL, 8, 'menu', NULL, 'ADMIN'),
('School Settings', 'system-config/settings', NULL, 'system-config', 1, 'menu-screen', NULL, 'ADMIN'),
('Get school', 'api/v1/schools/:id', NULL, 'system-config', NULL, 'api', 'GET', 'SYSTEM_ADMIN_AND_ADMIN'),
('Edit school', 'api/v1/schools/:id', NULL, 'system-config', NULL, 'api', 'PUT', 'SYSTEM_ADMIN_AND_ADMIN'),

('System', 'system', NULL, NULL, 9, NULL, NULL, 'ADMIN'),
('Get teachers', 'v1/teachers', NULL, 'system', NULL, 'api', 'GET', 'ADMIN')
ON CONFLICT DO NOTHING;


INSERT INTO static_school_user_roles(name, role)
VALUES
('Admin', 'ADMIN'),
('Teacher', 'TEACHER'),
('Student', 'STUDENT'),
('Parent', 'PARENT');

INSERT INTO leave_status (code, name) VALUES
('PENDING', 'Pending'),
('APPROVED', 'Approved'),
('REJECTED', 'Rejected');

INSERT INTO notice_status (code, name, action)
VALUES ('DRAFT', 'Draft', 'Save as Draft'),
('PENDING', 'Pending', 'Submit for review'),
('REJECTED', 'Rejected', 'Reject'),
('APPROVED', 'Approved', 'Approve'),
('PUBLISHED', 'Published', 'Publish');

-- system admin
INSERT INTO schools(name, email, school_id, school_code, is_active)
VALUES('Demo System Admin School', 'system-school@school-admin.xyz', 000000, 'SYS', true);

INSERT INTO roles(id, static_role, name, is_editable, school_id)
VALUES(1, 'SYSTEM_ADMIN', 'System Admin', false, 000000);

-- plain_pwd= systemadmin
INSERT INTO users(user_code, name, email, role_id, school_id, has_system_access, is_email_verified, password)
VALUES('SYS-2025-0001', 'System Admin', 'system-admin@school-admin.xyz', 1, 000000, true, true, '$argon2id$v=19$m=65536,t=3,p=4$ukh/MldWDwcMzSDz32+Aww$jJz9FQx87OUD5WABHzACQgyjaXlBGK0Stcf4j5T25oE');

-- school admin
INSERT INTO schools(name, email, school_id, school_code, is_active)
VALUES('Demo School Admin School', 'demo-school@school-admin.xyz', 123456, 'SCH', true);

INSERT INTO roles(id, static_role, name, is_editable, school_id)
VALUES(2, 'ADMIN', 'admin', false, 123456);

-- plain_pwd= schooladmin
INSERT INTO users(user_code, name, email, role_id, school_id, has_system_access, is_email_verified, password)
VALUES('SCH-2025-0001', 'Demo School Admin', 'admin@school-admin.xyz', 2, 123456, true, true, '$argon2id$v=19$m=65536,t=3,p=4$y2ecZ2rOvStbYhdsfLrLig$HzK0xtxZSS/TO9/5cg+JHhw8dsudFyUDuLqKhBR2U4I');

INSERT INTO invoice_status(code, name, action)
VALUES
    ('DRAFT', 'Draft', 'Create Invoice'),
    ('ISSUED', 'Unpaid', 'Issue Invoice'),
    ('PAID', 'Paid', 'Receive Payment'),
    ('PARTIALLY_PAID', 'Partial Payment Received', 'Receive Partial Payment'),
    ('REFUNDED', 'Payment refunded to the payer', 'Refund Invoice'),
    ('DISPUTED', 'Dispute Raised', 'Raise Dispute'),
    ('CANCELLED', 'Invoice Cancelled', 'Cancel Invoice');

INSERT INTO attendance_status (code, name) 
VALUES
    ('PRESENT', 'Present'),
    ('LATE_PRESENT', 'Late Present'),
    ('ABSENT', 'Absent'),
    ('EARLY_LEAVE', 'Early Leave'),
    ('ON_LEAVE', 'On Leave');

INSERT INTO roles(id, static_role, name, is_editable, school_id)
VALUES
(3, 'TEACHER', 'Teacher', false, 123456),
(4, 'STUDENT', 'Student', false, 123456);
SELECT setval('roles_id_seq', (SELECT MAX(id) FROM roles));

INSERT INTO onboarding_status(code, name)
VALUES                                                                                     
('PENDING', 'Pending'),
('IN_PROGRESS', 'In Progress'),
('COMPLETED', 'Completed'),
('ERROR', 'Error');

INSERT INTO demo_requests_status(code, name)
VALUES
('DEMO_CONFIRMATION_REQUEST_SENT', 'Confirmation email for demo date and time sent to user'),
('DEMO_CONFIRMED', 'Demo date and time confirmed'),
('DEMO_COMPLETION_FOLLOWUP_EMAIL_SENT', 'Follow-up email sent after demo with invitation to system'),
('DEMO_CANCELLED', 'Demo was Cancelled'),
('PWD_SETUP_INVITE_SENT', 'User invited for account setup after verification'),
('ACCOUNT_SETUP_REQUEST_RECEIVED', 'User requested direct access'),
('ACCOUNT_SETUP_REQUEST_DENIED', ' Direct access request was canceled'),
('ACCOUNT_VERIFICATION_EMAIL_SENT', 'Account verification email sent'),
('ACCOUNT_ACTIVE', 'User completed registration and account is active');

INSERT INTO demo_requests_contact_person_roles(code, name)
VALUES
('PRINCIPAL', 'Principal'),
('VICE_PRINCIPAL', 'Vice Principal'),
('TEACHER', 'Teacher'),
('IT_ADMINISTRATOR', 'IT Administrator'),
('ADMINISTRATIVE_STAFF', 'Administrative Staff'),
('SCHOOL_BOARD_MEMBER', 'School Board Member'),
('OTHER', 'Other');

INSERT INTO genders(code, name)
VALUES
('MALE', 'Male'),
('FEMALE', 'Female'),
('OTHER', 'Other');

INSERT INTO marital_status(code, name)
VALUES
('SINGLE', 'Single'),
('MARRIED', 'Married'),
('DIVORCED', 'Divorced'),
('WIDOWED', 'Widowed');
