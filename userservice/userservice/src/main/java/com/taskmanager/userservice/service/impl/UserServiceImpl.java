package com.taskmanager.userservice.service.impl;

import com.taskmanager.userservice.dto.AuthResponse;
import com.taskmanager.userservice.dto.LoginRequest;
import com.taskmanager.userservice.dto.RegisterRequest;
import com.taskmanager.userservice.entity.User;
import com.taskmanager.userservice.repository.UserRepository;
import com.taskmanager.userservice.security.JwtUtil;
import com.taskmanager.userservice.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepo;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManager authManager;

    @Override
    public ResponseEntity<?> register(RegisterRequest request) {
        if (userRepo.findByEmail(request.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body("Email already exists");
        }

        User user = new User();
        user.setUsername(request.getName());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        userRepo.save(user);
        return ResponseEntity.ok("User registered successfully");
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        authManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );
        String token = jwtUtil.generateToken(request.getEmail());
        return new AuthResponse(token);
    }

    @Override
    public boolean userExists(Long userId) {
        return userRepo.findById(userId).isPresent();
    }
}

