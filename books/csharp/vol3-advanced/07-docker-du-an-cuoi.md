# Chương 7 — Docker và dự án cuối

## Mục tiêu

- Viết Dockerfile *multi-stage* (nhiều giai đoạn) cho ASP.NET Core, dùng image chính thức từ `mcr.microsoft.com`.
- Build, chạy container, gọi API trong container.
- Chạy an toàn: user không phải root, cấu hình bằng biến môi trường, dữ liệu trong volume.
- Dùng `docker compose` và tổng kết dự án cuối.

## Giải thích đơn giản

**Docker** đóng gói ứng dụng + runtime + thư viện hệ điều hành thành một **image**. Chạy image
ra **container** — ở đâu cũng chạy giống nhau (máy bạn, CI, server).

Với Angular, bạn build ra thư mục `dist/` rồi phục vụ bằng nginx. Với .NET:

1. Stage **build**: image SDK (có compiler) → `dotnet publish` ra thư mục `publish/`.
2. Stage **final**: image ASP.NET Core runtime (nhỏ hơn, không có compiler) + copy `publish/`.

Image cuối không chứa source code hay SDK → nhỏ hơn và ít lỗ hổng hơn.

## Ví dụ

### Dockerfile

<!-- include: final-project/Dockerfile -->
```dockerfile
# syntax=docker/dockerfile:1
# ---------- Stage 1: build & publish (SDK image, ~1 GB, not shipped) ----------
FROM mcr.microsoft.com/dotnet/sdk:10.0.401 AS build
WORKDIR /src

# Copy only project files first -> "dotnet restore" layer is cached until a .csproj changes.
COPY global.json Directory.Build.props TaskBoard.slnx ./
COPY src/TaskBoard.Domain/TaskBoard.Domain.csproj src/TaskBoard.Domain/
COPY src/TaskBoard.Application/TaskBoard.Application.csproj src/TaskBoard.Application/
COPY src/TaskBoard.Infrastructure/TaskBoard.Infrastructure.csproj src/TaskBoard.Infrastructure/
COPY src/TaskBoard.Api/TaskBoard.Api.csproj src/TaskBoard.Api/
# Optional secret "ca_bundle": only needed behind a TLS-inspecting corporate proxy
# (see README). Without the secret this is a normal "dotnet restore".
RUN --mount=type=secret,id=ca_bundle,required=false \
    if [ -f /run/secrets/ca_bundle ]; then export SSL_CERT_FILE=/run/secrets/ca_bundle; fi && \
    dotnet restore src/TaskBoard.Api/TaskBoard.Api.csproj

# Copy the source and publish a Release build.
COPY src/ src/
RUN dotnet publish src/TaskBoard.Api/TaskBoard.Api.csproj -c Release -o /app/publish --no-restore

# ---------- Stage 2: runtime (ASP.NET Core runtime only, much smaller) ----------
FROM mcr.microsoft.com/dotnet/aspnet:10.0.12 AS final
WORKDIR /app

# The SQLite file lives in /app/data (mount a volume here to keep data).
RUN mkdir -p /app/data && chown app:app /app/data
ENV ASPNETCORE_HTTP_PORTS=8080 \
    ConnectionStrings__TaskBoard="Data Source=/app/data/taskboard.db"

COPY --from=build /app/publish .

# Run as the non-root "app" user that the official .NET images provide.
USER app
EXPOSE 8080
ENTRYPOINT ["dotnet", "TaskBoard.Api.dll"]
```

<!-- include: final-project/.dockerignore -->
```text
**/bin/
**/obj/
**/*.db
**/*.db-shm
**/*.db-wal
**/TestResults/
tests/
.git
Dockerfile
```

Điểm chính:

- Tag **cố định** (`sdk:10.0.401`, `aspnet:10.0.12` — có trên mcr.microsoft.com, checked 2026-09-28)
  để build lặp lại được. Dùng tag `10.0` nếu muốn tự nhận bản vá mới.
- Copy file `.csproj` trước rồi `restore` → Docker cache lớp này; sửa code không phải tải lại gói.
- Image ASP.NET Core từ .NET 8 nghe cổng **8080** và có sẵn user **`app`** không phải root
  (theo README của image `dotnet/aspnet`).
- Chuỗi kết nối truyền qua biến môi trường `ConnectionStrings__TaskBoard` (dấu `__` thay cho `:`).
- Secret `ca_bundle` là **tùy chọn**: chỉ cần khi build sau proxy công ty có kiểm tra TLS
  (xem mục "Lỗi và bẫy"). Không có secret thì `restore` chạy bình thường.

### Build, chạy và gọi API — output thật

Script `final-project/scripts/docker-smoke.sh` build image, chạy container, gọi vài endpoint rồi dọn dẹp:

<!-- include: final-project/scripts/docker-smoke.sh -->
```bash
#!/usr/bin/env bash
# Build the Docker image, run it, call a few endpoints, then clean up.
# Behind a TLS-inspecting proxy, set CA_BUNDLE=/path/to/ca-bundle.crt (and HTTPS_PROXY).
set -euo pipefail
cd "$(dirname "$0")/.."
IMAGE=taskboard-api:dev
NAME=taskboard-smoke
PORT=18080

build_args=()
if [[ -n "${CA_BUNDLE:-}" ]]; then
  build_args+=(--network host --secret "id=ca_bundle,src=$CA_BUNDLE")
  [[ -n "${HTTPS_PROXY:-}" ]] && build_args+=(--build-arg "HTTPS_PROXY=$HTTPS_PROXY" --build-arg "HTTP_PROXY=$HTTPS_PROXY")
fi

echo "\$ docker build -t $IMAGE ."
docker build -q "${build_args[@]}" -t "$IMAGE" . >/dev/null
docker image ls "$IMAGE" --format 'image {{.Repository}}:{{.Tag}} size={{.Size}}'

docker rm -f "$NAME" >/dev/null 2>&1 || true
echo "\$ docker run -d -p $PORT:8080 --name $NAME $IMAGE"
docker run -d -p "$PORT:8080" --name "$NAME" "$IMAGE" >/dev/null
trap 'docker rm -f "$NAME" >/dev/null 2>&1 || true' EXIT

for i in $(seq 1 30); do
  curl -fsS "http://localhost:$PORT/health" >/dev/null 2>&1 && break
  sleep 1
done

call() { echo "\$ curl $*"; curl -sS -w '\n-> HTTP %{http_code}\n' "$@"; }
call "http://localhost:$PORT/health"
call -X POST "http://localhost:$PORT/api/tasks" -H 'Content-Type: application/json' \
  -d '{"title":"Triển khai bằng Docker","priority":"High","dueDate":"2030-01-31"}'
call -X PATCH "http://localhost:$PORT/api/tasks/1/status" -H 'Content-Type: application/json' -d '{"status":"Done"}'
call "http://localhost:$PORT/api/tasks?status=Todo"
echo "\$ docker exec $NAME whoami"
docker exec "$NAME" whoami
echo "\$ docker logs $NAME (last 4 lines)"
docker logs "$NAME" 2>&1 | tail -4
```

<!-- output: examples/V3Ch07.Docker -->
```text
$ docker build -t taskboard-api:dev .
image taskboard-api:dev size=401MB
$ docker run -d -p 18080:8080 --name taskboard-smoke taskboard-api:dev
$ curl http://localhost:18080/health
Healthy
-> HTTP 200
$ curl -X POST http://localhost:18080/api/tasks -H Content-Type: application/json -d {"title":"Triển khai bằng Docker","priority":"High","dueDate":"2030-01-31"}
{"id":1,"title":"Triển khai bằng Docker","description":null,"status":"Todo","priority":"High","dueDate":"2030-01-31","isOverdue":false,"createdAt":"2026-09-28T15:29:28.7572938+00:00","completedAt":null}
-> HTTP 201
$ curl -X PATCH http://localhost:18080/api/tasks/1/status -H Content-Type: application/json -d {"status":"Done"}
{"type":"https://tools.ietf.org/html/rfc9110#section-15.5.10","title":"Không chuyển được trạng thái từ Todo sang Done.","status":409,"traceId":"00-75a0b12967265e9f21bfb3137f8c92d1-959a2b6c2ec4bed2-00"}
-> HTTP 409
$ curl http://localhost:18080/api/tasks?status=Todo
{"items":[{"id":1,"title":"Triển khai bằng Docker","description":null,"status":"Todo","priority":"High","dueDate":"2030-01-31","isOverdue":false,"createdAt":"2026-09-28T15:29:28.7572938+00:00","completedAt":null}],"page":1,"pageSize":20,"totalCount":1}
-> HTTP 200
$ docker exec taskboard-smoke whoami
app
$ docker logs taskboard-smoke (last 4 lines)
info: TaskBoard.Application.TaskService[0]
      Created task 1 with priority High
info: TaskBoard.Api.ApiExceptionHandler[0]
      Request PATCH /api/tasks/1/status failed with 409: Không chuyển được trạng thái từ Todo sang Done.
```

Kết quả cho thấy: container khỏe (`Healthy`), migration chạy lúc khởi động tạo bảng, `POST` trả
**201**, chuyển thẳng `Todo → Done` bị chặn với **409** (quy tắc Domain), tiến trình chạy bằng user
`app`, và log có cấu trúc.

## Đi sâu

### Tổng kết dự án cuối `TaskBoard`

| Yêu cầu | Ở đâu | Bằng chứng |
|---|---|---|
| Web API CRUD + đổi trạng thái | `src/TaskBoard.Api/TaskEndpoints.cs` | integration tests, docker smoke |
| Validation + Problem Details | `TaskService.Validate`, `ApiExceptionHandler` | test `Post_InvalidBody_Returns400ProblemDetails` |
| EF Core + SQLite + migrations | `src/TaskBoard.Infrastructure/` | `dotnet ef migrations list` (Chương 2) |
| Clean architecture | 4 project + `ArchitectureTests` | Chương 5 |
| Unit + integration tests | `tests/` | 28 test pass (Chương 5) |
| Health check, OpenAPI, logging | `Program.cs` | `/health`, `/openapi/v1.json`, log trong container |
| Dockerfile multi-stage, non-root | `Dockerfile` | output ở trên |
| Compose + volume | `compose.yaml` | Bài tập 1 |

API:

| Method | Route | Kết quả |
|---|---|---|
| GET | `/api/tasks?status=&search=&page=&pageSize=` | 200 + trang kết quả |
| GET | `/api/tasks/{id}` | 200 / 404 |
| POST | `/api/tasks` | 201 + `Location` / 400 |
| PUT | `/api/tasks/{id}` | 200 / 400 / 404 / 409 |
| PATCH | `/api/tasks/{id}/status` | 200 / 404 / 409 |
| DELETE | `/api/tasks/{id}` | 204 / 404 |
| GET | `/health`, `/openapi/v1.json` | trạng thái, tài liệu OpenAPI |

### Kích thước image

Image cuối khoảng 400 MB (số liệu `docker image ls` ở trên). Muốn nhỏ hơn: dùng biến thể
`-alpine` hoặc *chiseled* (Ubuntu tối giản, không có shell), hoặc publish Native AOT. Các biến thể này
được mô tả trong tài liệu của repo `dotnet/dotnet-docker`. **UNVERIFIED** trong bộ sách: chưa đo kích
thước các biến thể này.

### Checklist production

- HTTPS ở reverse proxy / load balancer (container chỉ nghe HTTP 8080 bên trong mạng nội bộ).
- Secret (chuỗi kết nối DB thật, API key) qua biến môi trường hoặc secret store, **không** ghi trong image.
- Health check cho orchestrator; log ra stdout (Docker thu thập).
- Database thật (PostgreSQL/SQL Server) thay cho SQLite khi có nhiều instance.
- Chạy migration như một bước deploy riêng khi hệ thống lớn (Chương 2).

## Lỗi và bẫy thường gặp

- **Build sau proxy có TLS inspection** (gặp thật khi viết chương này): `dotnet restore` trong
  container báo `NU1301 ... The remote certificate is invalid because of errors in the certificate
  chain: UntrustedRoot`. Container không tin CA của proxy. Cách xử lý không làm bẩn image: truyền file
  CA qua BuildKit secret, chỉ dùng trong bước restore:
  `docker build --secret id=ca_bundle,src=/path/ca-bundle.crt ...` (trong môi trường viết sách còn cần
  `--network host` và `--build-arg HTTPS_PROXY=...`). Script smoke test làm việc này khi có biến `CA_BUNDLE`.
- **Copy cả thư mục `bin/obj` vào context** → build chậm, lỗi lạ. Dùng `.dockerignore`.
- **Chạy bằng root** → rủi ro bảo mật. Dùng `USER app`.
- **Lưu SQLite trong container không có volume** → mất dữ liệu khi xóa container.
- **Quên map cổng** (`-p 18080:8080`) → không truy cập được từ máy host.
- **`global.json` và SDK trong image khác band**: `rollForward: latestFeature` cho phép SDK
  10.0.401 trong image build project ghim 10.0.112.

## Tóm tắt

- Dockerfile multi-stage: SDK để build, ASP.NET runtime để chạy.
- Tag cố định, cache restore, non-root, cấu hình bằng biến môi trường, dữ liệu trong volume.
- Dự án cuối gom mọi kiến thức Tập 3: Web API, EF Core, clean architecture, test, logging, Docker.

## Bài tập (có lời giải)

1. Viết `compose.yaml` chạy API với volume cho thư mục dữ liệu; chứng minh dữ liệu còn sau khi
   restart container.
2. Vì sao Dockerfile copy các file `.csproj` và chạy `dotnet restore` **trước** khi copy source?
3. Dự án cuối nên đổi gì khi chạy 3 instance API sau load balancer?

<details>
<summary>Lời giải</summary>

**Bài 1.**

<!-- include: final-project/compose.yaml -->
```yaml
# docker compose up -d   -> API at http://localhost:8080, data kept in the "taskboard-data" volume
services:
  api:
    image: taskboard-api:dev
    build: .
    ports:
      - "8080:8080"
    environment:
      ASPNETCORE_ENVIRONMENT: Production
      ConnectionStrings__TaskBoard: "Data Source=/app/data/taskboard.db"
    volumes:
      - taskboard-data:/app/data
    restart: unless-stopped

volumes:
  taskboard-data:
```

Script kiểm tra (dùng image đã build ở trên):

<!-- include: examples/V3Ch07.Solutions/run.sh -->
```bash
#!/usr/bin/env bash
# Exercise: run the API with docker compose and check that data survives a container restart.
# Uses the image taskboard-api:dev built by V3Ch07.Docker (so no second build is needed here).
set -euo pipefail
cd ../../final-project
export COMPOSE_PROJECT_NAME=taskboard-ex
docker compose down -v >/dev/null 2>&1 || true
trap 'docker compose down -v >/dev/null 2>&1 || true' EXIT
echo '$ docker compose up -d --no-build'
docker compose up -d --no-build 2>&1 | grep -v -i "warn" | sed 's/^ *//' | grep -E "Created|Started|Running" || true
wait_up() { for i in $(seq 1 30); do curl -fsS localhost:8080/health >/dev/null 2>&1 && return; sleep 1; done; }
wait_up
echo '$ curl -X POST localhost:8080/api/tasks ...'
curl -sS -o /dev/null -w 'HTTP %{http_code}\n' -X POST localhost:8080/api/tasks -H 'Content-Type: application/json' -d '{"title":"Dữ liệu phải còn sau restart"}'
echo '$ docker compose restart api'
docker compose restart api >/dev/null 2>&1
wait_up
echo '$ curl localhost:8080/api/tasks'
curl -sS localhost:8080/api/tasks | python3 -c 'import json,sys; d=json.load(sys.stdin); print("totalCount =", d["totalCount"], "| title =", d["items"][0]["title"])'
```

<!-- output: examples/V3Ch07.Solutions -->
```text
$ docker compose up -d --no-build
Network taskboard-ex_default Created 
Volume taskboard-ex_taskboard-data Created 
Container taskboard-ex-api-1 Created 
Container taskboard-ex-api-1 Started 
$ curl -X POST localhost:8080/api/tasks ...
HTTP 201
$ docker compose restart api
$ curl localhost:8080/api/tasks
totalCount = 1 | title = Dữ liệu phải còn sau restart
```

**Bài 2.** Docker cache từng lớp (layer). Lớp `restore` chỉ phụ thuộc file `.csproj`; khi bạn chỉ sửa
code `.cs`, Docker dùng lại lớp đã restore → build nhanh hơn nhiều, không tải lại gói NuGet.

**Bài 3.** SQLite là file cục bộ — 3 container sẽ có 3 database khác nhau. Cần: database dùng chung
(PostgreSQL/SQL Server) bằng cách đổi provider EF Core và chuỗi kết nối; chạy migration một lần
trong bước deploy (tắt `Database:MigrateOnStartup`); không giữ trạng thái trong bộ nhớ của từng instance.
</details>

## Nguồn tham khảo (Sources)

- Containerize a .NET app (nguồn Microsoft Learn): https://github.com/dotnet/docs/blob/main/docs/core/docker/build-container.md
- Docker images for ASP.NET Core: https://github.com/dotnet/AspNetCore.Docs/blob/main/aspnetcore/host-and-deploy/docker/building-net-docker-images.md
- `dotnet/aspnet` image README (port 8080, non-root): https://github.com/dotnet/dotnet-docker/blob/main/README.aspnet.md
- Non-root user sample: https://github.com/dotnet/dotnet-docker/blob/main/samples/kubernetes/non-root/README.md
- Ubuntu chiseled images: https://github.com/dotnet/dotnet-docker/blob/main/documentation/ubuntu-chiseled.md
- MCR tag list (sdk): https://mcr.microsoft.com/v2/dotnet/sdk/tags/list
- Docker build secrets (nguồn docs.docker.com): https://github.com/docker/docs/blob/main/content/manuals/build/building/secrets.md
- Dockerfile reference, `RUN --mount=type=secret` (option `required`): https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/reference.md
