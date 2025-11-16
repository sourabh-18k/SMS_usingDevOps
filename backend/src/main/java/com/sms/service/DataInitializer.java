package com.sms.service;

import com.sms.entity.*;
import com.sms.repository.*;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Component
@RequiredArgsConstructor
public class DataInitializer {

    private final AppUserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final DepartmentRepository departmentRepository;
    private final TeacherRepository teacherRepository;
    private final StudentRepository studentRepository;
    private final CourseRepository courseRepository;
    private final AttendanceRepository attendanceRepository;
    private final MarkRepository markRepository;

    @PostConstruct
    public void seed() {
    seedAdmin();
    seedReferenceData();
    }

    private void seedAdmin() {
        if (!userRepository.existsByEmail("admin@sms.dev")) {
            AppUser admin = AppUser.builder()
                    .fullName("Platform Admin")
                    .email("admin@sms.dev")
                    .password(passwordEncoder.encode("ChangeMe123!"))
                    .role(RoleType.ADMIN)
                    .build();
            userRepository.save(admin);
        }
    }

    private void seedReferenceData() {
    Department cse = ensureDepartment("CSE", "Computer Science & Engineering",
        "AI/ML labs at Bengaluru campus");
    Department ece = ensureDepartment("ECE", "Electronics & Communication",
        "High frequency design labs in Hyderabad");
    Department mech = ensureDepartment("ME", "Mechanical Engineering",
        "Advanced manufacturing facility in Chennai");

    Teacher ananya = ensureTeacher("TCH-1001", "Dr. Ananya Rao", "ananya.rao@sms.dev",
        "9876543210", cse, List.of("Data Structures", "Algorithms"));
    Teacher kiran = ensureTeacher("TCH-1002", "Dr. Kiran Iyer", "kiran.iyer@sms.dev",
        "9810012345", ece, List.of("Signals", "VLSI"));

    Student aarav = ensureStudent("23CSE001", "Aarav", "Sharma", "aarav.sharma@sms.dev",
        "9123456780", LocalDate.of(2005, 2, 11), "M", "Koramangala, Bengaluru",
        cse, LocalDate.of(2023, 8, 1));
    Student diya = ensureStudent("23ECE002", "Diya", "Menon", "diya.menon@sms.dev",
        "9898989898", LocalDate.of(2005, 7, 4), "F", "Gachibowli, Hyderabad",
        ece, LocalDate.of(2023, 8, 1));
    Student kabir = ensureStudent("23ME003", "Kabir", "Singh", "kabir.singh@sms.dev",
        "9000090000", LocalDate.of(2004, 12, 21), "M", "Velachery, Chennai",
        mech, LocalDate.of(2022, 8, 1));

    Course advDs = ensureCourse("CSE201", "Advanced Data Structures",
        "Hands-on labs for competitive programming", 4, cse, ananya);
    Course embedded = ensureCourse("ECE150", "Embedded Systems",
        "Arm Cortex projects with IoT focus", 3, ece, kiran);

    seedAttendanceSample(aarav, advDs, LocalDate.now().minusDays(1), AttendanceStatus.PRESENT);
    seedAttendanceSample(diya, embedded, LocalDate.now().minusDays(1), AttendanceStatus.LATE);
    seedAttendanceSample(kabir, advDs, LocalDate.now().minusDays(2), AttendanceStatus.ABSENT);

    seedMarksSample(aarav, advDs, "Midterm", new BigDecimal("44"), new BigDecimal("50"));
    seedMarksSample(diya, embedded, "Quiz", new BigDecimal("18"), new BigDecimal("20"));
    }

    private Department ensureDepartment(String code, String name, String description) {
    return departmentRepository.findByCode(code)
        .orElseGet(() -> departmentRepository.save(Department.builder()
            .code(code)
            .name(name)
            .description(description)
            .build()));
    }

    private Teacher ensureTeacher(String employeeId, String name, String email, String phone,
                  Department department, List<String> subjects) {
    return teacherRepository.findByEmployeeId(employeeId)
        .orElseGet(() -> teacherRepository.save(Teacher.builder()
            .employeeId(employeeId)
            .name(name)
            .email(email)
            .phone(phone)
            .department(department)
            .subjects(subjects)
            .build()));
    }

    private Student ensureStudent(String rollNo, String firstName, String lastName, String email,
                  String phone, LocalDate dob, String gender, String address,
                  Department department, LocalDate enrollDate) {
    return studentRepository.findByRollNo(rollNo)
        .orElseGet(() -> studentRepository.save(Student.builder()
            .rollNo(rollNo)
            .firstName(firstName)
            .lastName(lastName)
            .email(email)
            .phone(phone)
            .dob(dob)
            .gender(gender)
            .address(address)
            .department(department)
            .enrollDate(enrollDate)
            .status(StudentStatus.ACTIVE)
            .build()));
    }

    private Course ensureCourse(String code, String title, String description, int credits,
                Department department, Teacher teacher) {
    return courseRepository.findByCode(code)
        .orElseGet(() -> courseRepository.save(Course.builder()
            .code(code)
            .title(title)
            .description(description)
            .credits(credits)
            .department(department)
            .teacher(teacher)
            .build()));
    }

    private void seedAttendanceSample(Student student, Course course, LocalDate date, AttendanceStatus status) {
    AttendanceId id = AttendanceId.builder()
        .studentId(student.getId())
        .courseId(course.getId())
        .date(date)
        .build();
    if (!attendanceRepository.existsById(id)) {
        attendanceRepository.save(Attendance.builder()
            .id(id)
            .student(student)
            .course(course)
            .status(status)
            .build());
    }
    }

    private void seedMarksSample(Student student, Course course, String examType,
                 BigDecimal marksObtained, BigDecimal maxMarks) {
    MarkId id = MarkId.builder()
        .studentId(student.getId())
        .courseId(course.getId())
        .examType(examType)
        .build();
    if (!markRepository.existsById(id)) {
        markRepository.save(Mark.builder()
            .id(id)
            .student(student)
            .course(course)
            .marksObtained(marksObtained)
            .maxMarks(maxMarks)
            .build());
    }
    }
}
