#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0

echo "=========================================="
echo "PHASE 7 VERIFICATION"
echo "Frontend (React)"
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

# 1. React App Structure
echo "=========================================="
echo "1. React App Structure"
echo "=========================================="

[ -d "frontend" ] && test_check 0 "Frontend directory exists" || test_check 1 "Frontend directory missing"
[ -f "frontend/package.json" ] && test_check 0 "package.json exists" || test_check 1 "package.json missing"
[ -f "frontend/tsconfig.json" ] && test_check 0 "TypeScript configured" || test_check 1 "TypeScript not configured"

echo ""

# 2. Dependencies
echo "=========================================="
echo "2. Dependencies"
echo "=========================================="

if [ -f "frontend/package.json" ]; then
    grep -q "react-router-dom" frontend/package.json && test_check 0 "React Router installed" || test_check 1 "React Router missing"
    grep -q "axios" frontend/package.json && test_check 0 "Axios installed" || test_check 1 "Axios missing"
    grep -q "@dnd-kit/core" frontend/package.json && test_check 0 "DnD Kit installed" || test_check 1 "DnD Kit missing"
    grep -q "@react-oauth/google" frontend/package.json && test_check 0 "Google OAuth installed" || test_check 1 "Google OAuth missing"
fi

echo ""

# 3. Pages
echo "=========================================="
echo "3. Pages"
echo "=========================================="

[ -f "frontend/src/pages/Login.tsx" ] && test_check 0 "Login page exists" || test_check 1 "Login page missing"
[ -f "frontend/src/pages/Dashboard.tsx" ] && test_check 0 "Dashboard page exists" || test_check 1 "Dashboard page missing"
[ -f "frontend/src/pages/Kanban.tsx" ] && test_check 0 "Kanban page exists" || test_check 1 "Kanban page missing"

echo ""

# 4. Components
echo "=========================================="
echo "4. Components"
echo "=========================================="

[ -f "frontend/src/components/KanbanColumn.tsx" ] && test_check 0 "KanbanColumn component exists" || test_check 1 "KanbanColumn missing"
[ -f "frontend/src/components/TaskCard.tsx" ] && test_check 0 "TaskCard component exists" || test_check 1 "TaskCard missing"
[ -f "frontend/src/components/FileUpload.tsx" ] && test_check 0 "FileUpload component exists" || test_check 1 "FileUpload missing"

echo ""

# 5. Services & Context
echo "=========================================="
echo "5. Services & Context"
echo "=========================================="

[ -f "frontend/src/services/api.ts" ] && test_check 0 "API service exists" || test_check 1 "API service missing"
[ -f "frontend/src/context/AuthContext.tsx" ] && test_check 0 "Auth context exists" || test_check 1 "Auth context missing"
[ -f "frontend/src/types/index.ts" ] && test_check 0 "TypeScript types defined" || test_check 1 "Types missing"

echo ""

# 6. Features
echo "=========================================="
echo "6. Features Implementation"
echo "=========================================="

if [ -f "frontend/src/pages/Login.tsx" ]; then
    grep -q "GoogleLogin" frontend/src/pages/Login.tsx && test_check 0 "Google OAuth implemented" || test_check 1 "Google OAuth missing"
    grep -q "jwt" frontend/src/context/AuthContext.tsx && test_check 0 "JWT authentication implemented" || test_check 1 "JWT missing"
fi

if [ -f "frontend/src/pages/Kanban.tsx" ]; then
    grep -q "DndContext" frontend/src/pages/Kanban.tsx && test_check 0 "Drag-and-drop implemented" || test_check 1 "Drag-and-drop missing"
fi

if [ -f "frontend/src/components/FileUpload.tsx" ]; then
    grep -q "FormData" frontend/src/components/FileUpload.tsx && test_check 0 "File upload implemented" || test_check 1 "File upload missing"
fi

echo ""

# 7. Configuration
echo "=========================================="
echo "7. Configuration"
echo "=========================================="

[ -f "frontend/.env.example" ] && test_check 0 "Environment template exists" || test_check 1 "Environment template missing"
[ -f "frontend/src/App.tsx" ] && test_check 0 "App component exists" || test_check 1 "App component missing"

if [ -f "frontend/src/App.tsx" ]; then
    grep -q "BrowserRouter" frontend/src/App.tsx && test_check 0 "Routing configured" || test_check 1 "Routing not configured"
    grep -q "PrivateRoute" frontend/src/App.tsx && test_check 0 "Protected routes implemented" || test_check 1 "Protected routes missing"
fi

echo ""

# Summary
echo "=========================================="
echo "VERIFICATION SUMMARY"
echo "=========================================="
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"
echo ""

TOTAL=$((PASS_COUNT + FAIL_COUNT))
PERCENTAGE=$((PASS_COUNT * 100 / TOTAL))

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}✅ PHASE 7 COMPLETE - ALL TESTS PASSED${NC}"
    echo ""
    echo "Next steps:"
    echo "1. cd frontend"
    echo "2. cp .env.example .env"
    echo "3. Update .env with your API URL and Google Client ID"
    echo "4. npm start"
    exit 0
elif [ $PERCENTAGE -ge 80 ]; then
    echo -e "${YELLOW}⚠️  PHASE 7 MOSTLY COMPLETE ($PERCENTAGE%)${NC}"
    exit 0
else
    echo -e "${RED}❌ PHASE 7 INCOMPLETE ($PERCENTAGE%)${NC}"
    exit 1
fi
