# AI 任务管理 API

基于 Laravel 框架实现的任务管理 API 服务，支持 Docker Compose 一键启动。

## 功能特性

- ✅ 健康检查接口 (`GET /api/health`)
- ✅ 任务 CRUD 操作
- ✅ 按状态/优先级筛选
- ✅ 按创建时间/优先级排序
- ✅ 分页查询
- ✅ 数据持久化到 MySQL
- ✅ Docker Compose 一键启动

## 技术栈

- Laravel 11.x
- PHP 8.2
- MySQL 8.0
- Nginx
- Docker Compose

## 快速开始

### 1. 启动服务

```bash
docker compose up --build -d
```

服务启动后：
- API 访问地址: `http://localhost:8000`
- MySQL 端口: `3307`

### 2. 运行数据库迁移

容器启动脚本会自动等待 MySQL 就绪并执行迁移。如需手动执行：

```bash
docker compose exec php php artisan migrate
```

### 3. 运行测试

```bash
docker compose exec php bash tests/test_api.sh
```

### 4. 停止服务

```bash
docker compose down
```

### 5. 清理数据

```bash
docker compose down -v
```

## API 接口

### 健康检查

```http
GET /api/health
```

响应：
```json
{
  "status": "ok",
  "service": "task-api"
}
```

### 创建任务

```http
POST /api/tasks
```

请求体：
```json
{
  "title": "任务标题",
  "description": "任务描述",
  "status": "pending",
  "priority": 4
}
```

响应：
```json
{
  "id": 1,
  "title": "任务标题",
  "description": "任务描述",
  "status": "pending",
  "priority": 4,
  "created_at": "2026-07-16T14:22:51.000000Z",
  "updated_at": "2026-07-16T14:22:51.000000Z"
}
```

### 查询任务列表

```http
GET /api/tasks?status=pending&sort=priority&order=desc&page=1&per_page=10
```

参数：
- `status`: 状态筛选 (`pending`, `running`, `completed`, `failed`)
- `priority`: 优先级筛选 (1-5)
- `sort`: 排序字段 (`priority`, `created_at`, `updated_at`)
- `order`: 排序方向 (`asc`, `desc`)
- `page`: 页码
- `per_page`: 每页数量 (1-100)

响应：
```json
{
  "data": [...],
  "meta": {
    "current_page": 1,
    "per_page": 10,
    "total": 100,
    "last_page": 10
  }
}
```

### 查询单个任务

```http
GET /api/tasks/{id}
```

响应：
```json
{
  "id": 1,
  "title": "任务标题",
  "description": "任务描述",
  "status": "pending",
  "priority": 4,
  "created_at": "2026-07-16T14:22:51.000000Z",
  "updated_at": "2026-07-16T14:22:51.000000Z"
}
```

### 修改任务

```http
PATCH /api/tasks/{id}
```

请求体：
```json
{
  "status": "running",
  "priority": 5
}
```

响应：
```json
{
  "id": 1,
  "title": "任务标题",
  "description": "任务描述",
  "status": "running",
  "priority": 5,
  "created_at": "2026-07-16T14:22:51.000000Z",
  "updated_at": "2026-07-16T14:23:22.000000Z"
}
```

### 删除任务

```http
DELETE /api/tasks/{id}
```

响应：HTTP 204 No Content

### 完成任务

```http
POST /api/tasks/{id}/complete
```

响应：
```json
{
  "id": 1,
  "title": "任务标题",
  "description": "任务描述",
  "status": "completed",
  "priority": 4,
  "created_at": "2026-07-16T14:22:51.000000Z",
  "updated_at": "2026-07-16T14:24:00.000000Z"
}
```

## 任务字段

| 字段 | 类型 | 说明 |
|------|------|------|
| id | 整数 | 主键 |
| title | 字符串 | 任务标题，必填，最长 100 字符 |
| description | 文本 | 任务描述，可选 |
| status | 字符串 | `pending`、`running`、`completed`、`failed` |
| priority | 整数 | 1-5，数字越大优先级越高 |
| created_at | 时间 | 创建时间 |
| updated_at | 时间 | 修改时间 |

## 错误响应

### 404 任务不存在

```json
{
  "error": "Task not found"
}
```

### 422 参数验证失败

```json
{
  "error": "Validation failed",
  "details": {
    "title": ["The title field is required."]
  }
}
```

## 目录结构

```
.
├── app/
│   ├── Http/
│   │   └── Controllers/
│   │       └── TaskController.php
│   └── Models/
│       └── Task.php
├── bootstrap/
│   └── app.php
├── config/
├── database/
│   └── migrations/
│       └── 2026_07_16_000001_create_tasks_table.php
├── docker/
│   └── nginx/
│       └── default.conf
├── public/
├── routes/
│   ├── api.php
│   ├── console.php
│   └── web.php
├── tests/
│   └── test_api.sh
├── Dockerfile
├── compose.yaml
├── .env
├── .env.example
├── README.md
├── AI_NOTES.md
├── AGENT.md
├── artisan
├── composer.json
├── composer.lock
└── docker-entrypoint.sh
```

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| APP_ENV | local | 应用环境 |
| APP_KEY | - | 应用密钥 |
| DB_HOST | mysql | 数据库主机 |
| DB_PORT | 3306 | 数据库端口 |
| DB_DATABASE | task_api | 数据库名 |
| DB_USERNAME | admin | 数据库用户名 |
| DB_PASSWORD | secret | 数据库密码 |

## 生产部署建议

当前配置适用于开发环境，生产部署应考虑：

1. 使用正式的 SSL 证书和 HTTPS
2. 配置适当的安全中间件
3. 使用 Redis 缓存提高性能
4. 配置队列处理异步任务
5. 设置适当的日志轮转
6. 使用环境变量管理敏感配置
7. 配置防火墙和安全组
