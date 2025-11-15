package com.sms.service;

import com.sms.dto.Dtos;
import com.sms.entity.*;
import com.sms.exception.ResourceNotFoundException;
import com.sms.repository.*;
import java.math.BigDecimal;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EngagementService {

    private final AttendanceRepository attendanceRepository;
    private final MarkRepository markRepository;
    private final StudentRepository studentRepository;
    private final CourseRepository courseRepository;

    public Dtos.AttendanceResponse markAttendance(Dtos.AttendanceRequest request) {
        Student student = studentRepository.findById(request.studentId())
                .orElseThrow(() -> new ResourceNotFoundException("Student not found"));
        Course course = courseRepository.findById(request.courseId())
                .orElseThrow(() -> new ResourceNotFoundException("Course not found"));
        Attendance attendance = Attendance.builder()
                .id(AttendanceId.builder()
                        .studentId(student.getId())
                        .courseId(course.getId())
                        .date(request.date())
                        .build())
                .student(student)
                .course(course)
                .status(request.status())
                .build();
        attendanceRepository.save(attendance);
        return new Dtos.AttendanceResponse(student.getId(), course.getId(), request.date(), request.status());
    }

    public List<Dtos.AttendanceResponse> listAttendance(Long courseId) {
        return attendanceRepository.findByCourseId(courseId).stream()
                .map(a -> new Dtos.AttendanceResponse(a.getStudent().getId(), a.getCourse().getId(),
                        a.getId().getDate(), a.getStatus()))
                .toList();
    }

    public Dtos.MarkResponse recordMark(Dtos.MarkRequest request) {
        Student student = studentRepository.findById(request.studentId())
                .orElseThrow(() -> new ResourceNotFoundException("Student not found"));
        Course course = courseRepository.findById(request.courseId())
                .orElseThrow(() -> new ResourceNotFoundException("Course not found"));
        BigDecimal marksObtained = request.marksObtained();
        BigDecimal maxMarks = request.maxMarks();
        if (marksObtained.compareTo(maxMarks) > 0) {
            throw new IllegalArgumentException("marksObtained > maxMarks");
        }
        Mark mark = Mark.builder()
                .id(MarkId.builder()
                        .studentId(student.getId())
                        .courseId(course.getId())
                        .examType(request.examType())
                        .build())
                .student(student)
                .course(course)
                .marksObtained(marksObtained)
                .maxMarks(maxMarks)
                .build();
        markRepository.save(mark);
        return new Dtos.MarkResponse(student.getId(), course.getId(), request.examType(), marksObtained, maxMarks);
    }

    public List<Dtos.MarkResponse> listMarks(Long courseId) {
        return markRepository.findAll().stream()
                .filter(m -> courseId == null || m.getCourse().getId().equals(courseId))
                .map(m -> new Dtos.MarkResponse(m.getStudent().getId(), m.getCourse().getId(),
                        m.getId().getExamType(), m.getMarksObtained(), m.getMaxMarks()))
                .toList();
    }
}
