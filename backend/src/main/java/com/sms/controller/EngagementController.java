package com.sms.controller;

import com.sms.dto.Dtos;
import com.sms.service.EngagementService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class EngagementController {

    private final EngagementService engagementService;

    @PostMapping("/attendance")
    @PreAuthorize("hasAnyRole('ADMIN','TEACHER')")
    public Dtos.AttendanceResponse markAttendance(@Valid @RequestBody Dtos.AttendanceRequest request) {
        return engagementService.markAttendance(request);
    }

    @GetMapping("/attendance")
    public java.util.List<Dtos.AttendanceResponse> listAttendance(@RequestParam(required = false) Long courseId) {
        return engagementService.listAttendance(courseId);
    }

    @PostMapping("/marks")
    @PreAuthorize("hasAnyRole('ADMIN','TEACHER')")
    public Dtos.MarkResponse recordMark(@Valid @RequestBody Dtos.MarkRequest request) {
        return engagementService.recordMark(request);
    }

    @GetMapping("/marks")
    public java.util.List<Dtos.MarkResponse> listMarks(@RequestParam(required = false) Long courseId) {
        return engagementService.listMarks(courseId);
    }
}
