package com.sms.service;

import com.sms.dto.Dtos;
import com.sms.entity.StudentStatus;
import com.sms.repository.AttendanceRepository;
import com.sms.repository.CourseRepository;
import com.sms.repository.MarkRepository;
import com.sms.repository.StudentRepository;
import com.sms.repository.TeacherRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final StudentRepository studentRepository;
    private final TeacherRepository teacherRepository;
    private final CourseRepository courseRepository;
    private final AttendanceRepository attendanceRepository;
    private final MarkRepository markRepository;

    public Dtos.DashboardMetrics metrics() {
        long students = studentRepository.count();
        long teachers = teacherRepository.count();
        long courses = courseRepository.count();
        Double avgAttendance = attendanceRepository.findAverageAttendance();
        List<Dtos.TopPerformer> top = markRepository.findTopPerformers(Pageable.ofSize(5)).stream()
                .map(row -> new Dtos.TopPerformer(
                        (Long) row[0],
                        row[1] + " " + row[2],
                        ((Double) row[3]) * 100))
                .toList();
        return new Dtos.DashboardMetrics(
                students,
                teachers,
                courses,
                avgAttendance == null ? 0 : Math.round(avgAttendance * 1000) / 10.0,
                top);
    }

    public long activeStudents() {
        return studentRepository.countByStatus(StudentStatus.ACTIVE);
    }
}
