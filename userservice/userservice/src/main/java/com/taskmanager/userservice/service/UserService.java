package com.taskmanager.userservice.service;

import com.taskmanager.userservice.dto.LoginRequest;
import com.taskmanager.userservice.dto.RegisterRequest;
import com.taskmanager.userservice.dto.AuthResponse;
import org.springframework.http.ResponseEntity;

public interface UserService {
    ResponseEntity<?> register(RegisterRequest request);
    AuthResponse login(LoginRequest request);
    boolean userExists(Long userId);
}

