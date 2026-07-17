#!/bin/bash

set -euo pipefail

API_URL="${API_URL:-http://nginx}"
TMP_DIR="$(mktemp -d)"
RESPONSE_FILE="$TMP_DIR/response.json"

trap 'rm -rf "$TMP_DIR"' EXIT

request() {
  local label="$1"
  local expected_status="$2"
  shift 2

  echo "=== ${label} ==="

  local http_status
  http_status="$(curl -sS -o "$RESPONSE_FILE" -w "%{http_code}" "$@")"

  if [ -s "$RESPONSE_FILE" ]; then
    cat "$RESPONSE_FILE"
    echo ""
  fi

  echo "HTTP Status: ${http_status}"

  if [ "$http_status" != "$expected_status" ]; then
    echo "Expected HTTP ${expected_status}, got HTTP ${http_status}" >&2
    exit 1
  fi

  echo ""
}

request "测试 1: 健康检查" "200" \
  "$API_URL/api/health"

request "测试 2: 创建任务" "201" \
  -X POST "$API_URL/api/tasks" \
  -H "Content-Type: application/json" \
  -d '{"title":"封装 Laravel 服务","description":"使用 Docker Compose 启动","status":"pending","priority":4}'

TASK_ID="$(php -r '$data = json_decode(file_get_contents($argv[1]), true); if (!isset($data["id"])) { fwrite(STDERR, "Missing task id\n"); exit(1); } echo $data["id"];' "$RESPONSE_FILE")"

request "测试 3: 缺少标题校验失败" "422" \
  -X POST "$API_URL/api/tasks" \
  -H "Content-Type: application/json" \
  -d '{"description":"缺少标题"}'

request "测试 4: 查询任务列表" "200" \
  "$API_URL/api/tasks?status=pending&sort=priority&order=desc&page=1&per_page=10"

request "测试 5: 查询单个任务" "200" \
  "$API_URL/api/tasks/$TASK_ID"

request "测试 6: 修改任务状态" "200" \
  -X PATCH "$API_URL/api/tasks/$TASK_ID" \
  -H "Content-Type: application/json" \
  -d '{"status":"running"}'

request "测试 7: 查询不存在的任务" "404" \
  "$API_URL/api/tasks/999999999"

request "测试 8: 删除任务" "204" \
  -X DELETE "$API_URL/api/tasks/$TASK_ID"

echo "All API checks passed."
