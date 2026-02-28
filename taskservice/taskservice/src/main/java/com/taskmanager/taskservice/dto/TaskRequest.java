package com.taskmanager.taskservice.dto;

import lombok.*;

@Data
public class TaskRequest {
    private String title;
    private String description;
    private String status;
    private String assignedTo;
    private Long projectId;
}

