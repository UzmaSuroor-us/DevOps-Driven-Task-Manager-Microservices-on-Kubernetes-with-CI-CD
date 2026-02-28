package com.taskmanager.projectservice.controller;

import com.taskmanager.projectservice.dto.ProjectRequest;
import com.taskmanager.projectservice.entity.Project;
import com.taskmanager.projectservice.service.ProjectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/projects")
public class ProjectController {

    @Autowired
    private ProjectService service;

    @PostMapping
    public Project createProject(@RequestBody ProjectRequest request) {
        return service.create(request);
    }

    @GetMapping("/{id}")
    public Project getProject(@PathVariable Long id) {
        return service.getById(id);
    }
    @GetMapping
    public List<Project> getAllProjects() {
         return service.getAll();
    }

    @PutMapping("/{id}")
    public Project updateProject(@PathVariable Long id, @RequestBody ProjectRequest request) {
         return service.update(id, request);
    }

    @DeleteMapping("/{id}")
    public String deleteProject(@PathVariable Long id) {
         service.delete(id);
         return "Project deleted successfully";
   }
}

