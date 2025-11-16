package com.sms.repository;

import com.sms.entity.Course;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CourseRepository extends JpaRepository<Course, Long> {
    Page<Course> findByTitleContainingIgnoreCase(String title, Pageable pageable);
    Optional<Course> findByCode(String code);
}
