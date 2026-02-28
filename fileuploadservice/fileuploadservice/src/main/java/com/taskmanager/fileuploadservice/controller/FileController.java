package com.taskmanager.fileuploadservice.controller;

import java.io.InputStream;
import com.taskmanager.fileuploadservice.service.FileService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/files")
@RequiredArgsConstructor
public class FileController {

    private final FileService fileService;

    @PostMapping("/upload")
    public ResponseEntity<String> upload(@RequestParam("file") MultipartFile file) {
        String message = fileService.upload(file);
        return ResponseEntity.ok(message);
    }

    @GetMapping
    public ResponseEntity<?> getAllFiles() {
        return ResponseEntity.ok(fileService.getAllFiles());
    }

    @GetMapping("/health")
    public String health() {
        return "File upload service is working!";
    }

    @GetMapping("/download/{filename}")
    public ResponseEntity<InputStreamResource> download(@PathVariable String filename) {
        InputStream inputStream = fileService.download(filename);
        InputStreamResource resource = new InputStreamResource(inputStream);

        return ResponseEntity.ok()
            .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
            .contentType(MediaType.APPLICATION_OCTET_STREAM)
            .body(resource);
    }

    @DeleteMapping("/{filename}")
    public ResponseEntity<String> delete(@PathVariable String filename) {
        fileService.delete(filename);
        return ResponseEntity.ok("File deleted successfully");
    }

}

