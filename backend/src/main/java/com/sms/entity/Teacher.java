package com.sms.entity;

import jakarta.persistence.*;
import java.util.List;
import lombok.*;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Teacher {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String employeeId;

    private String name;
    private String email;
    private String phone;

    @ManyToOne(fetch = FetchType.LAZY)
    private Department department;

    @ElementCollection
    private List<String> subjects;
}
