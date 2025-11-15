package com.sms.entity;

import jakarta.persistence.Embeddable;
import java.io.Serializable;
import lombok.*;

@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MarkId implements Serializable {
    private Long studentId;
    private Long courseId;
    private String examType;
}
