package com.taskmanager.notificationservice.dto;

import lombok.*;
import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TaskEvent implements Serializable {
    private String title;
    private String description;
    private String assignedTo;
    private String status;
}

