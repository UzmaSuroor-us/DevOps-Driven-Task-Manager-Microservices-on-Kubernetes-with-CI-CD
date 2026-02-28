package com.taskmanager.fileuploadservice.storage;

import org.springframework.web.multipart.MultipartFile;
import java.io.InputStream;
import java.util.List;

public interface FileStorage {
    String uploadFile(MultipartFile file);
    InputStream downloadFile(String filename);
    List<String> listFiles();
    void deleteFile(String filename);
}

