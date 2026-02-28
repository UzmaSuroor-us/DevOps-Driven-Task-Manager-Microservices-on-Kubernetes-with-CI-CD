package com.taskmanager.taskservice.config;

import jakarta.servlet.Filter;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class FilterConfig {

    @Bean
    public FilterRegistrationBean<Filter> jwtFilter(JwtAuthFilter jwtAuthFilter) {
        FilterRegistrationBean<Filter> registrationBean = new FilterRegistrationBean<>();
        registrationBean.setFilter(jwtAuthFilter);
        registrationBean.addUrlPatterns("/tasks/*"); // Protect only /projects endpoints
        return registrationBean;
    }
}
