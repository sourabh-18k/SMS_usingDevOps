package com.sms.service;

import com.sms.dto.Dtos;
import com.sms.entity.Department;
import com.sms.entity.Student;
import com.sms.entity.StudentStatus;
import com.sms.repository.DepartmentRepository;
import com.sms.repository.StudentRepository;
import java.time.LocalDate;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;

class StudentServiceTest {

    private final StudentRepository studentRepository = Mockito.mock(StudentRepository.class);
    private final DepartmentRepository departmentRepository = Mockito.mock(DepartmentRepository.class);
    private final AcademicService academicService = new AcademicService(studentRepository, null, null, departmentRepository, null);

    @Test
    void createStudentPersistsEntity() {
        Department dept = Department.builder().id(1L).code("CSE").name("CSE").build();
        when(departmentRepository.findById(1L)).thenReturn(Optional.of(dept));
        when(studentRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

        var request = new Dtos.StudentRequest(
                "2024CSE001", "Jamie", "Lee", "jamie@uni.dev", "5557770000",
                LocalDate.of(2004, 1, 1), "F", "Dorm 2", 1L,
                LocalDate.of(2022, 8, 1), null, StudentStatus.ACTIVE);

        var response = academicService.createStudent(request);

        assertThat(response.rollNo()).isEqualTo("2024CSE001");
        assertThat(response.departmentId()).isEqualTo(1L);
    }

    @Test
    void listStudentsReturnsPage() {
        when(studentRepository.findByFirstNameContainingIgnoreCaseOrLastNameContainingIgnoreCase(eq(""), eq(""), any(PageRequest.class)))
                .thenReturn(new PageImpl<>(java.util.List.of(Student.builder().id(1L).firstName("A").lastName("B").build())));
        var page = academicService.listStudents("", 0, 10);
        assertThat(page.content()).hasSize(1);
    }
}
