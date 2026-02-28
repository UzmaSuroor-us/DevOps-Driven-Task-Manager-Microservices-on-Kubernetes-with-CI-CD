package com.taskmanager.taskservice.service;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

@FeignClient(name = "user-service")
public interface UserClient {

  @GetMapping("/auth/check/{username}")
   boolean userExists(@PathVariable String username);
}    
