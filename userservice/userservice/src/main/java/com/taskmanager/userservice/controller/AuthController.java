package com.taskmanager.userservice.controller;

import com.taskmanager.userservice.dto.AuthResponse;
import com.taskmanager.userservice.dto.LoginRequest;
import com.taskmanager.userservice.dto.RegisterRequest;
import com.taskmanager.userservice.entity.User;
import com.taskmanager.userservice.repository.UserRepository;
import com.taskmanager.userservice.security.JwtUtil;
import com.taskmanager.userservice.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;


@RestController
@RequiredArgsConstructor
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthenticationManager authManager;
    private final UserRepository userRepo;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final UserService userService;

    @PostMapping("/register")
    public ResponseEntity<Map<String, String>> register(@RequestBody RegisterRequest request) {
        if (userRepo.findByEmail(request.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Email already exists"));
        }

        User user = new User();
        user.setUsername(request.getName());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        userRepo.save(user);

        return ResponseEntity.ok(Map.of("message", "User registered successfully"));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest request) {
        authManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );

        String token = jwtUtil.generateToken(request.getEmail());
        return ResponseEntity.ok(new AuthResponse(token));
    }

    @GetMapping("/check/{username}")
    public ResponseEntity<Boolean> checkUser(@PathVariable String username) {
        boolean exists = userRepo.findByUsername(username).isPresent();
        return ResponseEntity.ok(exists);
    }

    @GetMapping("/{userId}/exists")
    public ResponseEntity<Boolean> userExists(@PathVariable Long userId) {
        boolean exists = userService.userExists(userId);
        return ResponseEntity.ok(exists);
    }
    @GetMapping("/all")
    public ResponseEntity<List<User>> getAllUsers() {
        List<User> users = userRepo.findAll();
        return ResponseEntity.ok(users);
    }

}

