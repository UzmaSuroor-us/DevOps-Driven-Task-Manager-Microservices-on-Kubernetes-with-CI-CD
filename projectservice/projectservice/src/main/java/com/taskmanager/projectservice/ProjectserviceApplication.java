package com.taskmanager.projectservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;

@SpringBootApplication(exclude = { SecurityAutoConfiguration.class })
@EnableFeignClients(basePackages = "com.taskmanager.projectservice.service")
public class ProjectserviceApplication {

	public static void main(String[] args) {
		SpringApplication.run(ProjectserviceApplication.class, args);
	}

}
