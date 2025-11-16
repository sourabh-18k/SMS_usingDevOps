package com.sms.repository;

import com.sms.entity.Attendance;
import com.sms.entity.AttendanceId;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface AttendanceRepository extends JpaRepository<Attendance, AttendanceId> {

    @Query("SELECT AVG(CASE WHEN a.status = 'PRESENT' THEN 1.0 ELSE 0.0 END) FROM Attendance a")
    Double findAverageAttendance();

    List<Attendance> findByIdCourseId(Long courseId);
}
