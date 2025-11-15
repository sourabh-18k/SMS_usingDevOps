package com.sms.service;

import com.sms.dto.Dtos;
import com.sms.entity.*;
import com.sms.exception.ResourceNotFoundException;
import com.sms.repository.*;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AcademicService {

    private final StudentRepository studentRepository;
    private final TeacherRepository teacherRepository;
    private final CourseRepository courseRepository;
    private final DepartmentRepository departmentRepository;
    private final EnrollmentRepository enrollmentRepository;

    public Dtos.PageResponse<Dtos.StudentResponse> listStudents(String search, int page, int size) {
        var pageable = PageRequest.of(page, size);
        var result = studentRepository
                .findByFirstNameContainingIgnoreCaseOrLastNameContainingIgnoreCase(search, search, pageable);
        List<Dtos.StudentResponse> content = result.getContent().stream().map(this::toStudentResponse).toList();
        return new Dtos.PageResponse<>(content, result.getTotalElements(), result.getTotalPages(), page, size);
    }

    public Dtos.StudentResponse createStudent(Dtos.StudentRequest request) {
        Department department = departmentRepository.findById(request.departmentId())
                .orElseThrow(() -> new ResourceNotFoundException("Department not found"));
        Student student = Student.builder()
                .rollNo(request.rollNo())
                .firstName(request.firstName())
                .lastName(request.lastName())
                .email(request.email())
                .phone(request.phone())
                .dob(request.dob())
                .gender(request.gender())
                .address(request.address())
                .department(department)
                .enrollDate(request.enrollDate())
                .profilePhotoUrl(request.profilePhotoUrl())
                .status(request.status())
                .build();
        studentRepository.save(student);
        return toStudentResponse(student);
    }

    public Dtos.StudentResponse updateStudent(Long id, Dtos.StudentRequest request) {
        Student student = studentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found"));
        Department department = departmentRepository.findById(request.departmentId())
                .orElseThrow(() -> new ResourceNotFoundException("Department not found"));
        student.setRollNo(request.rollNo());
        student.setFirstName(request.firstName());
        student.setLastName(request.lastName());
        student.setEmail(request.email());
        student.setPhone(request.phone());
        student.setDob(request.dob());
        student.setGender(request.gender());
        student.setAddress(request.address());
        student.setDepartment(department);
        student.setEnrollDate(request.enrollDate());
        student.setProfilePhotoUrl(request.profilePhotoUrl());
        student.setStatus(request.status());
        return toStudentResponse(studentRepository.save(student));
    }

    public void deleteStudent(Long id) {
        studentRepository.deleteById(id);
    }

    public Dtos.PageResponse<Dtos.TeacherResponse> listTeachers(int page, int size) {
        var result = teacherRepository.findAll(PageRequest.of(page, size));
        var content = result.getContent().stream().map(this::toTeacherResponse).toList();
        return new Dtos.PageResponse<>(content, result.getTotalElements(), result.getTotalPages(), page, size);
    }

    public Dtos.TeacherResponse createTeacher(Dtos.TeacherRequest request) {
        Department dept = departmentRepository.findById(request.departmentId())
                .orElseThrow(() -> new ResourceNotFoundException("Department not found"));
        Teacher teacher = Teacher.builder()
                .employeeId(request.employeeId())
                .name(request.name())
                .email(request.email())
                .phone(request.phone())
                .department(dept)
                .subjects(request.subjects())
                .build();
        teacherRepository.save(teacher);
        return toTeacherResponse(teacher);
    }

    public Dtos.PageResponse<Dtos.CourseResponse> listCourses(String title, int page, int size) {
        var result = courseRepository.findByTitleContainingIgnoreCase(title, PageRequest.of(page, size));
        var content = result.getContent().stream().map(this::toCourseResponse).toList();
        return new Dtos.PageResponse<>(content, result.getTotalElements(), result.getTotalPages(), page, size);
    }

    public Dtos.CourseResponse createCourse(Dtos.CourseRequest request) {
        Department dept = departmentRepository.findById(request.departmentId())
                .orElseThrow(() -> new ResourceNotFoundException("Department not found"));
        Teacher teacher = null;
        if (request.teacherId() != null) {
            teacher = teacherRepository.findById(request.teacherId())
                    .orElseThrow(() -> new ResourceNotFoundException("Teacher not found"));
        }
        Course course = Course.builder()
                .code(request.code())
                .title(request.title())
                .description(request.description())
                .credits(request.credits())
                .department(dept)
                .teacher(teacher)
                .build();
        courseRepository.save(course);
        return toCourseResponse(course);
    }

    public List<Dtos.DepartmentResponse> listDepartments() {
        return departmentRepository.findAll().stream()
                .map(dept -> new Dtos.DepartmentResponse(dept.getId(), dept.getCode(), dept.getName(), dept.getDescription()))
                .toList();
    }

    public Dtos.DepartmentResponse createDepartment(Dtos.DepartmentRequest request) {
        Department dept = Department.builder()
                .code(request.code())
                .name(request.name())
                .description(request.description())
                .build();
        departmentRepository.save(dept);
        return new Dtos.DepartmentResponse(dept.getId(), dept.getCode(), dept.getName(), dept.getDescription());
    }

    public Dtos.EnrollmentResponse enrollStudent(Dtos.EnrollmentRequest request) {
        Student student = studentRepository.findById(request.studentId())
                .orElseThrow(() -> new ResourceNotFoundException("Student not found"));
        Course course = courseRepository.findById(request.courseId())
                .orElseThrow(() -> new ResourceNotFoundException("Course not found"));
        Enrollment enrollment = Enrollment.builder()
                .id(new EnrollmentId(student.getId(), course.getId(), request.semester()))
                .student(student)
                .course(course)
                .status(request.status())
                .build();
        enrollmentRepository.save(enrollment);
        return new Dtos.EnrollmentResponse(student.getId(), course.getId(), request.semester(), request.status());
    }

    private Dtos.StudentResponse toStudentResponse(Student s) {
        return new Dtos.StudentResponse(
                s.getId(), s.getRollNo(), s.getFirstName(), s.getLastName(), s.getEmail(),
                s.getPhone(), s.getDob(), s.getGender(), s.getAddress(),
                s.getDepartment() != null ? s.getDepartment().getId() : null,
                s.getEnrollDate(), s.getProfilePhotoUrl(), s.getStatus());
    }

    private Dtos.TeacherResponse toTeacherResponse(Teacher t) {
        return new Dtos.TeacherResponse(t.getId(), t.getEmployeeId(), t.getName(), t.getEmail(), t.getPhone(),
                t.getDepartment() != null ? t.getDepartment().getId() : null, t.getSubjects());
    }

    private Dtos.CourseResponse toCourseResponse(Course c) {
        return new Dtos.CourseResponse(c.getId(), c.getCode(), c.getTitle(), c.getDescription(), c.getCredits(),
                c.getDepartment() != null ? c.getDepartment().getId() : null,
                c.getTeacher() != null ? c.getTeacher().getId() : null);
    }
}
