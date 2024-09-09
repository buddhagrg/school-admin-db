INSERT INTO access_controls(
    id,
    name,
    path,
    icon,
    parent_id,
    hierarchy_id,
    type
)
VALUES
(1, 'Dashoard', 'dashboard', 'dashboard.svg', NULL, 1, 'menu'),
(2, 'Leave', 'leave', 'leave.svg', NULL, 2, 'menu'),
(3, 'Leave Define', 'leave/define', NULL, 2, 1, 'menu'),
(4, 'Leave Request', 'leave/request', NULL, 2, 2, 'menu'),
(5, 'Pending Leave Request', 'leave/pending', NULL, 2, 3, 'menu'),
(6, 'Academics', 'academics', 'academics.svg', NULL, 3, 'menu'),
(7, 'Classes', 'classes', NULL, 6, 1, 'menu'),
(8, 'Class Teachers', 'class-teachers', NULL, 6, 2, 'menu'),
(9, 'Students', 'students', 'students.svg', NULL, 4, 'menu'),
(10, 'Student List', 'students', NULL, 9, 1, 'menu'),
(11, 'Add Student', 'students/add', NULL, 9, 2, 'menu'),
(12, 'Communication', 'communication', 'communication.svg', NULL, 5, 'menu'),
(13, 'Notice Board', 'notices', NULL, 12, 1, 'menu'),
(14, 'Add Notice', 'notices/add', NULL, 12, 2, 'menu'),
(15, 'Human Resource', 'hr', 'hr.svg', NULL, 6, 'menu'),
(16, 'Staff List', 'staffs', NULL, 15, 1, 'menu'),
(17, 'Add Staff', 'staffs/add', NULL, 15, 2, 'menu'),
(18, 'Access Setting', 'access-setting', 'rolesAndPermissions.svg', NULL, 7, 'menu'),
(19, 'Roles & Permissions', 'roles-and-permissions', NULL, 18, 1, 'menu'),
(20, 'Classes Edit', 'classes/edit/id', NULL, NULL, NULL, 'screen'),
(21, 'Class Teachers Edit', 'class-teachers/edit/id', NULL, NULL, NULL, 'screen'),
(22, 'View Student', 'students/id', NULL, NULL, NULL, 'screen'),
(23, 'Edit Student', 'students/edit/id', NULL, NULL, NULL, 'screen'),
(24, 'View Notice', 'notices/id', NULL, NULL, NULL, 'screen'),
(25, 'Edit Notice', 'notics/edit/id', NULL, NULL, NULL, 'screen'),
(26, 'View Staffs', 'staffs/id', NULL, NULL, NULL, 'screen'),
(27, 'Edit Staff', 'staffs/edit/id', NULL, NULL, NULL, 'screen'),
(28, 'Manage Notices', 'notices/manage', NULL, 12, 3, 'menu'),
(29, 'Sections', 'sections', NULL, 6, 3, 'menu'),
(30, 'Section Edit', 'sections/edit/id', NULL, NULL, NULL, 'screen'),
(31, 'Departments', 'departments', NULL, 15, 3, 'menu'),
(32, 'Edit Department', 'departments/edit/id', NULL, NULL, NULL, 'screen'),
(33, 'Notice Recipients', 'notices/recipients', NULL, 12, 3, 'menu'),
(34, 'Edit Recipient', 'notices/recipients/edit/id', NULL, NULL, NULL, 'screen')
ON CONFLICT DO NOTHING;

ALTER SEQUENCE leave_status_id_seq RESTART WITH 1;
INSERT INTO leave_status (name) VALUES
('On Review'),
('Approved'),
('Cancelled');

ALTER SEQUENCE roles_id_seq RESTART WITH 1;
INSERT INTO roles (name, is_editable)
VALUES ('Admin', false), ('Teacher', false), ('Student', false);

ALTER SEQUENCE notice_status_id_seq RESTART WITH 1;
INSERT INTO notice_status (name, alias)
VALUES ('Draft', 'Draft'),
('Submit for Review', 'Approval Pending'),
('Submit for Deletion', 'Delete Pending'),
('Reject', 'Rejected'),
('Approve', 'Approved'),
('Delete', 'Deleted');

INSERT INTO users(name,email,role_id,created_dt,password, is_active, is_email_verified)
VALUES('John Doe','admin@gmail.com',1, now(),'$argon2id$v=19$m=65536,t=3,p=4$qGMKQSrLeRX3pDDQguzkMg$UKZgR5BaB6RNCzvtlOU8jX/W7gItTifTBbR7Y1U6HLI', true, true)
RETURNING id;

INSERT INTO user_profiles
(user_id, gender, marital_status, phone,dob,join_dt,qualification,experience,current_address,permanent_address,father_name,mother_name,emergency_phone)
VALUES
((SELECT currval('users_id_seq')),'Male','Married','4759746607','2024-08-05',NULL,NULL,NULL,NULL,NULL,'stut','lancy','79374304');

INSERT INTO permissions(role_id, access_control_id, type)
VALUES
(1 , 1, 'menu'),
(1 , 2, 'menu'),
(1 , 3, 'menu'),
(1 , 4, 'menu'),
(1 , 5, 'menu'),
(1 , 6, 'menu'),
(1 , 7, 'menu'),
(1 , 8, 'menu'),
(1 , 9, 'menu'),
(1 , 10, 'menu'),
(1 , 11, 'menu'),
(1 , 12, 'menu'),
(1 , 13, 'menu'),
(1 , 14, 'menu'),
(1 , 15, 'menu'),
(1 , 16, 'menu'),
(1 , 17, 'menu'),
(1 , 18, 'menu'),
(1 , 19, 'menu'),
(1 , 28, 'menu'),
(1 , 29, 'menu'),
(1 , 31, 'menu'),
(1 , 33, 'menu')
ON CONFLICT DO NOTHING;
