#!/bin/bash

API_URL=http://nginx

echo "=== 测试 1: 健康检查 ==="
curl -s "$API_URL/api/health"
echo ""
echo ""

echo "=== 测试 2: 创建任务 ==="
curl -s -X POST "$API_URL/api/tasks" \
  -H "Content-Type: application/json" \
  -d '{"title":"封装 Laravel 服务","description":"使用 Docker Compose 启动","status":"pending","priority":4}'
echo ""
echo ""

echo "=== 测试 3: 缺少标题校验失败 ==="
curl -s -X POST "$API_URL/api/tasks" \
  -H "Content-Type: application/json" \
  -d '{"description":"缺少标题"}'
echo ""
echo ""

echo "=== 测试 4: 查询任务列表 ==="
curl -s "$API_URL/api/tasks"
echo ""
echo ""

echo "=== 测试 5: 查询单个任务 ==="
curl -s "$API_URL/api/tasks/1"
echo ""
echo ""

echo "=== 测试 6: 修改任务状态 ==="
curl -s -X PATCH "$API_URL/api/tasks/1" \
  -H "Content-Type: application/json" \
  -d '{"status":"running"}'
echo ""
echo ""

echo "=== 测试 7: 查询不存在的任务 ==="
curl -s -w "HTTP Status: %{http_code}\n" "$API_URL/api/tasks/999"
echo ""

echo "=== 测试 8: 删除任务 ==="
curl -s -w "HTTP Status: %{http_code}\n" -X DELETE "$API_URL/api/tasks/1"
echo ""
