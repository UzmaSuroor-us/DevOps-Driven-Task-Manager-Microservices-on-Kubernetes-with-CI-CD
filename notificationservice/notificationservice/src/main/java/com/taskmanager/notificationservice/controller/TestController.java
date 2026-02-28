package com.taskmanager.notificationservice.controller;

import com.taskmanager.notificationservice.dto.TaskEvent;
import lombok.RequiredArgsConstructor;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class TestController {

    private final RabbitTemplate rabbitTemplate;

    @GetMapping("/test")
    public String test() {
        return "Notification service is working!";
    }

    @PostMapping("/notify")
    public String sendTestNotification(@RequestBody TaskEvent event) {
        rabbitTemplate.convertAndSend("task.notifications", event);
        return "Notification event sent to RabbitMQ";
    }
}

