package com.sms.entity;

import jakarta.persistence.Embeddable;
import java.io.Serializable;
import java.time.LocalDate;
import lombok.*;

@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AttendanceId implements Serializable {
    private Long studentId;
    private Long courseId;
    private LocalDate date;
}
