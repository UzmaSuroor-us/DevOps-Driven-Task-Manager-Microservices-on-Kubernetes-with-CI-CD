package com.taskmanager.userservice.controller;

import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @GetMapping
    public List<Map<String, Object>> getAll() {
        return List.of(
            Map.of("id", 1, "username", "john", "email", "john@example.com"),
            Map.of("id", 2, "username", "jane", "email", "jane@example.com")
        );
    }

    @GetMapping("/test")
    public String test() {
        return "User service is working!";
    }
}
