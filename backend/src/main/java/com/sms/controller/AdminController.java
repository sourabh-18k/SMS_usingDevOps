package com.sms.controller;

import com.sms.dto.Dtos;
import com.sms.service.CsvImportService;
import com.sms.service.DashboardService;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final DashboardService dashboardService;
    private final CsvImportService csvImportService;

    @GetMapping("/dashboard")
    public Dtos.DashboardMetrics dashboard() {
        return dashboardService.metrics();
    }

    @PostMapping("/students/bulk-upload")
    @PreAuthorize("hasRole('ADMIN')")
    public Dtos.CsvImportResponse bulkUpload(@RequestParam("file") MultipartFile file) throws IOException {
        return csvImportService.importStudents(file);
    }
}
