package com.sms.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class RootController {

    @GetMapping("/")
    public ResponseEntity<Map<String, Object>> welcome() {
        return ResponseEntity.ok(Map.of(
                "message", "Student Management System API is running",
                "docs", "/swagger-ui/index.html",
                "health", "/actuator/health",
                "loginHint", "Use POST /api/auth/login with a valid user"
        ));
    }
}
