#!/bin/bash

echo "=========================================="
echo "Deploying Task Manager to Kubernetes"
echo "=========================================="
echo ""

# Step 1: Deploy Infrastructure
echo "1. Deploying Infrastructure (PostgreSQL, RabbitMQ)..."
kubectl apply -f k8s-manifests/infrastructure/

echo "Waiting for infrastructure to be ready..."
sleep 30

# Step 2: Deploy Eureka Server
echo "2. Deploying Eureka Server..."
kubectl apply -f k8s-manifests/base/eureka-server.yaml

echo "Waiting for Eureka to be ready..."
sleep 30

# Step 3: Deploy Microservices
echo "3. Deploying Microservices..."
kubectl apply -f k8s-manifests/base/user-service.yaml
kubectl apply -f k8s-manifests/base/project-service.yaml
kubectl apply -f k8s-manifests/base/task-service.yaml
kubectl apply -f k8s-manifests/base/other-services.yaml

echo "Waiting for services to be ready..."
sleep 30

# Step 4: Deploy API Gateway
echo "4. Deploying API Gateway..."
kubectl apply -f k8s-manifests/base/api-gateway.yaml

echo "Waiting for API Gateway to be ready..."
sleep 20

# Step 5: Deploy Monitoring
echo "5. Deploying Monitoring (Prometheus & Grafana)..."
kubectl apply -f k8s-manifests/monitoring/

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""

# Display status
echo "Checking deployment status..."
kubectl get pods
echo ""
kubectl get services
echo ""

echo "=========================================="
echo "Access Points:"
echo "=========================================="
echo "API Gateway: http://localhost:8080"
echo "Eureka Dashboard: http://localhost:8761"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 (admin/admin)"
echo "=========================================="
