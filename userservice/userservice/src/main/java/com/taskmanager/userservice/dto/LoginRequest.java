package com.taskmanager.userservice.dto;

import lombok.*;

@Data
public class LoginRequest {
    private String email;
    private String password;
}

