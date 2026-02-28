package com.taskmanager.taskservice.controller;

import com.taskmanager.taskservice.dto.TaskRequest;
import com.taskmanager.taskservice.entity.Task;
import com.taskmanager.taskservice.service.TaskService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/tasks")
public class TaskController {

    @Autowired
    private TaskService service;

    @PostMapping
    public Task create(@RequestBody TaskRequest request) {
        return service.create(request);
    }

    @GetMapping
    public List<Task> getAll() {
        return service.getAll();
    }

    @PutMapping("/{id}")
    public Task update(@PathVariable Long id, @RequestBody TaskRequest request) {
        return service.update(id, request);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable Long id) {
        service.delete(id);
        return "Task deleted";
    }

    @PatchMapping("/{id}/status")
    public Task updateStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        return service.updateStatus(id, body.get("status"));
    }
}

