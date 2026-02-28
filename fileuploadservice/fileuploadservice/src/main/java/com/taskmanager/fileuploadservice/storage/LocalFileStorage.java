package com.taskmanager.fileuploadservice.storage;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.nio.file.*;

@Component
@RequiredArgsConstructor
public class LocalFileStorage implements FileStorage {

    @Value("${storage.location}")
    private String uploadDir;

    @Override
    public String uploadFile(MultipartFile file) {
        try {
            Path path = Paths.get(uploadDir, file.getOriginalFilename());
            Files.createDirectories(path.getParent());
            file.transferTo(path);
            return "File uploaded locally: " + path.toString();
        } catch (IOException e) {
            throw new RuntimeException("Failed to upload", e);
        }
    }

    @Override
    public InputStream downloadFile(String filename) {
        try {
            Path path = Paths.get(uploadDir, filename);
            return new FileInputStream(path.toFile());
        } catch (IOException e) {
            throw new RuntimeException("File not found", e);
        }
    }

    @Override
    public java.util.List<String> listFiles() {
        try {
            Path path = Paths.get(uploadDir);
            if (!Files.exists(path)) {
                return java.util.Collections.emptyList();
            }
            return Files.list(path)
                .filter(Files::isRegularFile)
                .map(p -> p.getFileName().toString())
                .collect(java.util.stream.Collectors.toList());
        } catch (IOException e) {
            return java.util.Collections.emptyList();
        }
    }

    @Override
    public void deleteFile(String filename) {
        try {
            Path path = Paths.get(uploadDir, filename);
            Files.deleteIfExists(path);
        } catch (IOException e) {
            throw new RuntimeException("Failed to delete file", e);
        }
    }
}

