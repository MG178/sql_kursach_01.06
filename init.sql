-- ============================================
-- CollegeHub: Единый студенческий портал колледжа
-- с QR-отметкой посещаемости
-- ============================================

CREATE TABLE roles (
    id INT AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    CONSTRAINT pk_roles PRIMARY KEY (id)
);

CREATE TABLE groups (
    id INT AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    course INT,
    department VARCHAR(100),
    CONSTRAINT pk_groups PRIMARY KEY (id)
);

CREATE TABLE users (
    id INT AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    group_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_users PRIMARY KEY (id),
    CONSTRAINT fk_users_role FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_users_group FOREIGN KEY (group_id)
        REFERENCES groups(id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE subjects (
    id INT AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    teacher_id INT NULL,
    CONSTRAINT pk_subjects PRIMARY KEY (id),
    CONSTRAINT fk_subjects_teacher FOREIGN KEY (teacher_id)
        REFERENCES users(id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE schedule (
    id INT AUTO_INCREMENT,
    group_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NULL,
    room VARCHAR(50),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    day_of_week ENUM('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday') NOT NULL,
    lesson_type ENUM('lecture','practice','lab') DEFAULT 'lecture',
    CONSTRAINT pk_schedule PRIMARY KEY (id),
    CONSTRAINT fk_schedule_group FOREIGN KEY (group_id)
        REFERENCES groups(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_schedule_subject FOREIGN KEY (subject_id)
        REFERENCES subjects(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_schedule_teacher FOREIGN KEY (teacher_id)
        REFERENCES users(id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE qr_sessions (
    id INT AUTO_INCREMENT,
    schedule_id INT NOT NULL,
    qr_code_data VARCHAR(255) NOT NULL UNIQUE,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT pk_qr_sessions PRIMARY KEY (id),
    CONSTRAINT fk_qr_schedule FOREIGN KEY (schedule_id)
        REFERENCES schedule(id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE attendance (
    id INT AUTO_INCREMENT,
    user_id INT NOT NULL,
    qr_session_id INT NOT NULL,
    scanned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('present','late','absent') DEFAULT 'present',
    CONSTRAINT pk_attendance PRIMARY KEY (id),
    CONSTRAINT fk_attendance_user FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_attendance_qr FOREIGN KEY (qr_session_id)
        REFERENCES qr_sessions(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT unique_attendance UNIQUE (user_id, qr_session_id)
);