# Running Task Manager Microservices

## Prerequisites
- Java 17
- Maven
- PostgreSQL (port 5432)
- RabbitMQ (port 5672)

## Database Setup
```sql
CREATE DATABASE projectdb;
```

## Startup Order

### 1. Start Eureka Server (Port 8761)
```bash
cd eureka-server
mvn spring-boot:run
```
Verify: http://localhost:8761

### 2. Start User Service (Port 8081)
```bash
cd userservice/userservice
mvn spring-boot:run
```

### 3. Start Project Service (Port 8082)
```bash
cd projectservice/projectservice
mvn spring-boot:run
```

### 4. Start Task Service (Port 8083)
```bash
cd taskservice/taskservice
mvn spring-boot:run
```

### 5. Start Notification Service (Port 8084)
```bash
cd notificationservice/notificationservice
mvn spring-boot:run
```

### 6. Start File Upload Service (Port 8085)
```bash
cd fileuploadservice/fileuploadservice
mvn spring-boot:run
```

### 7. Start API Gateway (Port 8080)
```bash
cd api-gateway/api-gateway
mvn spring-boot:run
```

## Verify Services

### Check Eureka Dashboard
http://localhost:8761
- Should show all 5 services registered

### Test API Gateway Routes

**User Service:**
```bash
curl http://localhost:8080/api/users/test
```

**Project Service:**
```bash
curl http://localhost:8080/api/projects
```

**Task Service:**
```bash
curl http://localhost:8080/api/tasks
```

**Notification Service:**
```bash
curl http://localhost:8080/api/notifications/test
```

**File Upload Service:**
```bash
curl http://localhost:8080/api/files/health
```

## Service Ports
- Eureka Server: 8761
- API Gateway: 8080
- User Service: 8081
- Project Service: 8082
- Task Service: 8083
- Notification Service: 8084
- File Upload Service: 8085

## Troubleshooting

**Services not registering with Eureka:**
- Wait 30 seconds for registration
- Check eureka.client.service-url.defaultZone in application.properties

**Gateway 503 errors:**
- Ensure target service is running and registered in Eureka
- Check service name matches in gateway routes

**Database connection errors:**
- Verify PostgreSQL is running
- Check credentials in application.properties
