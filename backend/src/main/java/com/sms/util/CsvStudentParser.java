package com.sms.util;

import com.sms.dto.Dtos;
import com.sms.entity.StudentStatus;
import com.sms.repository.DepartmentRepository;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

@Component
@RequiredArgsConstructor
public class CsvStudentParser {

    private final DepartmentRepository departmentRepository;

    public List<Dtos.StudentRequest> parse(MultipartFile file) throws IOException {
        List<Dtos.StudentRequest> rows = new ArrayList<>();
        try (var reader = new BufferedReader(new InputStreamReader(file.getInputStream()));
             var parser = new CSVParser(reader, CSVFormat.DEFAULT.withFirstRecordAsHeader())) {
            parser.forEach(record -> {
                Long departmentId = departmentRepository.findByCode(record.get("departmentCode"))
                        .map(com.sms.entity.Department::getId)
                        .orElseThrow(() -> new IllegalArgumentException("Unknown department " + record.get("departmentCode")));
                rows.add(new Dtos.StudentRequest(
                        record.get("rollNo"),
                        record.get("firstName"),
                        record.get("lastName"),
                        record.get("email"),
                        record.get("phone"),
                        LocalDate.parse(record.get("dob")),
                        record.get("gender"),
                        record.get("address"),
                        departmentId,
                        LocalDate.parse(record.get("enrollDate")),
                        record.get("profilePhotoUrl"),
                        StudentStatus.valueOf(record.get("status").toUpperCase())
                ));
            });
        }
        return rows;
    }
}
