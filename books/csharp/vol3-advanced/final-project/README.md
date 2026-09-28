# TaskBoard API — dự án cuối Tập 3

Web API quản lý công việc (task board) viết bằng **ASP.NET Core Minimal API (.NET 10)**,
**EF Core 10 + SQLite**, theo **clean architecture**, có **unit + integration test** (xUnit v3)
và **Dockerfile** multi-stage. Giải thích chi tiết: Tập 3, Chương 5 và Chương 7.

## Phiên bản (pinned)

| Thành phần | Phiên bản |
|---|---|
| .NET SDK | 10.0.112 (`global.json`, `rollForward: latestFeature`) |
| Runtime / ASP.NET Core | 10.0.12 |
| EF Core Sqlite / Design, `dotnet-ef` | 10.0.12 |
| Microsoft.AspNetCore.OpenApi | 10.0.12 |
| xunit.v3 | 4.0.1 |
| Microsoft.AspNetCore.Mvc.Testing | 10.0.12 |
| Docker base images | `mcr.microsoft.com/dotnet/sdk:10.0.401`, `mcr.microsoft.com/dotnet/aspnet:10.0.12` |

Thư mục này **tự chứa** (có `global.json` và `Directory.Build.props` riêng) để dùng làm Docker build context.

## Cấu trúc

```text
src/TaskBoard.Domain          entity TaskItem + quy tắc nghiệp vụ (không phụ thuộc framework)
src/TaskBoard.Application     use cases (TaskService), DTO, port ITaskRepository
src/TaskBoard.Infrastructure  EF Core DbContext, repository, migrations
src/TaskBoard.Api             Minimal API endpoints, xử lý lỗi, health check, OpenAPI
tests/TaskBoard.UnitTests         domain + use case + architecture tests (không DB)
tests/TaskBoard.IntegrationTests  gọi HTTP thật vào API (WebApplicationFactory + SQLite in-memory)
```

## Chạy

```bash
cd books/csharp/vol3-advanced/final-project
dotnet build TaskBoard.slnx
dotnet test --solution TaskBoard.slnx          # 28 tests
dotnet run --project src/TaskBoard.Api --urls http://localhost:5080
# mở http://localhost:5080/openapi/v1.json, gửi request trong requests.http
```

Database SQLite `taskboard.db` được tạo và migrate tự động khi khởi động
(`Database:MigrateOnStartup` trong `appsettings.json`).

### Migrations

```bash
dotnet tool restore
dotnet ef migrations add <Name> --project src/TaskBoard.Infrastructure --startup-project src/TaskBoard.Api --output-dir Migrations
dotnet ef migrations has-pending-model-changes --project src/TaskBoard.Infrastructure --startup-project src/TaskBoard.Api
```

### Docker

```bash
docker build -t taskboard-api:dev .
docker run -d -p 8080:8080 --name taskboard taskboard-api:dev
curl http://localhost:8080/health
# hoặc
docker compose up -d        # có volume taskboard-data cho SQLite
```

Sau proxy công ty có TLS inspection, truyền CA qua BuildKit secret:
`docker build --secret id=ca_bundle,src=/path/ca-bundle.crt -t taskboard-api:dev .`
(hoặc `CA_BUNDLE=/path/ca-bundle.crt ./scripts/docker-smoke.sh`).

## API

| Method | Route | Kết quả |
|---|---|---|
| GET | `/api/tasks?status=Todo&search=học&page=1&pageSize=20` | 200 |
| GET | `/api/tasks/{id}` | 200 / 404 |
| POST | `/api/tasks` | 201 / 400 |
| PUT | `/api/tasks/{id}` | 200 / 400 / 404 / 409 |
| PATCH | `/api/tasks/{id}/status` (`Todo → InProgress → Done`, `InProgress → Todo`) | 200 / 404 / 409 |
| DELETE | `/api/tasks/{id}` | 204 / 404 |
| GET | `/health`, `/openapi/v1.json` | |

Lỗi trả về theo **Problem Details** (RFC 7807, bản mới RFC 9457): 400 validation, 404 not found, 409 vi phạm quy tắc nghiệp vụ.

## Kết quả kiểm tra (chạy thật)

- `dotnet build` + `dotnet test`: xem output trong `../05-clean-architecture.md`
  (sinh bởi `../examples/V3Ch05.FinalProjectTests/run.sh`).
- `docker build` + `docker run` + gọi API: xem output trong `../07-docker-du-an-cuoi.md`
  (sinh bởi `scripts/docker-smoke.sh`).
