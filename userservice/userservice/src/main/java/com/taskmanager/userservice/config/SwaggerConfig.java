package com.taskmanager.userservice.config;

import io.swagger.v3.oas.models.*;
import io.swagger.v3.oas.models.info.Info;
import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.context.annotation.*;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI openAPI() {
        return new OpenAPI().info(
                new Info().title("User Service API")
                          .description("Handles Registration and JWT Auth")
                          .version("1.0"));
    }

    @Bean
    public GroupedOpenApi publicApi() {
        return GroupedOpenApi.builder()
                .group("user")
                .pathsToMatch("/auth/**", "/api/**")
                .build();
    }
}

