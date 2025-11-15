package com.sms.repository;

import com.sms.entity.Mark;
import com.sms.entity.MarkId;
import java.util.List;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface MarkRepository extends JpaRepository<Mark, MarkId> {

    @Query("SELECT m.student.id, m.student.firstName, m.student.lastName, AVG(m.marksObtained / m.maxMarks) " +
            "FROM Mark m GROUP BY m.student.id, m.student.firstName, m.student.lastName ORDER BY AVG(m.marksObtained / m.maxMarks) DESC")
    List<Object[]> findTopPerformers(Pageable pageable);
}
