package com.taskmanager.fileuploadservice.repository;

import com.taskmanager.fileuploadservice.entity.FileMetadata;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FileMetadataRepository extends JpaRepository<FileMetadata, Long> {
    FileMetadata findByFileName(String fileName);
    void deleteByFileName(String fileName);
}
