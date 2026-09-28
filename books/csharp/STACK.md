# STACK — Phiên bản công cụ dùng trong bộ sách

Tất cả phiên bản dưới đây được kiểm tra ngày **2026-09-28** (checked 2026-09-28).
Nguồn chính: file dữ liệu phát hành chính thức trong repo `dotnet/core`,
`dotnet/csharplang`, `dotnet/docs` và NuGet API. (learn.microsoft.com bị chặn
trong môi trường làm việc, nên dùng các repo nguồn trên GitHub — nội dung giống nhau.)

## 1. Tóm tắt

| Thành phần | Phiên bản dùng trong sách | Ghi chú |
|---|---|---|
| .NET | **.NET 10 (LTS)** | Phát hành 2025-11-11, hỗ trợ đến **2028-11-14** |
| .NET SDK (đã cài và chạy ở đây) | **10.0.112** | Feature band 1xx, gói apt của Ubuntu 24.04 |
| .NET Runtime / ASP.NET Core Runtime | **10.0.12** | Bản patch mới nhất, 2026-09-08 (có bản vá bảo mật) |
| C# | **C# 14** | Ngôn ngữ mặc định của .NET 10 |
| Test runner | Microsoft.Testing.Platform (MTP) | Bật trong `global.json` (`"test"`) |

**SDK mới nhất vs SDK đã cài:** bản SDK mới nhất của kênh 10.0 là **10.0.401**
(feature band 4xx, đi cùng Visual Studio 18.9/18.10). Máy làm việc cài **10.0.112**
(feature band 1xx). Cả hai cùng phát hành 2026-09-08 và cùng runtime **10.0.12**,
cùng C# 14. Khác nhau chỉ ở "feature band" của tooling SDK. Bản 1xx là band mà
các bản phân phối Linux build từ source dùng.

**.NET 11 thì sao?** .NET 11 đang ở giai đoạn preview: `11.0.0-rc.1`
(2026-09-08, STS, "go-live"). C# 15 sẽ đi cùng .NET 11 (unions, closed hierarchies,
labeled `break`/`continue`...). Sách này **không** dùng bản preview; chỉ dùng LTS.
(Lưu ý: `releases.json` của 11.0 rc.1 vẫn ghi `csharp-version: 14.0`, trong khi
`Language-Version-History.md` ghi C# 15.0 đi với .NET 11 — có thể trường dữ liệu
chưa được cập nhật. **UNVERIFIED** C# 15 sẽ có đủ các tính năng trên khi .NET 11 GA.)

## 2. Vì sao chọn .NET 10 LTS

| Kênh | Loại | Trạng thái (2026-09-28) | Hết hỗ trợ |
|---|---|---|---|
| 11.0 | STS | go-live (RC 1) | — |
| **10.0** | **LTS** | **active** | **2028-11-14** |
| 9.0 | STS | maintenance | 2026-11-10 |
| 8.0 | LTS | maintenance | 2026-11-10 |

- LTS (Long Term Support) = hỗ trợ dài hạn, 3 năm. STS (Standard Term Support) = ngắn hơn.
- .NET 8 và .NET 9 đều hết hỗ trợ ngày 2026-11-10, chỉ khoảng 6 tuần nữa.
  Vì vậy dự án mới nên dùng .NET 10.

## 3. `global.json` — ghim SDK

File: [`global.json`](global.json)

```json
{
  "sdk": {
    "version": "10.0.112",
    "rollForward": "latestFeature",
    "allowPrerelease": false
  },
  "test": {
    "runner": "Microsoft.Testing.Platform"
  }
}
```

**Giải thích lựa chọn `rollForward`:**

- `version: 10.0.112` = đúng bản SDK đã cài và đã chạy toàn bộ ví dụ trong sách.
- `rollForward: latestFeature` = dùng SDK 10.0 có feature band + patch **cao nhất**
  đã cài, miễn là **≥ 10.0.112**. Ví dụ: máy bạn cài 10.0.401 (bản từ trang
  Microsoft) thì vẫn chạy được, không lỗi.
- Không roll lên 11.0 (khác major/minor), nên không vô tình dùng preview.
- Vì sao không dùng `disable` hoặc `patch`: bạn đọc cài SDK từ trang Microsoft thường
  có band 3xx/4xx, không có 10.0.112 → `disable`/`patch` sẽ báo lỗi. `latestFeature`
  giữ đúng .NET 10 + C# 14 nhưng linh hoạt về band.
- `allowPrerelease: false` = không bao giờ chọn SDK preview.
- `test.runner` = bắt buộc với .NET 10 SDK khi dùng xUnit v3 / MTP. Nếu thiếu,
  `dotnet test` báo lỗi *"Testing with VSTest target is no longer supported by
  Microsoft.Testing.Platform on .NET 10 SDK and later"* (lỗi này đã gặp thật khi
  thử ở đây).

Kiểm tra:

```text
$ cd books/csharp && dotnet --version
10.0.112
```

## 4. Cài đặt chung cho mọi project

File [`Directory.Build.props`](Directory.Build.props) áp dụng cho mọi project dưới
`books/csharp/`:

- `TargetFramework` = `net10.0`, `LangVersion` = `14.0`
- `Nullable` = `enable` (kiểm tra null lúc biên dịch)
- `ImplicitUsings` = `enable`
- `TreatWarningsAsErrors` = `true` (warning cũng làm build fail → code sạch)
- `InvariantGlobalization` = `true` (định dạng số/ngày giống nhau trên mọi máy,
  nên output trong sách lặp lại được)

## 5. Gói NuGet (pin phiên bản chính xác)

| Gói | Phiên bản | Dùng ở |
|---|---|---|
| `xunit.v3` | 4.0.1 | Tập 2 ch.6, Tập 3, dự án cuối |
| `Microsoft.Extensions.DependencyInjection` | 10.0.12 | Tập 2 ch.7 |
| `Microsoft.Extensions.Hosting` | 10.0.12 | Tập 2 ch.7, Tập 3 |
| `Microsoft.EntityFrameworkCore.Sqlite` | 10.0.12 | Tập 3 ch.2, dự án cuối |
| `Microsoft.AspNetCore.Mvc.Testing` | 10.0.12 | Test tích hợp Web API |
| `Microsoft.AspNetCore.OpenApi` | 10.0.12 | Dự án cuối |
| `BenchmarkDotNet` | 0.15.8 | Tập 3 ch.3 |
| `OpenTelemetry.Extensions.Hosting` | 1.19.1 | Tập 3 ch.6 |
| `OpenTelemetry.Exporter.Console` | 1.19.1 | Tập 3 ch.6 |
| `OpenTelemetry.Instrumentation.AspNetCore` | 1.19.0 | Tập 3 ch.6 |

Phiên bản lấy từ NuGet API (`https://api.nuget.org/v3-flatcontainer/<id>/index.json`),
bản stable mới nhất ngày 2026-09-28. Các gói Microsoft.* chọn 10.0.12 để khớp runtime.

## 6. Công cụ khác

| Công cụ | Phiên bản | Dùng để |
|---|---|---|
| Ubuntu | 24.04 | Máy build |
| Docker Engine | 29.3.1 | Build image dự án cuối |
| Base images | `mcr.microsoft.com/dotnet/sdk:10.0.401`, `mcr.microsoft.com/dotnet/aspnet:10.0.12` (tag có trên mcr.microsoft.com, checked 2026-09-28) | Dockerfile dự án cuối |
| pandoc | 3.1.3 | Markdown → HTML |
| Node.js + Playwright (Chromium) | 22.22.2 / 1.56.1 | HTML → PDF |

## Nguồn tham khảo (Sources)

- .NET releases index: https://raw.githubusercontent.com/dotnet/core/main/release-notes/releases-index.json
- .NET 10 releases: https://raw.githubusercontent.com/dotnet/core/main/release-notes/10.0/releases.json
- .NET 11 releases: https://raw.githubusercontent.com/dotnet/core/main/release-notes/11.0/releases.json
- C# language version history: https://github.com/dotnet/csharplang/blob/main/Language-Version-History.md
- What's new in C# 14 (nguồn của Microsoft Learn): https://github.com/dotnet/docs/blob/main/docs/csharp/whats-new/csharp-14.md
- global.json overview (nguồn của Microsoft Learn): https://github.com/dotnet/docs/blob/main/docs/core/tools/global-json.md
- Testing with `dotnet test` (nguồn của Microsoft Learn): https://github.com/dotnet/docs/blob/main/docs/core/testing/unit-testing-with-dotnet-test.md
- xUnit.net repo: https://github.com/xunit/xunit
- NuGet API ví dụ: https://api.nuget.org/v3-flatcontainer/microsoft.entityframeworkcore.sqlite/index.json
