INSERT INTO departments (code, name, description)
VALUES ('CSE','Computer Science','Computer Science and Engineering')
ON CONFLICT DO NOTHING;

INSERT INTO departments (code, name, description)
VALUES ('ECE','Electronics','Electronics and Communication')
ON CONFLICT DO NOTHING;
