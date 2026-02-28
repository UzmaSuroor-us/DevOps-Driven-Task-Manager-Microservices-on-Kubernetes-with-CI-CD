package com.taskmanager.projectservice.dto;

import lombok.*;
import java.util.List;

@Data
public class ProjectRequest {
    private String name;
    private String description;
    private List<String> members;
}
