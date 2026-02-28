# Kubernetes Deployment Guide

## Prerequisites

1. **Kubernetes Cluster** (Minikube, Docker Desktop, or cloud provider)
2. **kubectl** installed and configured
3. **Docker images** built from Phase 4

## Quick Start

### 1. Start Kubernetes Cluster

**For Minikube:**
```bash
minikube start --cpus=4 --memory=8192
eval $(minikube docker-env)
```

**For Docker Desktop:**
- Enable Kubernetes in Docker Desktop settings

### 2. Build Docker Images

```bash
cd ~/task-manager
docker-compose build
```

### 3. Deploy to Kubernetes

```bash
chmod +x deploy-k8s.sh
./deploy-k8s.sh
```

**Or manually:**
```bash
# Infrastructure
kubectl apply -f k8s-manifests/infrastructure/

# Eureka Server
kubectl apply -f k8s-manifests/base/eureka-server.yaml

# Microservices
kubectl apply -f k8s-manifests/base/

# Monitoring
kubectl apply -f k8s-manifests/monitoring/
```

## Verify Deployment

### Check Pods
```bash
kubectl get pods
```

**Expected Output:**
```
NAME                                    READY   STATUS    RESTARTS
api-gateway-xxx                         1/1     Running   0
eureka-server-xxx                       1/1     Running   0
user-service-xxx                        1/1     Running   0
project-service-xxx                     1/1     Running   0
task-service-xxx                        1/1     Running   0
notification-service-xxx                1/1     Running   0
file-upload-service-xxx                 1/1     Running   0
postgres-xxx                            1/1     Running   0
rabbitmq-xxx                            1/1     Running   0
prometheus-xxx                          1/1     Running   0
grafana-xxx                             1/1     Running   0
```

### Check Services
```bash
kubectl get services
```

### View Logs
```bash
kubectl logs -f deployment/api-gateway
kubectl logs -f deployment/user-service
```

## Access Applications

### Get Service URLs (Minikube)
```bash
minikube service api-gateway --url
minikube service prometheus --url
minikube service grafana --url
```

### Access Points

| Service | URL | Credentials |
|---------|-----|-------------|
| API Gateway | http://localhost:8080 | - |
| Eureka Dashboard | http://localhost:8761 | - |
| Prometheus | http://localhost:9090 | - |
| Grafana | http://localhost:3000 | admin/admin |

## Monitoring Setup

### 1. Access Grafana
```bash
# Get Grafana URL
kubectl get service grafana

# Login: admin/admin
```

### 2. Add Prometheus Data Source
1. Go to Configuration → Data Sources
2. Add Prometheus
3. URL: `http://prometheus:9090`
4. Save & Test

### 3. Import Dashboard
1. Go to Dashboards → Import
2. Upload `k8s-manifests/monitoring/grafana-dashboard.json`
3. Select Prometheus data source
4. Import

### 4. View Metrics
- Service Health Status
- HTTP Request Rate
- Task Activity Per Project
- Response Times
- JVM Memory Usage
- Database Connections

## Scaling Services

### Scale User Service
```bash
kubectl scale deployment user-service --replicas=3
```

### Auto-scaling
```bash
kubectl autoscale deployment user-service --min=2 --max=10 --cpu-percent=80
```

## Update Deployment

### Update Image
```bash
# Rebuild image
docker-compose build user-service

# Restart deployment
kubectl rollout restart deployment/user-service
```

### Check Rollout Status
```bash
kubectl rollout status deployment/user-service
```

## Troubleshooting

### Pod Not Starting
```bash
# Describe pod
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

### Service Not Accessible
```bash
# Check service
kubectl get service <service-name>

# Check endpoints
kubectl get endpoints <service-name>

# Port forward for testing
kubectl port-forward service/api-gateway 8080:8080
```

### Database Connection Issues
```bash
# Check postgres pod
kubectl logs deployment/postgres

# Exec into pod
kubectl exec -it deployment/postgres -- psql -U postgres -d projectdb
```

## Clean Up

### Delete All Resources
```bash
kubectl delete -f k8s-manifests/monitoring/
kubectl delete -f k8s-manifests/base/
kubectl delete -f k8s-manifests/infrastructure/
```

### Or Delete Namespace
```bash
kubectl delete namespace task-manager
```

## Architecture

```
┌─────────────────────────────────────────────────┐
│           Kubernetes Cluster                     │
├─────────────────────────────────────────────────┤
│                                                  │
│  ┌──────────────┐      ┌──────────────┐        │
│  │  Prometheus  │◄─────┤   Grafana    │        │
│  │   (9090)     │      │   (3000)     │        │
│  └──────┬───────┘      └──────────────┘        │
│         │ scrapes                                │
│         ▼                                        │
│  ┌──────────────────────────────────┐          │
│  │      Microservices Pods          │          │
│  │  ┌────────┐  ┌────────┐         │          │
│  │  │  User  │  │Project │         │          │
│  │  │Service │  │Service │         │          │
│  │  └────────┘  └────────┘         │          │
│  │  ┌────────┐  ┌────────┐         │          │
│  │  │  Task  │  │ Notif  │         │          │
│  │  │Service │  │Service │         │          │
│  │  └────────┘  └────────┘         │          │
│  └──────────────────────────────────┘          │
│         ▲                                        │
│         │                                        │
│  ┌──────┴───────┐                               │
│  │ API Gateway  │◄──── LoadBalancer             │
│  │   (8080)     │                               │
│  └──────────────┘                               │
│                                                  │
│  ┌──────────────┐      ┌──────────────┐        │
│  │  PostgreSQL  │      │  RabbitMQ    │        │
│  │   (5432)     │      │   (5672)     │        │
│  └──────────────┘      └──────────────┘        │
│                                                  │
└─────────────────────────────────────────────────┘
```

## Key Features

✅ **High Availability**: Multiple replicas for critical services
✅ **Auto-scaling**: HPA based on CPU/memory
✅ **Health Checks**: Liveness and readiness probes
✅ **Service Discovery**: Eureka for dynamic service registration
✅ **Load Balancing**: Kubernetes services with load balancing
✅ **Monitoring**: Prometheus + Grafana for observability
✅ **Persistent Storage**: PVC for PostgreSQL data
✅ **Rolling Updates**: Zero-downtime deployments

## Metrics Available

### Application Metrics
- HTTP request count and rate
- Response time percentiles (p50, p95, p99)
- Error rates
- Task creation/completion metrics
- Project activity metrics

### System Metrics
- JVM memory usage (heap, non-heap)
- CPU usage
- Thread count
- Garbage collection stats

### Database Metrics
- Connection pool size
- Active connections
- Query execution time

## Next Steps

1. **Add Ingress Controller** for better routing
2. **Implement Helm Charts** for easier deployment
3. **Add Horizontal Pod Autoscaler** for auto-scaling
4. **Configure Persistent Volumes** for production
5. **Add Network Policies** for security
6. **Implement Service Mesh** (Istio/Linkerd)
7. **Add Distributed Tracing** (Jaeger/Zipkin)

---

**Phase 5 Complete!** ✅
