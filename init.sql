-- ============================================
-- CollegeHub: Инициализация базы данных
-- для Microsoft SQL Server
-- ============================================

-- 1. Создание базы данных
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'CollegeHub')
BEGIN
    CREATE DATABASE CollegeHub;
END;
GO

USE CollegeHub;
GO

-- 2. Создание таблиц

CREATE TABLE roles (
    id INT IDENTITY(1,1) NOT NULL,
    name NVARCHAR(50) NOT NULL UNIQUE,
    CONSTRAINT pk_roles PRIMARY KEY (id)
);

CREATE TABLE groups (
    id INT IDENTITY(1,1) NOT NULL,
    name NVARCHAR(50) NOT NULL,
    course INT,
    department NVARCHAR(100),
    CONSTRAINT pk_groups PRIMARY KEY (id)
);

CREATE TABLE users (
    id INT IDENTITY(1,1) NOT NULL,
    full_name NVARCHAR(150) NOT NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    group_id INT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT pk_users PRIMARY KEY (id),
    CONSTRAINT fk_users_role FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT fk_users_group FOREIGN KEY (group_id)
        REFERENCES groups(id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE subjects (
    id INT IDENTITY(1,1) NOT NULL,
    name NVARCHAR(150) NOT NULL,
    teacher_id INT NULL,
    CONSTRAINT pk_subjects PRIMARY KEY (id),
    CONSTRAINT fk_subjects_teacher FOREIGN KEY (teacher_id)
        REFERENCES users(id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE schedule (
    id INT IDENTITY(1,1) NOT NULL,
    group_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NULL,
    room NVARCHAR(50),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    day_of_week NVARCHAR(10) NOT NULL
        CONSTRAINT chk_day CHECK (day_of_week IN ('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')),
    lesson_type NVARCHAR(10) DEFAULT 'lecture'
        CONSTRAINT chk_lesson_type CHECK (lesson_type IN ('lecture','practice','lab')),
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
    id INT IDENTITY(1,1) NOT NULL,
    schedule_id INT NOT NULL,
    qr_code_data NVARCHAR(255) NOT NULL UNIQUE,
    generated_at DATETIME2 DEFAULT GETDATE(),
    expires_at DATETIME2 NOT NULL,
    is_active BIT DEFAULT 1,
    CONSTRAINT pk_qr_sessions PRIMARY KEY (id),
    CONSTRAINT fk_qr_schedule FOREIGN KEY (schedule_id)
        REFERENCES schedule(id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE attendance (
    id INT IDENTITY(1,1) NOT NULL,
    user_id INT NOT NULL,
    qr_session_id INT NOT NULL,
    scanned_at DATETIME2 DEFAULT GETDATE(),
    status NVARCHAR(10) DEFAULT 'present'
        CONSTRAINT chk_status CHECK (status IN ('present','late','absent')),
    CONSTRAINT pk_attendance PRIMARY KEY (id),
    CONSTRAINT fk_attendance_user FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_attendance_qr FOREIGN KEY (qr_session_id)
        REFERENCES qr_sessions(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT unique_attendance UNIQUE (user_id, qr_session_id)
);
GO

PRINT 'База данных CollegeHub успешно создана и инициализирована.';