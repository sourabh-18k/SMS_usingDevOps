package com.sms.repository;

import com.sms.entity.Enrollment;
import com.sms.entity.EnrollmentId;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EnrollmentRepository extends JpaRepository<Enrollment, EnrollmentId> {
}
