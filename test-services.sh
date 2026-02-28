#!/bin/bash

echo "=========================================="
echo "Testing Microservices Architecture"
echo "=========================================="
echo ""

echo "1. Checking Eureka Server..."
curl -s http://localhost:8761 > /dev/null && echo "✅ Eureka Server is UP" || echo "❌ Eureka Server is DOWN"
echo ""

echo "2. Testing API Gateway..."
curl -s http://localhost:8080 > /dev/null && echo "✅ API Gateway is UP" || echo "❌ API Gateway is DOWN"
echo ""

echo "3. Testing User Service via Gateway..."
response=$(curl -s http://localhost:8080/api/users/test)
if [ -n "$response" ]; then
    echo "✅ User Service: $response"
else
    echo "❌ User Service: No response"
fi
echo ""

echo "4. Testing Project Service via Gateway..."
response=$(curl -s http://localhost:8080/api/projects | head -c 50)
if [ -n "$response" ]; then
    echo "✅ Project Service: Working (data returned)"
else
    echo "❌ Project Service: No response"
fi
echo ""

echo "5. Testing Task Service via Gateway..."
response=$(curl -s http://localhost:8080/api/tasks | head -c 50)
if [ -n "$response" ]; then
    echo "✅ Task Service: Working (data returned)"
else
    echo "❌ Task Service: No response"
fi
echo ""

echo "6. Testing Notification Service via Gateway..."
response=$(curl -s http://localhost:8080/api/notifications/test)
if [ -n "$response" ]; then
    echo "✅ Notification Service: $response"
else
    echo "❌ Notification Service: No response"
fi
echo ""

echo "7. Testing File Upload Service via Gateway..."
response=$(curl -s http://localhost:8080/api/files/health)
if [ -n "$response" ]; then
    echo "✅ File Upload Service: $response"
else
    echo "❌ File Upload Service: No response"
fi
echo ""

echo "=========================================="
echo "Checking Eureka Registered Services..."
echo "=========================================="
echo "Visit: http://localhost:8761"
echo ""
echo "Expected services:"
echo "  - API-GATEWAY (8080)"
echo "  - USER-SERVICE (8081)"
echo "  - PROJECTSERVICE (8082)"
echo "  - TASKSERVICE (8083)"
echo "  - NOTIFICATIONSERVICE (8084)"
echo "  - FILEUPLOADSERVICE (8085)"
echo ""
echo "=========================================="
echo "Test Complete!"
echo "=========================================="
