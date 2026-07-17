# AI 使用记录与复盘

## 1. 使用的 AI 工具

- Trae AI Agent（内部开发的代码助手）

## 2. 关键提示词

1. "创建一个 Laravel 项目的 Docker Compose 配置，包含 Nginx、PHP-FPM 和 MySQL"
2. "为任务管理 API 创建 Laravel Migration，包含 title、description、status、priority 字段"
3. "实现任务 CRUD API，支持筛选、排序和分页"
4. "编写 Docker Entrypoint 脚本，处理 MySQL 就绪检查"
5. "修复 Laravel Controller 基类不存在的问题"

## 3. AI 生成的主要内容

1. **Docker 配置文件**: `Dockerfile`、`compose.yaml`、`docker/nginx/default.conf`、`docker-entrypoint.sh`
2. **Laravel 代码**: `app/Models/Task.php`、`app/Http/Controllers/TaskController.php`、`database/migrations/2026_07_16_000001_create_tasks_table.php`、`routes/api.php`
3. **配置文件**: `.env`、`.env.example`、`bootstrap/app.php`
4. **测试脚本**: `tests/test_api.sh`
5. **文档**: `README.md`

## 4. AI 给出的错误或不适用的建议

1. **路由冲突**: AI 在 `routes/console.php` 中定义了自定义的 `migrate` 命令，覆盖了 Laravel 默认命令，导致迁移失败。
2. **Controller 基类**: AI 生成的 `TaskController` 使用了不存在的 `App\Http\Controllers\Controller` 基类（Laravel 11 中需使用 `Illuminate\Routing\Controller`）。
3. **中间件问题**: AI 添加了 `EnsureFrontendRequestsAreStateful` 中间件，导致 JSON 请求体无法正确解析。
4. **健康检查路由**: AI 在 `bootstrap/app.php` 中配置了 `health: '/api/health'`，与自定义路由冲突。

## 5. 验证与修正方法

1. **路由冲突**: 通过查看 `routes/console.php` 文件，发现自定义命令覆盖了默认命令，删除了这些自定义命令。
2. **Controller 基类**: 通过运行 `php artisan route:list` 发现类不存在错误，修改为 `Illuminate\Routing\Controller`。
3. **中间件问题**: 通过测试 API 发现验证失败（参数无法获取），移除了 `EnsureFrontendRequestsAreStateful` 中间件。
4. **健康检查路由**: 通过测试发现返回 HTML 而不是 JSON，移除了 `health` 配置。
5. **数据库迁移**: 通过查看日志发现 `"--force" option does not exist` 错误，定位到 `routes/console.php` 的问题。

## 6. 后续改进方向

如果有更多时间，会继续改进：

1. **添加 Redis 缓存**: 为 `GET /api/tasks/{id}` 添加缓存，并在更新/删除时失效缓存。
2. **实现幂等创建**: 添加 `Idempotency-Key` 请求头支持，防止重复创建任务。
3. **添加 Laravel Feature Test**: 使用 PHPUnit 编写单元测试和功能测试。
4. **添加认证**: 使用 Laravel Sanctum 实现 API 认证。
5. **优化 Docker 镜像**: 使用多阶段构建，减小镜像体积。
6. **添加限流**: 防止 API 被恶意请求攻击。
7. **添加日志监控**: 配置 ELK 或其他日志系统。
8. **优化数据库**: 添加索引，优化查询性能。
