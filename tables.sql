CREATE TABLE schools (
    id SERIAL PRIMARY KEY,
    school_code VARCHAR(6) UNIQUE DEFAULT NULL CHECK(school_code IS NULL OR school_code ~ '^[A-Z0-9]{3,6}$'),
    school_id INTEGER UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(30) DEFAULT NULL,
    pan VARCHAR(50) DEFAULT NULL,
    calendar_type CHAR(2) CHECK(calendar_type IN('BS', 'AD')) DEFAULT 'BS',
    established_year INTEGER DEFAULT NULL,
    address VARCHAR(100) DEFAULT NULL,
    registration_number VARCHAR(100) DEFAULT NULL,
    admin_id INTEGER DEFAULT NULL,
    motto VARCHAR(100) DEFAULT NULL,
    website_url VARCHAR(100) DEFAULT NULL,
    logo_url VARCHAR(250) DEFAULT NULL,
    is_active BOOLEAN DEFAULT false,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_modified_by INTEGER DEFAULT NULL,
    updated_date TIMESTAMP DEFAULT NULL
);

CREATE TABLE static_school_user_roles(
    id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    role VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE genders(
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    name TEXT NOT NULL,
    UNIQUE(code, name)
);

CREATE TABLE marital_status(
    id SERIAL PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    name TEXT NOT NULL,
    UNIQUE(code, name)
);

CREATE TABLE academic_levels(
    id SERIAL PRIMARY KEY,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE classes(
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    academic_level_id INTEGER REFERENCES academic_levels(id) DEFAULT NULL,
    sort_order INTEGER DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(name, school_id, academic_level_id, sort_order)
);

CREATE TABLE departments(
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    UNIQUE(name, school_id)
);

CREATE TABLE sections(
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    class_id INTEGER REFERENCES classes(id) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT NULL,
    UNIQUE(name, school_id, class_id, sort_order)
);

CREATE TABLE academic_years(
    id SERIAL PRIMARY KEY,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    name VARCHAR(70) UNIQUE NOT NULL,
    academic_level_id INTEGER REFERENCES academic_levels(id) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT false
);

CREATE TABLE leave_policies(
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    UNIQUE(name, school_id)
);

CREATE TABLE roles(
    id SERIAL PRIMARY KEY,
    static_role VARCHAR(20) NOT NULL,
    name VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    is_editable BOOLEAN DEFAULT true,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    UNIQUE(static_role, name, school_id)
);

CREATE TABLE users(
    id SERIAL PRIMARY KEY,
    user_code VARCHAR(30) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(255) DEFAULT NULL,
    password_last_changed_date TIMESTAMP DEFAULT NULL,
    last_login TIMESTAMP DEFAULT NULL,
    is_email_verified BOOLEAN DEFAULT false,
    has_system_access BOOLEAN DEFAULT false,
    role_id INTEGER NOT NULL,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT NULL,
    reporter_id INTEGER DEFAULT NULL,
    status_last_reviewed_date TIMESTAMP DEFAULT NULL,
    status_last_reviewer_id INTEGER REFERENCES users(id)
        ON UPDATE SET NULL
        DEFAULT NULL,
    profile_url VARCHAR(250) DEFAULT NULL,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    recent_device_info TEXT DEFAULT NULL,
    UNIQUE(email, school_id)
);

CREATE TABLE user_profiles(
    user_id INTEGER PRIMARY KEY REFERENCES users(id),
    gender VARCHAR(10) REFERENCES genders(code) DEFAULT NULL,
    marital_status VARCHAR(50) REFERENCES marital_status(code) DEFAULT NULL,
    join_date DATE DEFAULT NULL,
    qualification VARCHAR(100) DEFAULT NULL,
    experience VARCHAR(100) DEFAULT NULL,
    dob DATE DEFAULT NULL,
    phone VARCHAR(20) DEFAULT NULL,
    class_id INTEGER REFERENCES classes(id) DEFAULT NULL,
    section_id INTEGER REFERENCES sections(id) DEFAULT NULL,
    roll INTEGER DEFAULT NULL,
    department_id INTEGER REFERENCES departments(id) DEFAULT NULL,
    guardian_name VARCHAR(50) DEFAULT NULL,
    guardian_phone VARCHAR(20) DEFAULT NULL,
    guardian_email VARCHAR(50) DEFAULT NULL,
    guardian_relationship VARCHAR(50) DEFAULT NULL,
    current_address VARCHAR(50) DEFAULT NULL,
    permanent_address VARCHAR(50) DEFAULT NULL,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT NULL,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    blood_group CHAR(2) DEFAULT NULL,
    UNIQUE(user_id, school_id)
);

CREATE TABLE permissions(
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    path VARCHAR(100) DEFAULT NULL,
    icon VARCHAR(100) DEFAULT NULL,
    parent_path VARCHAR(100) DEFAULT NULL,
    hierarchy_id INTEGER DEFAULT NULL,
    type VARCHAR(50) DEFAULT NULL,
    method VARCHAR(10) DEFAULT NULL,
    direct_allowed_role VARCHAR(50) DEFAULT NULL,
    UNIQUE(path, method)
);

CREATE TABLE leave_status(
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE user_leaves(
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users (id) NOT NULL,
    academic_year_id INTEGER REFERENCES academic_years(id) NOT NULL,
    leave_policy_id INTEGER REFERENCES leave_policies(id) DEFAULT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    note VARCHAR(100),
    submitted_date TIMESTAMP DEFAULT CURRENT_DATE,
    updated_date TIMESTAMP DEFAULT NULL,
    reviewed_date TIMESTAMP DEFAULT NULL,
    reviewer_id INTEGER REFERENCES users(id),
    reviewer_note VARCHAR(100),
    leave_status_code VARCHAR(20) REFERENCES leave_status(code),
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    UNIQUE(school_id, academic_year_id, user_id, leave_policy_id, from_date, to_date)
);

CREATE TABLE class_teachers(
    id SERIAL PRIMARY KEY,
    teacher_id INTEGER REFERENCES users(id),
    class_id INTEGER REFERENCES classes(id) NOT NULL,
    section_id INTEGER REFERENCES sections(id) DEFAULT NULL,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    UNIQUE(school_id, class_id, teacher_id)
);

CREATE TABLE notice_status(
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    action VARCHAR(50) NOT NULL
);

CREATE TABLE notices(
    id SERIAL PRIMARY KEY,
    author_id INTEGER REFERENCES users(id),
    title VARCHAR(100) NOT NULL,
    description VARCHAR(400) NOT NULL,
    notice_status_code VARCHAR(20) REFERENCES notice_status(code) NOT NULL,
    published_date TIMESTAMP DEFAULT NULL,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT NULL,
    reviewed_date TIMESTAMP DEFAULT NULL,
    reviewer_id INTEGER REFERENCES users(id) DEFAULT NULL,
    recipient_type CHAR(2) NOT NULL,
    recipient_role_id INTEGER DEFAULT NULL,
    recipient_first_field INT DEFAULT NULL,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL
);

CREATE TABLE user_refresh_tokens (
  id SERIAL PRIMARY KEY,
  token TEXT NOT NULL,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  issued_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  school_id INTEGER REFERENCES schools(school_id) NOT NULL
);

CREATE TABLE role_permissions(
    id SERIAL PRIMARY KEY,
    role_id INTEGER NOT NULL,
    permission_id INTEGER REFERENCES permissions(id),
    type VARCHAR(20) DEFAULT NULL,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    UNIQUE(role_id, permission_id, school_id)
);

CREATE TABLE user_leave_policy (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) DEFAULT NULL,
    leave_policy_id INTEGER REFERENCES leave_policies(id) DEFAULT NULL,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    UNIQUE(user_id, leave_policy_id, school_id)
);

CREATE TABLE student_academic_record(
    id SERIAL PRIMARY KEY,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    academic_year_id INTEGER REFERENCES academic_years(id) NOT NULL,
    student_id INTEGER REFERENCES users(id) NOT NULL,
    class_id INTEGER REFERENCES classes(id) NOT NULL,
    section_id INTEGER REFERENCES sections(id) DEFAULT NULL,
    roll_number INTEGER DEFAULT NULL,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT NULL
);

CREATE TABLE credits(
    id SERIAL PRIMARY KEY,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    user_id INTEGER REFERENCES users(id) NOT NULL,
    amount NUMERIC(10, 2) DEFAULT 0,
    status VARCHAR(20) CHECK(status IN('ACTIVE', 'REFUNDED', 'USED')) DEFAULT 'ACTIVE',
    reason VARCHAR(50) DEFAULT NULL, -- reason for credit: overpayment, advance, error
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT NULL,
    UNIQUE(school_id, user_id)
);

CREATE TABLE payment_methods(
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(70) DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT NULL
);

CREATE TABLE refunds(
    id SERIAL PRIMARY KEY,
    invoice_id INTEGER DEFAULT NULL,
    type VARCHAR(15) DEFAULT NULL, -- deposit, credit, invoice
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    user_id INTEGER REFERENCES users(id) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL, -- Refund amount
    refunded_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method_id INT REFERENCES payment_methods(id) NOT NULL, -- Method of refund (e.g., "Bank Transfer", "Credit Card")
    status VARCHAR(20) CHECK(status IN('PENDING', 'PROGRESS', 'COMPLETED')) DEFAULT 'PENDING', -- Refund status: PENDING, PROGRESS, COMPLETED
    reason VARCHAR(255) DEFAULT NULL -- Reason for the refund (if applicable)
);

CREATE TABLE attendance_status(
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE,
    name VARCHAR(30)
);

CREATE TABLE subjects(
    id SERIAL PRIMARY KEY,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    name VARCHAR(70),
    total_operating_period INTEGER DEFAULT 0,
    class_id INTEGER REFERENCES classes(id) NOT NULL,
    section_id INTEGER REFERENCES sections(id) DEFAULT NULL,
	UNIQUE(school_id, name, class_id, section_id)
);

CREATE TABLE attendances(
    id SERIAL PRIMARY KEY,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    user_leave_id INTEGER REFERENCES user_leaves(id) DEFAULT NULL,
    academic_year_id INTEGER REFERENCES academic_years(id) NOT NULL,
    user_id INTEGER REFERENCES users(id) NOT NULL,
    attendance_status_code VARCHAR(20) REFERENCES attendance_status(code) NOT NULL,
    attendance_date DATE NOT NULL,
    remarks TEXT DEFAULT NULL,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT NULL,
    attendance_recorder INTEGER REFERENCES users(id) NOT NULL,
    attendance_type CHAR(1) CHECK(attendance_type IN('D', 'S')) DEFAULT 'D',
        -- D= Day Wise
        -- S= Subject Wise
    subject_id INTEGER REFERENCES subjects(id) DEFAULT NULL,
    UNIQUE(school_id, academic_year_id, user_id, attendance_date)
);

CREATE TABLE exams(
    id SERIAL PRIMARY KEY,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    academic_year_id INTEGER REFERENCES academic_years(id) NOT NULL,
    class_id INTEGER REFERENCES classes(id) DEFAULT NULL,
    section_id INTEGER REFERENCES sections(id) DEFAULT NULL,
    parent_exam_id INTEGER REFERENCES exams(id) DEFAULT NULL,
    name VARCHAR(70) NOT NULL,
    exam_date DATE DEFAULT NULL,
    type CHAR(1) NOT NULL,
    subject_id INTEGER REFERENCES subjects(id) DEFAULT NULL,
    start_time TIME DEFAULT NULL,
    end_time TIME DEFAULT NULL,
    total_marks NUMERIC(5, 2) DEFAULT NULL,
    theory_passing_marks NUMERIC(5, 2) DEFAULT NULL,
    practical_passing_marks NUMERIC(5, 2) DEFAULT NULL,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT NULL,
    UNIQUE(school_id, academic_year_id, type, name, subject_id)
);

CREATE TABLE marks(
    id SERIAL PRIMARY KEY,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    academic_year_id INTEGER REFERENCES academic_years(id) NOT NULL,
    exam_id INTEGER REFERENCES exams(id) NOT NULL,
    class_id INTEGER REFERENCES classes(id) DEFAULT NULL,
    section_id INTEGER REFERENCES sections(id) DEFAULT NULL,
    user_id INTEGER REFERENCES users(id) NOT NULL,
    subject_id INTEGER REFERENCES subjects(id) NOT NULL,
    theory_marks_obtained NUMERIC(5, 2) DEFAULT 0.00,
    practical_marks_obtained NUMERIC(5, 2) DEFAULT 0.00,
    total_marks_obtained NUMERIC(5, 2) DEFAULT 0.00,
    grade NUMERIC(5, 2) DEFAULT 0.00,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT NULL,
    UNIQUE(school_id, academic_year_id, exam_id, user_id, subject_id)
);

CREATE TABLE invoice_status(
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(30) NOT NULL,
    action VARCHAR(70) DEFAULT NULL
);

CREATE TABLE fiscal_years(
    id SERIAL PRIMARY KEY,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    name VARCHAR(70) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT false
);

CREATE TABLE academic_periods(
    id SERIAL PRIMARY KEY,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    name VARCHAR(50) NOT NULL,
    academic_level_id INTEGER REFERENCES academic_levels(id) NOT NULL,
    sort_order INTEGER DEFAULT NULL,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    UNIQUE(school_id, academic_level_id, sort_order)
);

CREATE TABLE invoices(
    id SERIAL PRIMARY KEY,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    fiscal_year_id INTEGER REFERENCES fiscal_years(id) NOT NULL,
    academic_year_id INTEGER REFERENCES academic_years(id) NOT NULL,
    academic_period_id INTEGER REFERENCES academic_periods(id) NOT NULL,
    user_id INTEGER REFERENCES users(id) NOT NULL,
    initiator INTEGER REFERENCES users(id) NOT NULL,
    invoice_number VARCHAR(70) UNIQUE DEFAULT NULL,
    description VARCHAR(50) DEFAULT NULL,
    invoice_status_status VARCHAR(20) REFERENCES invoice_status(code) DEFAULT 'DRAFT',
    due_date DATE DEFAULT NULL,
    amount NUMERIC(10, 2) DEFAULT 0,
    discounted_amt NUMERIC(10, 2) DEFAULT 0,
    paid_amt NUMERIC(10, 2) DEFAULT 0,
    outstanding_amt NUMERIC(10, 2) DEFAULT 0,
    refunded_amt NUMERIC(10, 2) DEFAULT 0,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE fees(
    id SERIAL PRIMARY KEY,
    name VARCHAR(70) NOT NULL,
    group_id INTEGER REFERENCES fees(id) DEFAULT NULL
);

CREATE TABLE fee_structures(
    id SERIAL PRIMARY KEY,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    fee_id INTEGER REFERENCES fees(id) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    class_id INTEGER DEFAULT NULL,
    is_active BOOLEAN DEFAULT false,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT NULL
);

CREATE TABLE student_fees(
    id SERIAL PRIMARY KEY,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    academic_period_id INTEGER REFERENCES academic_periods(id) NOT NULL,
    student_id INTEGER REFERENCES users(id),
    academic_year_id INTEGER REFERENCES academic_years(id) NOT NULL,
    fiscal_year_id INTEGER REFERENCES fiscal_years(id) NOT NULL,
    initiator INTEGER REFERENCES users(id) NOT NULL,
    fee_structure_id INTEGER REFERENCES fee_structures(id) NOT NULL,
    due_date DATE DEFAULT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    discount_value NUMERIC(10, 2) DEFAULT NULL,
    discount_type CHAR(1) CHECK(discount_type IN('P', 'A')) DEFAULT 'A',
        -- P= Percentage
        -- A= Amount
    outstanding_amt  NUMERIC(10, 2) NOT NULL,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    
    updated_date TIMESTAMP DEFAULT NULL
);

CREATE TABLE invoice_items(
    id SERIAL PRIMARY KEY,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    invoice_id INTEGER REFERENCES invoices(id) NOT NULL,
    fee_structure_id INTEGER REFERENCES fee_structures(id) DEFAULT NULL,
    student_fee_id INTEGER REFERENCES student_fees(id) DEFAULT NULL,
    description VARCHAR(50) DEFAULT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    quantity INTEGER NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL,
    total_discount NUMERIC(10, 2) NOT NULL,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT NULL
);

CREATE TABLE discounts (
    id SERIAL PRIMARY KEY,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    user_id INTEGER DEFAULT NULL,
    description VARCHAR(100) DEFAULT NULL,
    discount_type VARCHAR(20) CHECK (discount_type IN('PERCENTAGE', 'AMOUNT')) NOT NULL,
    discount_value NUMERIC(10, 2) NOT NULL,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE deposits(
    id SERIAL PRIMARY KEY,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    user_id INTEGER REFERENCES users(id) NOT NULL,
    amount NUMERIC(10, 2) DEFAULT 0,
    remarks TEXT DEFAULT NULL,
    status VARCHAR(15) CHECK (status IN('ACTIVE', 'REFUNDED')) DEFAULT 'ACTIVE'
);

CREATE TABLE transactions(
    id SERIAL PRIMARY KEY,
    school_id INTEGER REFERENCES schools(school_id) NOT NULL,
    academic_year_id INTEGER REFERENCES academic_years(id) NOT NULL,
    fiscal_year_id INTEGER REFERENCES fiscal_years(id) NOT NULL,
    user_id INTEGER REFERENCES users(id) DEFAULT NULL,
    initiator INTEGER REFERENCES users(id) NOT NULL,
    type VARCHAR(10) NOT NULL,
    fee_structure_id INTEGER REFERENCES fee_structures(id) DEFAULT NULL,
    invoice_id INTEGER DEFAULT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_DATE,
    payment_method_id INT REFERENCES payment_methods(id) NOT NULL,
    transaction_id VARCHAR(100) UNIQUE DEFAULT NULL,
    status VARCHAR(30) CHECK(status IN('PENDING', 'SUCCESS')) DEFAULT 'PENDING',
    remarks TEXT DEFAULT NULL,
    updated_date TIMESTAMP DEFAULT NULL
);

CREATE TABLE system_access_person_roles(
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    UNIQUE(code, name)
);

CREATE TABLE system_access_status(
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    UNIQUE(code, name) 
);

CREATE TABLE system_access_requests(
    id SERIAL PRIMARY KEY,
    contact_person VARCHAR(100) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    school_name VARCHAR(100) NOT NULL,
    system_access_person_code VARCHAR(50) REFERENCES system_access_person_roles(code) DEFAULT NULL,
    phone VARCHAR(50) DEFAULT NULL,
    school_size CHAR(2) CHECK(school_size IN('S', 'M', 'L', 'VL')) DEFAULT NULL,
    additional_information TEXT DEFAULT NULL,
    system_access_status_code VARCHAR(50) REFERENCES system_access_status(code) NOT NULL,
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE contact_messages(
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) DEFAULT NULL,
    email VARCHAR(50) NOT NULL,
    message TEXT NOT NULL
);

CREATE TABLE school_ids(
    id SERIAL PRIMARY KEY,
    school_id INTEGER NOT NULL UNIQUE,
    state VARCHAR(10) CHECK(state IN('FREE', 'RESERVED', 'USED')) DEFAULT 'FREE'
);

CREATE TABLE verification_tokens(
    id SERIAL PRIMARY KEY,
    identifier VARCHAR(70),
    purpose VARCHAR(50),
    hash_key TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiry_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(identifier, purpose, hash_key)
);