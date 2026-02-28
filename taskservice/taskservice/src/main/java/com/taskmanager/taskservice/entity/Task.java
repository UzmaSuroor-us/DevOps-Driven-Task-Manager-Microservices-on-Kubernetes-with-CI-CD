package com.taskmanager.taskservice.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Task {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String description;

    private String status; // TO_DO, IN_PROGRESS, DONE

    private String assignedTo; // username from user-service

    private Long projectId; // reference to project-service
    
    private String fileId; // reference to file-upload-service (optional)
}

