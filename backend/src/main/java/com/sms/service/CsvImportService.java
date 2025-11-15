package com.sms.service;

import com.sms.dto.Dtos;
import com.sms.util.CsvStudentParser;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
public class CsvImportService {

    private final CsvStudentParser parser;
    private final AcademicService academicService;

    public Dtos.CsvImportResponse importStudents(MultipartFile file) throws IOException {
        var rows = parser.parse(file);
        int success = 0;
        var errors = new java.util.ArrayList<Dtos.CsvRowError>();
        int rowIndex = 1;
        for (Dtos.StudentRequest request : rows) {
            try {
                academicService.createStudent(request);
                success++;
            } catch (Exception ex) {
                errors.add(new Dtos.CsvRowError(rowIndex, ex.getMessage()));
            }
            rowIndex++;
        }
        return new Dtos.CsvImportResponse(rows.size(), success, rows.size() - success, errors);
    }
}
