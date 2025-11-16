package com.sms.repository;

import com.sms.entity.Teacher;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TeacherRepository extends JpaRepository<Teacher, Long> {
	Optional<Teacher> findByEmployeeId(String employeeId);
}
