package com.sms.repository;

import com.sms.entity.Student;
import com.sms.entity.StudentStatus;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StudentRepository extends JpaRepository<Student, Long> {
    Page<Student> findByFirstNameContainingIgnoreCaseOrLastNameContainingIgnoreCase(String first, String last, Pageable pageable);
    long countByStatus(StudentStatus status);
    Optional<Student> findByRollNo(String rollNo);
}
