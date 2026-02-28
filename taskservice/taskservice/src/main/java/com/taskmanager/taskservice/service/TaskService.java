package com.taskmanager.taskservice.service;

import com.taskmanager.taskservice.dto.TaskRequest;
import com.taskmanager.taskservice.entity.Task;
import com.taskmanager.taskservice.repository.TaskRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.taskmanager.taskservice.event.TaskEvent;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;


import java.util.*;

@Service
public class TaskService {

    @Autowired
    private TaskRepository repo;

    @Autowired
    private UserClient userClient;

    @Autowired
    private ProjectClient projectClient;

    private final RabbitTemplate rabbitTemplate;

    public TaskService(RabbitTemplate rabbitTemplate, Jackson2JsonMessageConverter messageConverter) {
        this.rabbitTemplate = rabbitTemplate;
        this.rabbitTemplate.setMessageConverter(messageConverter);
    }
    public Task create(TaskRequest request) {
        // Skip user validation for now
        // if (request.getAssignedTo() != null && !userClient.userExists(request.getAssignedTo())) {
        //     throw new RuntimeException("User does not exist: " + request.getAssignedTo());
        // }

        projectClient.projectExists(request.getProjectId()); // 404 if not found

        Task task = new Task();
        task.setTitle(request.getTitle());
        task.setDescription(request.getDescription());
        task.setStatus(request.getStatus());
        task.setAssignedTo(request.getAssignedTo());
        task.setProjectId(request.getProjectId());

        Task saved=  repo.save(task);

	 // ✅ Prepare and send RabbitMQ event
   	TaskEvent event = new TaskEvent();
    	event.setTitle(saved.getTitle());
    	event.setDescription(saved.getDescription());
    	event.setAssignedTo(saved.getAssignedTo());
    	event.setStatus(saved.getStatus());

    	rabbitTemplate.convertAndSend("task.notifications", event);

    	return saved;
    }	

    public List<Task> getAll() {
        return repo.findAll();
    }

    public Task update(Long id, TaskRequest request) {
        Task task = repo.findById(id).orElseThrow(() -> new RuntimeException("Task not found"));
        task.setTitle(request.getTitle());
        task.setDescription(request.getDescription());
        task.setStatus(request.getStatus());
        task.setAssignedTo(request.getAssignedTo());
        task.setProjectId(request.getProjectId());
        Task updated = repo.save(task);
        
        TaskEvent event = new TaskEvent();
        event.setTitle(updated.getTitle());
        event.setDescription(updated.getDescription());
        event.setAssignedTo(updated.getAssignedTo());
        event.setStatus(updated.getStatus());
        rabbitTemplate.convertAndSend("task.notifications", event);
        
        return updated;
    }

    public void delete(Long id) {
        repo.deleteById(id);
    }

    public Task updateStatus(Long id, String status) {
        Task task = repo.findById(id).orElseThrow(() -> new RuntimeException("Task not found"));
        task.setStatus(status);
        Task updated = repo.save(task);
        
        TaskEvent event = new TaskEvent();
        event.setTitle(updated.getTitle());
        event.setDescription(updated.getDescription());
        event.setAssignedTo(updated.getAssignedTo());
        event.setStatus(updated.getStatus());
        rabbitTemplate.convertAndSend("task.notifications", event);
        
        return updated;
    }
}

