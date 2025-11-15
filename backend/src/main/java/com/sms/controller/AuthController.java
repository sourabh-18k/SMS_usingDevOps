package com.sms.controller;

import com.sms.dto.Dtos;
import com.sms.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public Dtos.AuthResponse register(@Valid @RequestBody Dtos.RegisterRequest request) {
        return authService.register(request);
    }

    @PostMapping("/login")
    public Dtos.AuthResponse login(@Valid @RequestBody Dtos.AuthRequest request) {
        return authService.login(request);
    }
}
