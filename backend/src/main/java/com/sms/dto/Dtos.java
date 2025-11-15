package com.sms.dto;

import com.sms.entity.AttendanceStatus;
import com.sms.entity.RoleType;
import com.sms.entity.StudentStatus;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;

public final class Dtos {
    private Dtos() {}

    public record AuthRequest(@Email @NotBlank String email, @NotBlank String password) {}
    public record RegisterRequest(@NotBlank String fullName,
                                  @Email @NotBlank String email,
                                  @Size(min = 8) String password,
                                  @NotNull RoleType role) {}
    public record AuthResponse(String token, String role, Instant expiresAt) {}

    public record StudentRequest(
            @NotBlank String rollNo,
            @NotBlank String firstName,
            @NotBlank String lastName,
            @Email @NotBlank String email,
            @Pattern(regexp = "\\d{10,15}") String phone,
            @NotNull LocalDate dob,
            @NotBlank String gender,
            @NotBlank String address,
            @NotNull Long departmentId,
            @NotNull LocalDate enrollDate,
            String profilePhotoUrl,
            @NotNull StudentStatus status
    ) {}

    public record StudentResponse(
            Long id,
            String rollNo,
            String firstName,
            String lastName,
            String email,
            String phone,
            LocalDate dob,
            String gender,
            String address,
            Long departmentId,
            LocalDate enrollDate,
            String profilePhotoUrl,
            StudentStatus status
    ) {}

    public record TeacherRequest(
            @NotBlank String employeeId,
            @NotBlank String name,
            @Email String email,
            @Pattern(regexp = "\\d{10,15}") String phone,
            @NotNull Long departmentId,
            List<String> subjects
    ) {}

    public record TeacherResponse(
            Long id,
            String employeeId,
            String name,
            String email,
            String phone,
            Long departmentId,
            List<String> subjects
    ) {}

    public record CourseRequest(
            @NotBlank String code,
            @NotBlank String title,
            String description,
            @Positive int credits,
            @NotNull Long departmentId,
            Long teacherId
    ) {}

    public record CourseResponse(
            Long id,
            String code,
            String title,
            String description,
            int credits,
            Long departmentId,
            Long teacherId
    ) {}

    public record DepartmentRequest(
            @NotBlank String code,
            @NotBlank String name,
            String description
    ) {}

    public record DepartmentResponse(
            Long id,
            String code,
            String name,
            String description
    ) {}

    public record EnrollmentRequest(
            @NotNull Long studentId,
            @NotNull Long courseId,
            @NotBlank String semester,
            @NotBlank String status
    ) {}

    public record EnrollmentResponse(
            Long studentId,
            Long courseId,
            String semester,
            String status
    ) {}

    public record AttendanceRequest(
            @NotNull Long studentId,
            @NotNull Long courseId,
            @NotNull LocalDate date,
            @NotNull AttendanceStatus status
    ) {}

    public record AttendanceResponse(
            Long studentId,
            Long courseId,
            LocalDate date,
            AttendanceStatus status
    ) {}

    public record MarkRequest(
            @NotNull Long studentId,
            @NotNull Long courseId,
            @NotBlank String examType,
            @DecimalMin("0.0") BigDecimal marksObtained,
            @DecimalMin("1.0") BigDecimal maxMarks
    ) {}

    public record MarkResponse(
            Long studentId,
            Long courseId,
            String examType,
            BigDecimal marksObtained,
            BigDecimal maxMarks
    ) {}

    public record TopPerformer(
            Long studentId,
            String fullName,
            double score
    ) {}

    public record DashboardMetrics(
            long totalStudents,
            long totalTeachers,
            long totalCourses,
            double averageAttendance,
            List<TopPerformer> topPerformers
    ) {}

    public record CsvImportResponse(int processed, int succeeded, int failed, List<CsvRowError> errors) {}
    public record CsvRowError(int row, String message) {}

    public record PageResponse<T>(List<T> content, long totalElements, int totalPages, int page, int size) {}
}
