package com.taskmanager.userservice.dto;

import lombok.*;

@Data
public class RegisterRequest {
    private String name;
    private String email;
    private String password;
}

