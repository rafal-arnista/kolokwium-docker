#!/usr/bin/env bash
set -euo pipefail

BASE="${BASE_URL:-http://localhost:8080}"
PASS=0
FAIL=0

ok()   { echo "  PASS: $1"; ((PASS++)); }
fail() { echo "  FAIL: $1"; ((FAIL++)); }

echo "=== Smoke test: $BASE ==="

# 1. Health check
echo
echo "1. Health check (GET /health)"
STATUS=$(curl -sf -o /dev/null -w "%{http_code}" "$BASE/health")
[ "$STATUS" = "200" ] && ok "HTTP 200" || fail "HTTP $STATUS"

BODY=$(curl -sf "$BASE/health")
echo "$BODY" | grep -q "status" && ok "body contains ok" || fail "unexpected body: $BODY"

# 2. Create resource
echo
echo "2. Create task (POST /tasks)"
RESPONSE=$(curl -sf -X POST "$BASE/tasks" \
  -H "Content-Type: application/json" \
  -d '{"title": "smoke-test task", "priority": "high"}')
echo "$RESPONSE" | grep -q '"id"' && ok "response contains id" || fail "unexpected response: $RESPONSE"
echo "$RESPONSE" | grep -q '"smoke-test task"' && ok "title echoed back" || fail "title missing"

# 3. List resources
echo
echo "3. List tasks (GET /tasks)"
LIST=$(curl -sf "$BASE/tasks")
echo "$LIST" | grep -q '"smoke-test task"' && ok "created task visible in list" || fail "task not found in list: $LIST"

echo
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
