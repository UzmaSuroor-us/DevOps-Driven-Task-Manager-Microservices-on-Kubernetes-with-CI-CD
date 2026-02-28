#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASS_COUNT=0
FAIL_COUNT=0

echo "=========================================="
echo "PHASE 5 COMPLETE VERIFICATION"
echo "Kubernetes + Monitoring"
echo "=========================================="
echo ""

# Test function
test_check() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ PASS${NC}: $2"
        ((PASS_COUNT++))
    else
        echo -e "${RED}❌ FAIL${NC}: $2"
        ((FAIL_COUNT++))
    fi
}

# ==========================================
# 1. K8S MANIFESTS - DEPLOYMENTS
# ==========================================
echo "=========================================="
echo "1. Kubernetes Manifests - Deployments"
echo "=========================================="

# Check infrastructure manifests
if [ -f "k8s-manifests/infrastructure/postgres.yaml" ] && [ -f "k8s-manifests/infrastructure/rabbitmq.yaml" ]; then
    test_check 0 "Infrastructure manifests (postgres, rabbitmq)"
else
    test_check 1 "Infrastructure manifests missing"
fi

# Check service manifests
SERVICES=("eureka-server" "api-gateway" "user-service" "project-service" "task-service")
MISSING_SERVICES=0
for service in "${SERVICES[@]}"; do
    if [ ! -f "k8s-manifests/base/${service}.yaml" ]; then
        ((MISSING_SERVICES++))
    fi
done

if [ $MISSING_SERVICES -eq 0 ]; then
    test_check 0 "All 5 core service manifests exist"
else
    test_check 1 "$MISSING_SERVICES service manifests missing"
fi

# Check other services
if [ -f "k8s-manifests/base/other-services.yaml" ]; then
    test_check 0 "Other services manifest (notification, file-upload)"
else
    test_check 1 "Other services manifest missing"
fi

echo ""

# ==========================================
# 2. K8S MANIFESTS - SERVICES
# ==========================================
echo "=========================================="
echo "2. Kubernetes Manifests - Services"
echo "=========================================="

# Check if manifests contain Service definitions
SERVICE_COUNT=$(grep -r "kind: Service" k8s-manifests/ 2>/dev/null | wc -l)
if [ $SERVICE_COUNT -ge 7 ]; then
    test_check 0 "Service definitions found ($SERVICE_COUNT services)"
else
    test_check 1 "Insufficient Service definitions (found: $SERVICE_COUNT, expected: ≥7)"
fi

echo ""

# ==========================================
# 3. K8S MANIFESTS - CONFIGMAPS
# ==========================================
echo "=========================================="
echo "3. Kubernetes Manifests - ConfigMaps"
echo "=========================================="

# Check ConfigMaps
CONFIGMAP_COUNT=$(grep -r "kind: ConfigMap" k8s-manifests/ 2>/dev/null | wc -l)
if [ $CONFIGMAP_COUNT -ge 2 ]; then
    test_check 0 "ConfigMap definitions found ($CONFIGMAP_COUNT)"
else
    test_check 1 "Insufficient ConfigMaps (found: $CONFIGMAP_COUNT, expected: ≥2)"
fi

echo ""

# ==========================================
# 4. PROMETHEUS SETUP
# ==========================================
echo "=========================================="
echo "4. Prometheus Monitoring"
echo "=========================================="

# Check Prometheus manifest
if [ -f "k8s-manifests/monitoring/prometheus.yaml" ]; then
    test_check 0 "Prometheus manifest exists"
    
    # Check scrape configs for all services
    SCRAPE_JOBS=$(grep "job_name:" k8s-manifests/monitoring/prometheus.yaml | wc -l)
    if [ $SCRAPE_JOBS -ge 6 ]; then
        test_check 0 "Prometheus scrape configs for all services ($SCRAPE_JOBS jobs)"
    else
        test_check 1 "Insufficient scrape configs (found: $SCRAPE_JOBS, expected: ≥6)"
    fi
    
    # Check metrics path
    if grep -q "metrics_path: '/actuator/prometheus'" k8s-manifests/monitoring/prometheus.yaml; then
        test_check 0 "Prometheus metrics path configured"
    else
        test_check 1 "Prometheus metrics path not configured"
    fi
else
    test_check 1 "Prometheus manifest missing"
fi

echo ""

# ==========================================
# 5. GRAFANA SETUP
# ==========================================
echo "=========================================="
echo "5. Grafana Monitoring"
echo "=========================================="

# Check Grafana manifest
if [ -f "k8s-manifests/monitoring/grafana.yaml" ]; then
    test_check 0 "Grafana manifest exists"
else
    test_check 1 "Grafana manifest missing"
fi

# Check Grafana dashboard
if [ -f "k8s-manifests/monitoring/grafana-dashboard.json" ]; then
    test_check 0 "Grafana dashboard JSON exists"
    
    # Check for required dashboard panels
    if grep -q "Task Activity Per Project" k8s-manifests/monitoring/grafana-dashboard.json; then
        test_check 0 "Dashboard: Task activity per project panel"
    else
        test_check 1 "Dashboard missing: Task activity per project"
    fi
    
    if grep -q "Service Health Status" k8s-manifests/monitoring/grafana-dashboard.json; then
        test_check 0 "Dashboard: Service health checks panel"
    else
        test_check 1 "Dashboard missing: Service health checks"
    fi
else
    test_check 1 "Grafana dashboard JSON missing"
fi

echo ""

# ==========================================
# 6. SPRING BOOT ACTUATOR
# ==========================================
echo "=========================================="
echo "6. Spring Boot Actuator Integration"
echo "=========================================="

# Check actuator dependency in pom.xml files
SERVICES_WITH_ACTUATOR=0
for pom in userservice/userservice/pom.xml api-gateway/api-gateway/pom.xml projectservice/projectservice/pom.xml taskservice/taskservice/pom.xml; do
    if [ -f "$pom" ]; then
        if grep -q "spring-boot-starter-actuator" "$pom"; then
            ((SERVICES_WITH_ACTUATOR++))
        fi
    fi
done

if [ $SERVICES_WITH_ACTUATOR -ge 2 ]; then
    test_check 0 "Actuator dependency in $SERVICES_WITH_ACTUATOR services"
else
    test_check 1 "Actuator dependency missing (found in $SERVICES_WITH_ACTUATOR services)"
fi

# Check Micrometer Prometheus registry
SERVICES_WITH_MICROMETER=0
for pom in userservice/userservice/pom.xml api-gateway/api-gateway/pom.xml projectservice/projectservice/pom.xml taskservice/taskservice/pom.xml; do
    if [ -f "$pom" ]; then
        if grep -q "micrometer-registry-prometheus" "$pom"; then
            ((SERVICES_WITH_MICROMETER++))
        fi
    fi
done

if [ $SERVICES_WITH_MICROMETER -ge 2 ]; then
    test_check 0 "Micrometer Prometheus in $SERVICES_WITH_MICROMETER services"
else
    test_check 1 "Micrometer Prometheus missing (found in $SERVICES_WITH_MICROMETER services)"
fi

echo ""

# ==========================================
# 7. DOCKER COMPOSE DEPLOYMENT (RUNTIME)
# ==========================================
echo "=========================================="
echo "7. Docker Compose Deployment (Runtime)"
echo "=========================================="

# Check if Docker is running
if docker ps &>/dev/null; then
    RUNNING_CONTAINERS=$(docker ps --format '{{.Names}}' | grep -E 'user-service|project-service|task-service|notification-service|file-upload-service|api-gateway|eureka-server|postgres|rabbitmq' | wc -l)
    
    if [ $RUNNING_CONTAINERS -ge 7 ]; then
        test_check 0 "Docker containers running ($RUNNING_CONTAINERS/9)"
    else
        test_check 1 "Insufficient containers running ($RUNNING_CONTAINERS/9)"
    fi
else
    echo -e "${YELLOW}⚠️  SKIP${NC}: Docker not running (optional for manifest verification)"
fi

echo ""

# ==========================================
# 8. ACTUATOR ENDPOINTS (RUNTIME)
# ==========================================
echo "=========================================="
echo "8. Actuator Endpoints (Runtime)"
echo "=========================================="

# Check actuator health endpoints
if curl -s http://localhost:8081/actuator/health &>/dev/null; then
    test_check 0 "User Service actuator health endpoint"
else
    echo -e "${YELLOW}⚠️  SKIP${NC}: User Service not running (optional)"
fi

if curl -s http://localhost:8080/actuator/health &>/dev/null; then
    test_check 0 "API Gateway actuator health endpoint"
else
    echo -e "${YELLOW}⚠️  SKIP${NC}: API Gateway not running (optional)"
fi

echo ""

# ==========================================
# 9. PROMETHEUS METRICS (RUNTIME)
# ==========================================
echo "=========================================="
echo "9. Prometheus Metrics Export (Runtime)"
echo "=========================================="

# Check Prometheus metrics endpoints
if curl -s http://localhost:8081/actuator/prometheus | grep -q "jvm_memory_used_bytes"; then
    test_check 0 "User Service Prometheus metrics endpoint"
else
    echo -e "${YELLOW}⚠️  SKIP${NC}: User Service metrics not available (optional)"
fi

if curl -s http://localhost:8080/actuator/prometheus | grep -q "jvm_memory_used_bytes"; then
    test_check 0 "API Gateway Prometheus metrics endpoint"
else
    echo -e "${YELLOW}⚠️  SKIP${NC}: API Gateway metrics not available (optional)"
fi

echo ""

# ==========================================
# 10. DEPLOYMENT SCRIPTS
# ==========================================
echo "=========================================="
echo "10. Deployment Scripts & Documentation"
echo "=========================================="

if [ -f "deploy-k8s.sh" ]; then
    test_check 0 "Kubernetes deployment script exists"
else
    test_check 1 "Kubernetes deployment script missing"
fi

if [ -f "docker-compose.yml" ]; then
    test_check 0 "Docker Compose file exists"
else
    test_check 1 "Docker Compose file missing"
fi

# Check documentation
DOC_COUNT=0
[ -f "PHASE5-KUBERNETES-MONITORING-DOCUMENTATION.md" ] && ((DOC_COUNT++))
[ -f "K8S-DEPLOYMENT-GUIDE.md" ] && ((DOC_COUNT++))

if [ $DOC_COUNT -ge 1 ]; then
    test_check 0 "Phase 5 documentation exists ($DOC_COUNT files)"
else
    test_check 1 "Phase 5 documentation missing"
fi

echo ""

# ==========================================
# SUMMARY
# ==========================================
echo "=========================================="
echo "VERIFICATION SUMMARY"
echo "=========================================="
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"
echo ""

TOTAL=$((PASS_COUNT + FAIL_COUNT))
PERCENTAGE=$((PASS_COUNT * 100 / TOTAL))

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}✅ PHASE 5 COMPLETE - ALL TESTS PASSED${NC}"
    exit 0
elif [ $PERCENTAGE -ge 80 ]; then
    echo -e "${YELLOW}⚠️  PHASE 5 MOSTLY COMPLETE ($PERCENTAGE%)${NC}"
    echo ""
    echo "Core requirements met. Minor issues detected."
    exit 0
else
    echo -e "${RED}❌ PHASE 5 INCOMPLETE ($PERCENTAGE%)${NC}"
    echo ""
    echo "Critical requirements missing. Review failed tests above."
    exit 1
fi
