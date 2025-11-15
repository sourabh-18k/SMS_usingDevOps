package com.sms.controller;

import com.sms.dto.Dtos;
import com.sms.service.AcademicService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class AcademicController {

    private final AcademicService academicService;

    @GetMapping("/students")
    public Dtos.PageResponse<Dtos.StudentResponse> students(@RequestParam(defaultValue = "") String search,
                                                            @RequestParam(defaultValue = "0") int page,
                                                            @RequestParam(defaultValue = "20") int size) {
        return academicService.listStudents(search, page, size);
    }

    @PostMapping("/students")
    @PreAuthorize("hasRole('ADMIN')")
    public Dtos.StudentResponse createStudent(@Valid @RequestBody Dtos.StudentRequest request) {
        return academicService.createStudent(request);
    }

    @PutMapping("/students/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','TEACHER')")
    public Dtos.StudentResponse updateStudent(@PathVariable Long id, @Valid @RequestBody Dtos.StudentRequest request) {
        return academicService.updateStudent(id, request);
    }

    @DeleteMapping("/students/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public void deleteStudent(@PathVariable Long id) {
        academicService.deleteStudent(id);
    }

    @GetMapping("/teachers")
    public Dtos.PageResponse<Dtos.TeacherResponse> teachers(@RequestParam(defaultValue = "0") int page,
                                                            @RequestParam(defaultValue = "20") int size) {
        return academicService.listTeachers(page, size);
    }

    @PostMapping("/teachers")
    @PreAuthorize("hasRole('ADMIN')")
    public Dtos.TeacherResponse createTeacher(@Valid @RequestBody Dtos.TeacherRequest request) {
        return academicService.createTeacher(request);
    }

    @GetMapping("/courses")
    public Dtos.PageResponse<Dtos.CourseResponse> courses(@RequestParam(defaultValue = "") String title,
                                                          @RequestParam(defaultValue = "0") int page,
                                                          @RequestParam(defaultValue = "20") int size) {
        return academicService.listCourses(title, page, size);
    }

    @PostMapping("/courses")
    @PreAuthorize("hasAnyRole('ADMIN','TEACHER')")
    public Dtos.CourseResponse createCourse(@Valid @RequestBody Dtos.CourseRequest request) {
        return academicService.createCourse(request);
    }

    @GetMapping("/departments")
    public java.util.List<Dtos.DepartmentResponse> departments() {
        return academicService.listDepartments();
    }

    @PostMapping("/departments")
    @PreAuthorize("hasRole('ADMIN')")
    public Dtos.DepartmentResponse createDepartment(@Valid @RequestBody Dtos.DepartmentRequest request) {
        return academicService.createDepartment(request);
    }

    @PostMapping("/enrollments")
    @PreAuthorize("hasAnyRole('ADMIN','TEACHER')")
    public Dtos.EnrollmentResponse enroll(@Valid @RequestBody Dtos.EnrollmentRequest request) {
        return academicService.enrollStudent(request);
    }
}
