package com.taskmanager.taskservice.repository;

import com.taskmanager.taskservice.entity.Task;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TaskRepository extends JpaRepository<Task, Long> {
}

