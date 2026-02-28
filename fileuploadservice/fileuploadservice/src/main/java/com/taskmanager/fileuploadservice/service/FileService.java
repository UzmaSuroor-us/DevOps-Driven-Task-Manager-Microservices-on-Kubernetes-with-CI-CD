package com.taskmanager.fileuploadservice.service;

import com.taskmanager.fileuploadservice.entity.FileMetadata;
import com.taskmanager.fileuploadservice.repository.FileMetadataRepository;
import com.taskmanager.fileuploadservice.storage.FileStorage;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FileService {

    private final FileStorage fileStorage;
    private final FileMetadataRepository fileMetadataRepository;

    public String upload(MultipartFile file) {
        String result = fileStorage.uploadFile(file);
        
        FileMetadata metadata = new FileMetadata();
        metadata.setFileName(file.getOriginalFilename());
        metadata.setFilePath(result);
        metadata.setFileSize(file.getSize());
        metadata.setContentType(file.getContentType());
        fileMetadataRepository.save(metadata);
        
        return result;
    }

    public List<String> getAllFiles() {
        return fileMetadataRepository.findAll()
            .stream()
            .map(FileMetadata::getFileName)
            .collect(Collectors.toList());
    }

    public InputStream download(String filename) {
        return fileStorage.downloadFile(filename);
    }

    @Transactional
    public void delete(String filename) {
        fileStorage.deleteFile(filename);
        fileMetadataRepository.deleteByFileName(filename);
    }
}

