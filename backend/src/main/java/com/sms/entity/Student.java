package com.sms.entity;

import jakarta.persistence.*;
import java.time.LocalDate;
import lombok.*;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Student {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String rollNo;

    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private LocalDate dob;
    private String gender;
    private String address;

    @ManyToOne(fetch = FetchType.LAZY)
    private Department department;

    private LocalDate enrollDate;
    private String profilePhotoUrl;

    @Enumerated(EnumType.STRING)
    private StudentStatus status;
}
