package com.sms.service;

import com.sms.dto.Dtos;
import com.sms.entity.AppUser;
import com.sms.exception.BadRequestException;
import com.sms.repository.AppUserRepository;
import com.sms.security.JwtService;
import java.time.Instant;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AppUserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;

    public Dtos.AuthResponse register(Dtos.RegisterRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            throw new BadRequestException("Email already registered");
        }
        AppUser user = AppUser.builder()
                .fullName(request.fullName())
                .email(request.email())
                .password(passwordEncoder.encode(request.password()))
                .role(request.role())
                .build();
        userRepository.save(user);
        String token = jwtService.generateToken(user);
        return new Dtos.AuthResponse(token, user.getRole().name(), Instant.now().plusMillis(86400000));
    }

    public Dtos.AuthResponse login(Dtos.AuthRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.email(), request.password()));
        AppUser user = userRepository.findByEmail(request.email()).orElseThrow();
        String token = jwtService.generateToken(user);
        return new Dtos.AuthResponse(token, user.getRole().name(), Instant.now().plusMillis(86400000));
    }
}
