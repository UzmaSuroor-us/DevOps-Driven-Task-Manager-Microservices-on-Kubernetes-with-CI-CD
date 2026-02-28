
package com.taskmanager.taskservice.service;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

@FeignClient(name = "project-service")
public interface ProjectClient {
    @GetMapping("/api/projects/{id}")
    void projectExists(@PathVariable Long id);
}

