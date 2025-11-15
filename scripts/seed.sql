INSERT INTO departments (id, code, name, description) VALUES
  (1, 'CSE', 'Computer Science', 'Computer Science and Engineering'),
  (2, 'ECE', 'Electronics', 'Electronics & Communication');

INSERT INTO teachers (id, employee_id, name, email, phone, department_id, subjects)
VALUES (1, 'EMP-001', 'Dr. Alice Quantum', 'alice@uni.dev', '5551112222', 1, '["Algorithms","AI"]');

INSERT INTO courses (id, code, title, description, credits, department_id, teacher_id)
VALUES (1, 'CS101', 'Intro to CS', 'Foundations of CS', 4, 1, 1);

INSERT INTO students (id, roll_no, first_name, last_name, email, phone, dob, gender, address, department_id, enroll_date, profile_photo_url, status)
VALUES (1, '2024CSE001', 'Jamie', 'Lee', 'jamie@uni.dev', '5550001111', '2004-01-12', 'F', 'Dorm 7', 1, '2022-08-01', 'https://picsum.photos/200', 'ACTIVE');
