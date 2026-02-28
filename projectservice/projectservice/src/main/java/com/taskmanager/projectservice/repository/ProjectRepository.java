package com.taskmanager.projectservice.repository;

import com.taskmanager.projectservice.entity.Project;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProjectRepository extends JpaRepository<Project, Long> {
}
