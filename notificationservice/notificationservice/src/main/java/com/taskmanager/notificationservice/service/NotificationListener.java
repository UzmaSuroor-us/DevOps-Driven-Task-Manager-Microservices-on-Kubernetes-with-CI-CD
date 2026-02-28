package com.taskmanager.notificationservice.service;

import com.taskmanager.notificationservice.dto.TaskEvent;
import jakarta.mail.MessagingException;
import lombok.RequiredArgsConstructor;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.mail.javamail.*;
import org.springframework.stereotype.Service;

import jakarta.mail.internet.MimeMessage;

@Service
@RequiredArgsConstructor
public class NotificationListener {

    private final JavaMailSender mailSender;

    @RabbitListener(queues = "task.notifications")
    public void handleTaskNotification(TaskEvent event) {
        sendEmail(event.getAssignedTo(), event);
    }

    private void sendEmail(String toUser, TaskEvent task) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true);

            helper.setTo(toUser);
            helper.setSubject("📝 Task Update: " + task.getTitle());
            helper.setText("Task: " + task.getTitle() + "\n\nDescription: " + task.getDescription() + "\n\nStatus: " + task.getStatus() + "\n\nAssigned to: " + task.getAssignedTo());

            mailSender.send(message);
            System.out.println("Email sent to: " + toUser);
        } catch (MessagingException e) {
            System.out.println("Failed to send email: " + e.getMessage());
        }
    }
}

