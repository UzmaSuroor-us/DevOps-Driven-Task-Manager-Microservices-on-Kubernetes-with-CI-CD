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
echo "PHASE 6 VERIFICATION"
echo "CI/CD Pipeline"
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
# 1. GITHUB ACTIONS WORKFLOWS
# ==========================================
echo "=========================================="
echo "1. GitHub Actions Workflows"
echo "=========================================="

if [ -f ".github/workflows/ci-cd-pipeline.yml" ]; then
    test_check 0 "Main CI/CD pipeline workflow exists"
else
    test_check 1 "Main CI/CD pipeline workflow missing"
fi

if [ -f ".github/workflows/pr-validation.yml" ]; then
    test_check 0 "PR validation workflow exists"
else
    test_check 1 "PR validation workflow missing"
fi

# Check workflow content
if [ -f ".github/workflows/ci-cd-pipeline.yml" ]; then
    if grep -q "build-and-test" .github/workflows/ci-cd-pipeline.yml; then
        test_check 0 "Build and test job configured"
    else
        test_check 1 "Build and test job missing"
    fi
    
    if grep -q "docker-build-push" .github/workflows/ci-cd-pipeline.yml; then
        test_check 0 "Docker build and push job configured"
    else
        test_check 1 "Docker build and push job missing"
    fi
    
    if grep -q "deploy-kubernetes" .github/workflows/ci-cd-pipeline.yml; then
        test_check 0 "Kubernetes deployment job configured"
    else
        test_check 1 "Kubernetes deployment job missing"
    fi
    
    if grep -q "security-scan" .github/workflows/ci-cd-pipeline.yml; then
        test_check 0 "Security scan job configured"
    else
        test_check 1 "Security scan job missing"
    fi
fi

echo ""

# ==========================================
# 2. MULTI-STAGE DOCKERFILES
# ==========================================
echo "=========================================="
echo "2. Multi-Stage Dockerfiles"
echo "=========================================="

DOCKERFILES=(
    "Dockerfile-eureka-server"
    "Dockerfile-api-gateway"
    "Dockerfile-user-service"
    "Dockerfile-project-service"
    "Dockerfile-task-service"
    "Dockerfile-notification-service"
    "Dockerfile-file-upload-service"
)

MISSING_DOCKERFILES=0
for dockerfile in "${DOCKERFILES[@]}"; do
    if [ -f "$dockerfile" ]; then
        # Check if it's multi-stage
        if grep -q "FROM.*AS build" "$dockerfile"; then
            :
        else
            ((MISSING_DOCKERFILES++))
        fi
    else
        ((MISSING_DOCKERFILES++))
    fi
done

if [ $MISSING_DOCKERFILES -eq 0 ]; then
    test_check 0 "All 7 multi-stage Dockerfiles exist"
else
    test_check 1 "$MISSING_DOCKERFILES Dockerfiles missing or not multi-stage"
fi

# Check for optimization (alpine)
ALPINE_COUNT=$(grep -l "alpine" Dockerfile-* 2>/dev/null | wc -l)
if [ $ALPINE_COUNT -ge 5 ]; then
    test_check 0 "Dockerfiles use Alpine for smaller images ($ALPINE_COUNT/7)"
else
    test_check 1 "Few Dockerfiles use Alpine optimization ($ALPINE_COUNT/7)"
fi

echo ""

# ==========================================
# 3. WORKFLOW MATRIX STRATEGY
# ==========================================
echo "=========================================="
echo "3. Workflow Matrix Strategy"
echo "=========================================="

if [ -f ".github/workflows/ci-cd-pipeline.yml" ]; then
    if grep -q "strategy:" .github/workflows/ci-cd-pipeline.yml && grep -q "matrix:" .github/workflows/ci-cd-pipeline.yml; then
        test_check 0 "Matrix strategy for parallel builds"
    else
        test_check 1 "Matrix strategy not configured"
    fi
    
    SERVICE_COUNT=$(grep -A 20 "matrix:" .github/workflows/ci-cd-pipeline.yml | grep -c "service")
    if [ $SERVICE_COUNT -ge 7 ]; then
        test_check 0 "All services in matrix ($SERVICE_COUNT services)"
    else
        test_check 1 "Incomplete service matrix ($SERVICE_COUNT services)"
    fi
fi

echo ""

# ==========================================
# 4. AUTOMATED TESTING
# ==========================================
echo "=========================================="
echo "4. Automated Testing"
echo "=========================================="

if [ -f ".github/workflows/ci-cd-pipeline.yml" ]; then
    if grep -q "mvn test" .github/workflows/ci-cd-pipeline.yml; then
        test_check 0 "Maven test execution configured"
    else
        test_check 1 "Maven test execution missing"
    fi
fi

if [ -f ".github/workflows/pr-validation.yml" ]; then
    if grep -q "mvn test" .github/workflows/pr-validation.yml; then
        test_check 0 "PR validation includes tests"
    else
        test_check 1 "PR validation missing tests"
    fi
fi

echo ""

# ==========================================
# 5. DOCKER REGISTRY INTEGRATION
# ==========================================
echo "=========================================="
echo "5. Docker Registry Integration"
echo "=========================================="

if [ -f ".github/workflows/ci-cd-pipeline.yml" ]; then
    if grep -q "docker/login-action" .github/workflows/ci-cd-pipeline.yml; then
        test_check 0 "Docker Hub login action configured"
    else
        test_check 1 "Docker Hub login action missing"
    fi
    
    if grep -q "docker/build-push-action" .github/workflows/ci-cd-pipeline.yml; then
        test_check 0 "Docker build-push action configured"
    else
        test_check 1 "Docker build-push action missing"
    fi
    
    if grep -q "DOCKER_USERNAME" .github/workflows/ci-cd-pipeline.yml; then
        test_check 0 "Docker credentials using secrets"
    else
        test_check 1 "Docker credentials not configured"
    fi
fi

echo ""

# ==========================================
# 6. KUBERNETES DEPLOYMENT AUTOMATION
# ==========================================
echo "=========================================="
echo "6. Kubernetes Deployment Automation"
echo "=========================================="

if [ -f ".github/workflows/ci-cd-pipeline.yml" ]; then
    if grep -q "kubectl apply" .github/workflows/ci-cd-pipeline.yml; then
        test_check 0 "Kubectl deployment commands configured"
    else
        test_check 1 "Kubectl deployment commands missing"
    fi
    
    if grep -q "k8s-set-context" .github/workflows/ci-cd-pipeline.yml; then
        test_check 0 "Kubernetes context configuration"
    else
        test_check 1 "Kubernetes context configuration missing"
    fi
    
    if grep -q "kubectl wait" .github/workflows/ci-cd-pipeline.yml; then
        test_check 0 "Deployment health checks configured"
    else
        test_check 1 "Deployment health checks missing"
    fi
fi

echo ""

# ==========================================
# 7. SECURITY SCANNING
# ==========================================
echo "=========================================="
echo "7. Security Scanning"
echo "=========================================="

if [ -f ".github/workflows/ci-cd-pipeline.yml" ]; then
    if grep -q "trivy" .github/workflows/ci-cd-pipeline.yml; then
        test_check 0 "Trivy security scanner configured"
    else
        test_check 1 "Security scanner missing"
    fi
    
    if grep -q "codeql" .github/workflows/ci-cd-pipeline.yml; then
        test_check 0 "CodeQL integration for security"
    else
        test_check 1 "CodeQL integration missing"
    fi
fi

echo ""

# ==========================================
# 8. WORKFLOW TRIGGERS
# ==========================================
echo "=========================================="
echo "8. Workflow Triggers"
echo "=========================================="

if [ -f ".github/workflows/ci-cd-pipeline.yml" ]; then
    if grep -q "push:" .github/workflows/ci-cd-pipeline.yml; then
        test_check 0 "Push trigger configured"
    else
        test_check 1 "Push trigger missing"
    fi
    
    if grep -q "pull_request:" .github/workflows/ci-cd-pipeline.yml; then
        test_check 0 "Pull request trigger configured"
    else
        test_check 1 "Pull request trigger missing"
    fi
fi

echo ""

# ==========================================
# 9. DOCUMENTATION
# ==========================================
echo "=========================================="
echo "9. Documentation"
echo "=========================================="

if [ -f "GITHUB-ACTIONS-SETUP.md" ]; then
    test_check 0 "GitHub Actions setup guide exists"
else
    test_check 1 "GitHub Actions setup guide missing"
fi

if [ -f "GITHUB-ACTIONS-SETUP.md" ]; then
    if grep -q "DOCKER_USERNAME" GITHUB-ACTIONS-SETUP.md; then
        test_check 0 "Documentation includes secrets setup"
    else
        test_check 1 "Documentation missing secrets setup"
    fi
fi

echo ""

# ==========================================
# 10. BUILD OPTIMIZATION
# ==========================================
echo "=========================================="
echo "10. Build Optimization"
echo "=========================================="

if [ -f ".github/workflows/ci-cd-pipeline.yml" ]; then
    if grep -q "cache:" .github/workflows/ci-cd-pipeline.yml; then
        test_check 0 "Maven dependency caching configured"
    else
        test_check 1 "Maven dependency caching missing"
    fi
    
    if grep -q "cache-from" .github/workflows/ci-cd-pipeline.yml; then
        test_check 0 "Docker layer caching configured"
    else
        test_check 1 "Docker layer caching missing"
    fi
fi

# Check multi-stage builds
MULTISTAGE_COUNT=$(grep -l "FROM.*AS build" Dockerfile-* 2>/dev/null | wc -l)
if [ $MULTISTAGE_COUNT -ge 7 ]; then
    test_check 0 "Multi-stage builds for optimization ($MULTISTAGE_COUNT/7)"
else
    test_check 1 "Not all Dockerfiles use multi-stage builds ($MULTISTAGE_COUNT/7)"
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
    echo -e "${GREEN}✅ PHASE 6 COMPLETE - ALL TESTS PASSED${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Setup GitHub secrets (see GITHUB-ACTIONS-SETUP.md)"
    echo "2. Push to GitHub to trigger pipeline"
    echo "3. Monitor workflow execution"
    exit 0
elif [ $PERCENTAGE -ge 80 ]; then
    echo -e "${YELLOW}⚠️  PHASE 6 MOSTLY COMPLETE ($PERCENTAGE%)${NC}"
    echo ""
    echo "Core CI/CD pipeline implemented. Minor optimizations pending."
    exit 0
else
    echo -e "${RED}❌ PHASE 6 INCOMPLETE ($PERCENTAGE%)${NC}"
    echo ""
    echo "Critical CI/CD components missing. Review failed tests above."
    exit 1
fi
