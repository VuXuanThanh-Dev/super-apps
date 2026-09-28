# Tập 3 — C# Nâng cao: backend thật

Tập này dựng backend thật: Web API, database, hiệu năng, concurrency,
kiến trúc, logging và Docker. Tập kết thúc bằng một dự án Web API hoàn chỉnh.

## Mục lục

| # | Chương | Ý chính | Ví dụ chạy được |
|---|---|---|---|
| 1 | [ASP.NET Core Web API](01-web-api.md) | Minimal API, routing, DTO, validation, status code, middleware | `V3Ch01.MinimalApi` |
| 2 | [EF Core với SQLite](02-ef-core.md) | `DbContext`, entity, query, migration/`EnsureCreated`, tracking | `V3Ch02.EfCore` |
| 3 | [Hiệu năng: Span, bộ nhớ, BenchmarkDotNet](03-performance.md) | `Span<T>`, `stackalloc`, `ArrayPool`, GC, benchmark | `V3Ch03.Spans`, `V3Ch03.Bench` |
| 4 | [Concurrency](04-concurrency.md) | `Task.Run`, `Parallel`, `lock`/`Lock`, `Interlocked`, `Channel<T>` | `V3Ch04.Concurrency` |
| 5 | [Clean architecture](05-clean-architecture.md) | Domain / Application / Infrastructure / Api, dependency rule | xem `final-project/` |
| 6 | [Logging và observability](06-logging-observability.md) | `ILogger`, structured logging, health checks, OpenTelemetry | `V3Ch06.Logging` |
| 7 | [Docker và dự án cuối](07-docker-du-an-cuoi.md) | Dockerfile multi-stage, chạy container, tổng kết dự án | `final-project/` |

Dự án cuối: [`final-project/`](final-project/README.md) — Web API quản lý công việc
(TaskBoard) với EF Core SQLite, xUnit (unit + integration), Dockerfile.

## Chạy ví dụ

```bash
cd books/csharp
./vol3-advanced/run-examples.sh
```

## Quy ước trình bày

- Thuật ngữ tiếng Anh giữ nguyên, giải thích tiếng Việt ở lần đầu; xem thêm Glossary cuối sách.
- Code và output trong sách được chép tự động từ file thật trong `examples/` sau mỗi lần chạy.
- Kiểm tra hiển thị tiếng Việt: ắ ằ ẳ ẵ ặ ơ ư đ Ư Đ (nếu các chữ này hiện đúng, font đã đủ dấu).
