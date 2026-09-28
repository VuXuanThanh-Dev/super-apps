# Test result — docs-writer

- Date: 2026-09-28
- Mode: real (headless `claude -p`)
- Delegated to: docs-writer
- Correct agent triggered: yes
- Tools the subagent used: Glob, Read, Write

## Prompt

Viết README song ngữ (tiếng Việt + English) cho app Node này: cài đặt, chạy, test, endpoint.

## Result (verbatim)

Subagent **docs-writer** đã hoàn tất. File `README.md` được tạo tại gốc dự án. Dưới đây là nguyên văn báo cáo của agent:

Đã tạo README.md song ngữ tại gốc dự án dựa trên nội dung thực tế đọc được từ `package.json`, `server.js`, `server.test.js`.

### File đã tạo/sửa
- `/tmp/claude-0/-home-user-super-apps/dc3b63d6-198e-59e3-b3c8-1c8b388a1027/scratchpad/agent-tests/docs-writer/README.md` (mới tạo)

### Những điều chưa xác minh (UNVERIFIED)
- Phiên bản Node.js chính xác được yêu cầu: repo không có `.nvmrc` hay trường `engines` trong `package.json`. Tôi khuyến nghị Node.js 18 LTS trở lên vì đó là bản ổn định `node:test` (test runner dùng trong `server.test.js`), nhưng đây là suy luận, không phải con số được xác nhận trong repo.

Toàn bộ nội dung file README.md:

```markdown
# hello-api

Tài liệu song ngữ Tiếng Việt / English.

---

## Tiếng Việt

### 1. Giới thiệu ngắn về app

`hello-api` là một Node.js HTTP server rất nhỏ, chỉ dùng module có sẵn `node:http` (không có
framework như Express, không có dependency ngoài nào). App hiện chỉ có một endpoint kiểm tra
tình trạng server (`health check`): `GET /health`.

### 2. Yêu cầu hệ thống

- **Node.js**: cần bản Node có sẵn module test runner `node:test` (dùng trong `server.test.js`).
  Module này ổn định từ Node.js 18 trở lên. **UNVERIFIED**: repo không có file `.nvmrc` hay
  trường `engines` trong `package.json` để chốt chính xác phiên bản Node yêu cầu, nên khuyến nghị
  dùng **Node.js 18 LTS trở lên**.
- **Package manager**: `npm` (repo không có `package-lock.json`, `yarn.lock` hay `pnpm-lock.yaml`,
  nên dùng `npm` là lựa chọn mặc định).
- App **không có dependency** nào trong `package.json` (không có trường `dependencies` /
  `devDependencies`).

### 3. Cài đặt

```bash
npm install
```

Vì `package.json` không khai báo dependency nào nên bước này chủ yếu để tạo `node_modules`
rỗng (nếu có) và đảm bảo môi trường npm hoạt động đúng.

### 4. Cách chạy app

Script chạy app được định nghĩa trong `package.json`:

```bash
npm start
```

Lệnh này chạy `node server.js` (xem trường `scripts.start` trong `package.json`).

**Biến môi trường:**

| Biến   | Mặc định | Mô tả                                   |
|--------|----------|------------------------------------------|
| `PORT` | `3000`   | Cổng HTTP server sẽ lắng nghe (xem `server.js` dòng 2) |

Ví dụ chạy với cổng khác:

```bash
PORT=4000 npm start
```

Sau khi chạy, server in ra log dạng `listening on <port>`.

### 5. Cách chạy test

Script test dùng Node.js test runner có sẵn (`node --test`, khai báo trong
`scripts.test` của `package.json`):

```bash
npm test
```

File test hiện có: `server.test.js`, kiểm tra rằng `GET /health` trả về status `200` và
body JSON `{ "status": "ok" }`.

### 6. Danh sách endpoint API

| Method | Path      | Mô tả                                           | Response                                              |
|--------|-----------|--------------------------------------------------|--------------------------------------------------------|
| GET    | `/health` | Health check, dùng để kiểm tra server còn sống  | `200 OK`, header `Content-Type: application/json`, body `{"status":"ok"}` |
| *      | (khác)    | Bất kỳ path nào khác không được xử lý riêng      | `404 Not Found`, không có body                         |

Toàn bộ logic routing nằm trong hàm `handler` ở `server.js`. Hiện tại app chỉ có đúng một
route (`/health`); mọi request khác (bất kỳ method hay path nào, vì code chỉ kiểm tra
`req.url`) đều trả về `404`.

---

## English

### 1. Short introduction

`hello-api` is a very small Node.js HTTP server built with only the built-in `node:http`
module (no framework like Express, no external dependencies). It currently exposes a single
health-check endpoint: `GET /health`.

### 2. Requirements

- **Node.js**: needs a Node version that includes the stable `node:test` test runner (used by
  `server.test.js`). This module is stable from Node.js 18 onward. **UNVERIFIED**: there is no
  `.nvmrc` file or `engines` field in `package.json` to pin the exact required Node version, so
  **Node.js 18 LTS or later** is recommended.
- **Package manager**: `npm` (the repo has no `package-lock.json`, `yarn.lock`, or
  `pnpm-lock.yaml`, so `npm` is the default choice).
- The app has **no dependencies** declared in `package.json` (no `dependencies` /
  `devDependencies` fields).

### 3. Installation

```bash
npm install
```

Since `package.json` declares no dependencies, this step mainly ensures the npm environment
is set up correctly (it will create an empty/near-empty `node_modules`).

### 4. Running the app

The run script is defined in `package.json`:

```bash
npm start
```

This runs `node server.js` (see the `scripts.start` field in `package.json`).

**Environment variables:**

| Variable | Default | Description                                          |
|----------|---------|--------------------------------------------------------|
| `PORT`   | `3000`  | HTTP port the server listens on (see `server.js` line 2) |

Example, running on a different port:

```bash
PORT=4000 npm start
```

Once running, the server logs a line like `listening on <port>`.

### 5. Running tests

Tests use Node.js's built-in test runner (`node --test`, declared in the `scripts.test`
field of `package.json`):

```bash
npm test
```

Current test file: `server.test.js`, which checks that `GET /health` returns status `200`
and JSON body `{ "status": "ok" }`.

### 6. API Endpoints

| Method | Path      | Description                                  | Response                                                   |
|--------|-----------|-----------------------------------------------|-------------------------------------------------------------|
| GET    | `/health` | Health check, used to verify the server is up | `200 OK`, header `Content-Type: application/json`, body `{"status":"ok"}` |
| *      | (other)   | Any other path not explicitly handled         | `404 Not Found`, no body                                     |

All routing logic lives in the `handler` function in `server.js`. There is currently only one
route (`/health`); any other request (any method or path, since the code only checks
`req.url`) returns `404`.

---

## Nguồn tham khảo (Sources)

Toàn bộ nội dung trong tài liệu này được rút ra trực tiếp từ mã nguồn trong repo, không dùng
nguồn bên ngoài:

- `package.json`
- `server.js`
- `server.test.js`
```
