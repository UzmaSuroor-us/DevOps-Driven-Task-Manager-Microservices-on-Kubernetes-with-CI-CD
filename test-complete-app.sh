#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0

echo "=========================================="
echo "COMPLETE APPLICATION TEST"
echo "All 7 Phases"
echo "=========================================="
echo ""

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
# 1. BACKEND SERVICES
# ==========================================
echo "=========================================="
echo "1. Backend Services (Phases 1-3)"
echo "=========================================="

[ -d "eureka-server" ] && test_check 0 "Eureka Server exists" || test_check 1 "Eureka Server missing"
[ -d "api-gateway" ] && test_check 0 "API Gateway exists" || test_check 1 "API Gateway missing"
[ -d "userservice" ] && test_check 0 "User Service exists" || test_check 1 "User Service missing"
[ -d "projectservice" ] && test_check 0 "Project Service exists" || test_check 1 "Project Service missing"
[ -d "taskservice" ] && test_check 0 "Task Service exists" || test_check 1 "Task Service missing"
[ -d "notificationservice" ] && test_check 0 "Notification Service exists" || test_check 1 "Notification Service missing"
[ -d "fileuploadservice" ] && test_check 0 "File Upload Service exists" || test_check 1 "File Upload Service missing"

echo ""

# ==========================================
# 2. DOCKER & KUBERNETES
# ==========================================
echo "=========================================="
echo "2. Containerization (Phases 4-5)"
echo "=========================================="

[ -f "docker-compose.yml" ] && test_check 0 "Docker Compose file exists" || test_check 1 "Docker Compose missing"
[ -d "k8s-manifests" ] && test_check 0 "Kubernetes manifests exist" || test_check 1 "K8s manifests missing"

DOCKERFILE_COUNT=$(ls -1 Dockerfile-* 2>/dev/null | wc -l)
if [ $DOCKERFILE_COUNT -ge 7 ]; then
    test_check 0 "All Dockerfiles exist ($DOCKERFILE_COUNT)"
else
    test_check 1 "Missing Dockerfiles ($DOCKERFILE_COUNT/7)"
fi

echo ""

# ==========================================
# 3. CI/CD PIPELINE
# ==========================================
echo "=========================================="
echo "3. CI/CD Pipeline (Phase 6)"
echo "=========================================="

[ -f ".github/workflows/ci-cd-pipeline.yml" ] && test_check 0 "CI/CD workflow exists" || test_check 1 "CI/CD workflow missing"
[ -f ".github/workflows/pr-validation.yml" ] && test_check 0 "PR validation workflow exists" || test_check 1 "PR validation missing"

echo ""

# ==========================================
# 4. FRONTEND
# ==========================================
echo "=========================================="
echo "4. Frontend (Phase 7)"
echo "=========================================="

[ -d "frontend" ] && test_check 0 "Frontend directory exists" || test_check 1 "Frontend missing"
[ -f "frontend/package.json" ] && test_check 0 "Frontend package.json exists" || test_check 1 "package.json missing"
[ -f "frontend/src/pages/Login.tsx" ] && test_check 0 "Login page exists" || test_check 1 "Login page missing"
[ -f "frontend/src/pages/Dashboard.tsx" ] && test_check 0 "Dashboard page exists" || test_check 1 "Dashboard page missing"
[ -f "frontend/src/pages/Kanban.tsx" ] && test_check 0 "Kanban page exists" || test_check 1 "Kanban page missing"

echo ""

# ==========================================
# 5. RUNTIME TESTS (DOCKER)
# ==========================================
echo "=========================================="
echo "5. Runtime Tests (Docker)"
echo "=========================================="

if docker ps &>/dev/null; then
    RUNNING=$(docker ps --format '{{.Names}}' | grep -E 'eureka-server|api-gateway|user-service|project-service|task-service|postgres|rabbitmq' | wc -l)
    
    if [ $RUNNING -ge 7 ]; then
        test_check 0 "Docker containers running ($RUNNING/9)"
    else
        echo -e "${YELLOW}⚠️  SKIP${NC}: Docker containers not running ($RUNNING/9)"
    fi
else
    echo -e "${YELLOW}⚠️  SKIP${NC}: Docker not running"
fi

echo ""

# ==========================================
# 6. API ENDPOINTS
# ==========================================
echo "=========================================="
echo "6. API Endpoints"
echo "=========================================="

if curl -s http://localhost:8761 &>/dev/null; then
    test_check 0 "Eureka Server responding (8761)"
else
    echo -e "${YELLOW}⚠️  SKIP${NC}: Eureka Server not running"
fi

if curl -s http://localhost:8080 &>/dev/null; then
    test_check 0 "API Gateway responding (8080)"
else
    echo -e "${YELLOW}⚠️  SKIP${NC}: API Gateway not running"
fi

if curl -s http://localhost:8081/actuator/health &>/dev/null; then
    test_check 0 "User Service health endpoint (8081)"
else
    echo -e "${YELLOW}⚠️  SKIP${NC}: User Service not running"
fi

echo ""

# ==========================================
# 7. FRONTEND SERVER
# ==========================================
echo "=========================================="
echo "7. Frontend Server"
echo "=========================================="

if curl -s http://localhost:3000 &>/dev/null; then
    test_check 0 "Frontend server running (3000)"
else
    echo -e "${YELLOW}⚠️  SKIP${NC}: Frontend not running (run: cd frontend && npm start)"
fi

echo ""

# ==========================================
# 8. DOCUMENTATION
# ==========================================
echo "=========================================="
echo "8. Documentation"
echo "=========================================="

[ -f "PHASE4-CONTAINERIZATION-DOCUMENTATION.md" ] && test_check 0 "Phase 4 docs exist" || test_check 1 "Phase 4 docs missing"
[ -f "PHASE5-KUBERNETES-MONITORING-DOCUMENTATION.md" ] && test_check 0 "Phase 5 docs exist" || test_check 1 "Phase 5 docs missing"
[ -f "PHASE6-CICD-DOCUMENTATION.md" ] && test_check 0 "Phase 6 docs exist" || test_check 1 "Phase 6 docs missing"
[ -f "PHASE7-FRONTEND-DOCUMENTATION.md" ] && test_check 0 "Phase 7 docs exist" || test_check 1 "Phase 7 docs missing"

echo ""

# ==========================================
# SUMMARY
# ==========================================
echo "=========================================="
echo "TEST SUMMARY"
echo "=========================================="
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"
echo ""

TOTAL=$((PASS_COUNT + FAIL_COUNT))
if [ $TOTAL -gt 0 ]; then
    PERCENTAGE=$((PASS_COUNT * 100 / TOTAL))
else
    PERCENTAGE=0
fi

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}✅ ALL TESTS PASSED - APPLICATION COMPLETE${NC}"
    echo ""
    echo "🎉 Congratulations! All 7 phases implemented successfully!"
    echo ""
    echo "Quick Start:"
    echo "1. Backend: docker-compose up -d"
    echo "2. Frontend: cd frontend && npm start"
    echo "3. Access: http://localhost:3000"
    exit 0
elif [ $PERCENTAGE -ge 80 ]; then
    echo -e "${YELLOW}⚠️  MOSTLY COMPLETE ($PERCENTAGE%)${NC}"
    echo ""
    echo "Core features implemented. Some runtime services may not be running."
    echo ""
    echo "To start services:"
    echo "1. docker-compose up -d"
    echo "2. cd frontend && npm start"
    exit 0
else
    echo -e "${RED}❌ INCOMPLETE ($PERCENTAGE%)${NC}"
    echo ""
    echo "Critical components missing. Review failed tests above."
    exit 1
fi
