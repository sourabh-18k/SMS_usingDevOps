package com.sms.service;

import com.sms.entity.AppUser;
import com.sms.entity.RoleType;
import com.sms.repository.AppUserRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataInitializer {

    private final AppUserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @PostConstruct
    public void seedAdmin() {
        if (!userRepository.existsByEmail("admin@sms.dev")) {
            AppUser admin = AppUser.builder()
                    .fullName("Platform Admin")
                    .email("admin@sms.dev")
                    .password(passwordEncoder.encode("ChangeMe123!"))
                    .role(RoleType.ADMIN)
                    .build();
            userRepository.save(admin);
        }
    }
}
