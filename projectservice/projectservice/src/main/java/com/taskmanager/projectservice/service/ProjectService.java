package com.taskmanager.projectservice.service;

import com.taskmanager.projectservice.dto.ProjectRequest;
import com.taskmanager.projectservice.entity.Project;
import com.taskmanager.projectservice.repository.ProjectRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
@Service
public class ProjectService {

    @Autowired
    private ProjectRepository projectRepo;

    @Autowired
    private UserClient userClient;
    

    private void validateUsers(List<String> usernames) {
        if (usernames == null || usernames.isEmpty()) {
            return;
        }
        for (String username : usernames) {
            boolean exists = userClient.userExists(username);
            if (!exists) {
                throw new RuntimeException("User not found: " + username);
           }
       }
    }
    public Project create(ProjectRequest request) {
	validateUsers(request.getMembers());
        Project project = new Project();
        project.setName(request.getName());
        project.setDescription(request.getDescription());
        project.setMembers(request.getMembers());
        return projectRepo.save(project);
    }
    public List<Project> getAll() {
    return projectRepo.findAll();
    }

    public Project getById(Long id) {
        return projectRepo.findById(id)
           .orElseThrow(() -> new RuntimeException("Project not found"));
    }

    public Project update(Long id, ProjectRequest request) {
	validateUsers(request.getMembers());
        Project project = getById(id);
        project.setName(request.getName());
        project.setDescription(request.getDescription());
        project.setMembers(request.getMembers());
        return projectRepo.save(project);

    }

    public void delete(Long id) {
        projectRepo.deleteById(id);
    }

}

