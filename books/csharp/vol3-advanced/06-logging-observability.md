# Chương 6 — Logging và observability

## Mục tiêu

- Dùng `ILogger<T>` với log level, filter, *structured logging* (log có cấu trúc) và scope.
- Viết log hiệu năng cao bằng `[LoggerMessage]` (source generator).
- Hiểu 3 trụ cột *observability* (khả năng quan sát): logs, traces, metrics.
- Thêm traces/metrics bằng `ActivitySource`, `Meter` và OpenTelemetry.
- Dùng health check cho `live` / `ready`.

## Giải thích đơn giản

Khi API chạy trên server, bạn không thể đặt breakpoint. Bạn cần **dấu vết**:

| Trụ cột | Trả lời câu hỏi | .NET API |
|---|---|---|
| **Logs** | Chuyện gì đã xảy ra? | `ILogger` |
| **Traces** | Một request đi qua những bước nào, mỗi bước bao lâu? | `System.Diagnostics.Activity` / `ActivitySource` |
| **Metrics** | Bao nhiêu? Nhanh hay chậm? (đếm, đo theo thời gian) | `System.Diagnostics.Metrics.Meter` |

**OpenTelemetry** (OTel) là chuẩn mở để thu thập và gửi 3 loại dữ liệu trên tới công cụ như
Jaeger, Prometheus, Grafana, Azure Monitor... .NET có sẵn API; OTel SDK chỉ việc "xuất" dữ liệu đi.

So với frontend: giống `console.log` + Sentry + Google Analytics, nhưng cho backend và theo chuẩn chung.

## Ví dụ

<!-- include: examples/V3Ch06.Logging/V3Ch06.Logging.csproj -->
```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.Extensions.Hosting" Version="10.0.12" />
    <PackageReference Include="OpenTelemetry.Extensions.Hosting" Version="1.19.1" />
    <PackageReference Include="OpenTelemetry.Exporter.Console" Version="1.19.1" />
  </ItemGroup>

</Project>
```

<!-- include: examples/V3Ch06.Logging/Program.cs -->
```csharp
using System.Diagnostics;
using System.Diagnostics.Metrics;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

var builder = Host.CreateApplicationBuilder(args);

// 1. Logging: JSON console formatter -> mỗi dòng log là một JSON có các trường riêng
builder.Logging.ClearProviders();
builder.Logging.AddJsonConsole(o =>
{
    o.IncludeScopes = true;
    o.JsonWriterOptions = new System.Text.Json.JsonWriterOptions
    {
        Indented = false,
        Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping, // giữ nguyên tiếng Việt
    };
});
builder.Logging.SetMinimumLevel(LogLevel.Information);
builder.Logging.AddFilter("Microsoft", LogLevel.Warning);   // bớt log của framework

// 2. Traces + metrics với OpenTelemetry, xuất ra console (thực tế: OTLP -> Jaeger/Grafana/...)
builder.Services.AddOpenTelemetry()
    .ConfigureResource(r => r.AddService("checkout-demo"))
    .WithTracing(t => t.AddSource(Checkout.ActivitySourceName).AddConsoleExporter())
    .WithMetrics(m => m.AddMeter(Checkout.MeterName).AddConsoleExporter((_, reader) =>
        reader.PeriodicExportingMetricReaderOptions.ExportIntervalMilliseconds = 60_000));

builder.Services.AddSingleton<Checkout>();
using var host = builder.Build();
await host.StartAsync();

var checkout = host.Services.GetRequiredService<Checkout>();
checkout.PlaceOrder("ORD-1001", 3, 450_000m);
checkout.PlaceOrder("ORD-1002", 0, 0m);

await host.StopAsync();   // flush traces và metrics ra console

public partial class Checkout(ILogger<Checkout> logger)
{
    public const string ActivitySourceName = "Demo.Checkout";
    public const string MeterName = "Demo.Checkout";
    private static readonly ActivitySource Source = new(ActivitySourceName);
    private static readonly Meter Meter = new(MeterName);
    private static readonly Counter<long> OrdersPlaced = Meter.CreateCounter<long>("orders.placed");

    public void PlaceOrder(string orderId, int quantity, decimal total)
    {
        using var activity = Source.StartActivity("PlaceOrder");   // một "span" trong trace
        activity?.SetTag("order.id", orderId);

        // Scope: mọi log bên trong đều mang OrderId
        using var scope = logger.BeginScope("Order {OrderId}", orderId);

        if (quantity <= 0)
        {
            LogInvalidQuantity(quantity);
            activity?.SetStatus(ActivityStatusCode.Error, "invalid quantity");
            return;
        }

        // Structured logging: {Quantity}, {Total} là tên trường, KHÔNG dùng $"..."
        logger.LogInformation("Đặt hàng thành công: {Quantity} sản phẩm, tổng {Total}", quantity, total);
        OrdersPlaced.Add(1, new KeyValuePair<string, object?>("status", "ok"));
    }

    // Source-generated logging: nhanh hơn, không cấp phát khi level bị tắt
    [LoggerMessage(EventId = 4001, Level = LogLevel.Warning, Message = "Số lượng không hợp lệ: {Quantity}")]
    private partial void LogInvalidQuantity(int quantity);
}
```

Output thật (log JSON, trace và metric xuất ra console; `TraceId`/`SpanId` ngẫu nhiên mỗi lần chạy.
Logger console và exporter OTel ghi từ hai luồng khác nhau nên thứ tự các dòng có thể xen nhau):

<!-- output: examples/V3Ch06.Logging -->
```text
{"EventId":0,"LogLevel":"Information","Category":"Checkout","Message":"Đặt hàng thành công: 3 sản phẩm, tổng 450000","State":{"Quantity":3,"Total":450000,"{OriginalFormat}":"Đặt hàng thành công: {Quantity} sản phẩm, tổng {Total}"},"Scopes":[{"Message":"SpanId:96249d65b4c5beb7, TraceId:095bb3e37e547e91d8e0e66625e54cad, ParentId:0000000000000000","SpanId":"96249d65b4c5beb7","TraceId":"095bb3e37e547e91d8e0e66625e54cad","ParentId":"0000000000000000"},{"Message":"Order ORD-1001","OrderId":"ORD-1001","{OriginalFormat}":"Order {OrderId}"}]}
Activity.TraceId:            095bb3e37e547e91d8e0e66625e54cad
Activity.SpanId:             96249d65b4c5beb7
Activity.TraceFlags:         Recorded
Activity.DisplayName:        PlaceOrder
Activity.Kind:               Internal
Activity.StartTime:          2026-09-28T15:19:16.1298429Z
Activity.Duration:           00:00:00.0184610
Activity.Tags:
    order.id: ORD-1001
Instrumentation scope (ActivitySource):
    Name: Demo.Checkout
Resource associated with Activity:
    service.name: checkout-demo
    service.instance.id: 92f0996e-0b17-45ab-bc00-7aa750916707
    telemetry.sdk.name: opentelemetry
    telemetry.sdk.language: dotnet
    telemetry.sdk.version: 1.19.1
    Schema URL: https://opentelemetry.io/schemas/1.44.0

Activity.TraceId:            f71f5a88f69aff85fa99d64785ba879c
{"EventId":4001,"LogLevel":"Warning","Category":"Checkout","Message":"Số lượng không hợp lệ: 0","State":{"Quantity":0,"{OriginalFormat}":"Số lượng không hợp lệ: {Quantity}"},"Scopes":[{"Message":"SpanId:d0d34733a6d5408b, TraceId:f71f5a88f69aff85fa99d64785ba879c, ParentId:0000000000000000","SpanId":"d0d34733a6d5408b","TraceId":"f71f5a88f69aff85fa99d64785ba879c","ParentId":"0000000000000000"},{"Message":"Order ORD-1002","OrderId":"ORD-1002","{OriginalFormat}":"Order {OrderId}"}]}
Activity.SpanId:             d0d34733a6d5408b
Activity.TraceFlags:         Recorded
Activity.DisplayName:        PlaceOrder
Activity.Kind:               Internal
Activity.StartTime:          2026-09-28T15:19:16.1592427Z
Activity.Duration:           00:00:00.0049518
Activity.Tags:
    order.id: ORD-1002
StatusCode: Error
Activity.StatusDescription:  invalid quantity
Instrumentation scope (ActivitySource):
    Name: Demo.Checkout
Resource associated with Activity:
    service.name: checkout-demo
    service.instance.id: 92f0996e-0b17-45ab-bc00-7aa750916707
    telemetry.sdk.name: opentelemetry
    telemetry.sdk.language: dotnet
    telemetry.sdk.version: 1.19.1
    Schema URL: https://opentelemetry.io/schemas/1.44.0

Resource associated with Metrics:
	service.name: checkout-demo
	service.instance.id: 92f0996e-0b17-45ab-bc00-7aa750916707
	telemetry.sdk.name: opentelemetry
	telemetry.sdk.language: dotnet
	telemetry.sdk.version: 1.19.1
	Schema URL: https://opentelemetry.io/schemas/1.44.0

Metric Name: orders.placed, Metric Type: LongSum
Instrumentation scope (Meter):
	Name: Demo.Checkout
(2026-09-28T15:19:16.1218484Z, 2026-09-28T15:19:16.1782077Z] status: ok 
Value: 1
```

Để ý trong log JSON:

- `State` có trường riêng `Quantity: 3`, `Total: 450000` → công cụ log lọc được
  "mọi đơn có Total > 1 triệu" mà không phải phân tích chuỗi.
- `Scopes` chứa `OrderId` **và** `TraceId`/`SpanId` → nối log với trace tương ứng.
- Log cảnh báo có `EventId: 4001` từ `[LoggerMessage]`.

## Đi sâu

### Log level

| Level | Dùng cho |
|---|---|
| `Trace`, `Debug` | chi tiết khi phát triển; tắt ở production |
| `Information` | sự kiện nghiệp vụ bình thường (đặt hàng, đăng nhập) |
| `Warning` | bất thường nhưng vẫn chạy (dữ liệu sai, retry) |
| `Error` | thao tác thất bại (exception) |
| `Critical` | hệ thống sắp/đã ngừng |

Cấu hình trong `appsettings.json` (dự án cuối):

```json
"Logging": { "LogLevel": { "Default": "Information", "Microsoft.AspNetCore": "Warning" } }
```

### Structured logging: đúng và sai

```csharp
logger.LogInformation("Đặt hàng {OrderId} tổng {Total}", id, total);   // ĐÚNG: có trường OrderId, Total
logger.LogInformation($"Đặt hàng {id} tổng {total}");                   // SAI: chỉ là một chuỗi
```

Cách sai mất cấu trúc, và luôn tạo chuỗi kể cả khi level bị tắt.

### `[LoggerMessage]`

Source generator sinh code log tối ưu: kiểm tra level trước, không boxing tham số, có `EventId`
cố định. Dùng cho log được gọi nhiều (mỗi request).

### Traces và correlation

ASP.NET Core tự tạo một `Activity` cho mỗi request HTTP. `TraceId` được truyền qua header
`traceparent` (chuẩn W3C) sang dịch vụ khác → xem được toàn bộ hành trình của một request qua
nhiều service. Problem Details của dự án cuối trả về `traceId` để người dùng báo lỗi kèm mã này.

### Health checks

- **Liveness** (`/health/live`): process còn sống? Nếu fail → orchestrator (Kubernetes) khởi động lại.
- **Readiness** (`/health/ready`): sẵn sàng nhận traffic chưa (DB, dịch vụ ngoài)? Nếu fail → tạm
  ngưng gửi request tới.
- Dự án cuối có `/health` kiểm tra kết nối SQLite (`DatabaseHealthCheck`).

### Đưa lên production

Thay `AddConsoleExporter()` bằng `AddOtlpExporter()` (gói `OpenTelemetry.Exporter.OpenTelemetryProtocol`)
để gửi tới collector. Thêm `AddAspNetCoreInstrumentation()` (gói `OpenTelemetry.Instrumentation.AspNetCore`)
để có trace/metric HTTP tự động. **UNVERIFIED** trong bộ sách: phần xuất OTLP tới collector thật
không chạy ở đây vì không có collector.

## Lỗi và bẫy thường gặp

- **Log dữ liệu nhạy cảm** (mật khẩu, token, số thẻ, thông tin cá nhân) → vi phạm bảo mật/pháp lý.
- **Dùng `$"..."` trong log** → mất cấu trúc, tốn CPU.
- **Log quá nhiều ở `Information`** trong vòng lặp nóng → tốn chi phí lưu trữ, khó tìm.
- **Nuốt exception mà không log** hoặc log mà không kèm object exception (`LogError(ex, ...)`).
- **Health check "ready" gọi dịch vụ ngoài cho cả liveness** → dịch vụ ngoài chậm làm container bị
  khởi động lại liên tục. Tách live/ready như Bài tập 3.
- **Tên metric/tag có giá trị không giới hạn** (user id, URL đầy đủ) → bùng nổ số chuỗi thời gian.

## Tóm tắt

- `ILogger` + structured logging + scope; `[LoggerMessage]` cho đường nóng.
- Observability = logs + traces + metrics; OpenTelemetry là chuẩn xuất dữ liệu.
- Health check tách `live` và `ready`.

## Bài tập (có lời giải)

1. Thêm health check tùy chỉnh kiểm tra dung lượng đĩa trống, và một check "payment-api" giả lập lỗi.
2. Viết middleware log mỗi request (method, path, status) bằng `[LoggerMessage]`, trong scope
   `CorrelationId` lấy từ header `X-Correlation-Id`.
3. Tách `/health/live` (bỏ qua check có tag `external`) và `/health/ready` (tất cả check).

<details>
<summary>Lời giải</summary>

<!-- include: examples/V3Ch06.Solutions/Program.cs -->
```csharp
using Microsoft.Extensions.Diagnostics.HealthChecks;

var builder = WebApplication.CreateBuilder(args);
builder.WebHost.UseUrls("http://127.0.0.1:5197");
builder.Logging.ClearProviders();
builder.Logging.AddSimpleConsole(o => { o.SingleLine = true; o.IncludeScopes = true; });
builder.Logging.AddFilter("Microsoft", LogLevel.Warning);

// Bài 1: health check tùy chỉnh kiểm tra dung lượng đĩa trống (ngưỡng giả lập)
builder.Services.AddHealthChecks()
    .AddCheck("disk", () =>
    {
        long freeMb = new DriveInfo("/").AvailableFreeSpace / 1024 / 1024;
        return freeMb > 100
            ? HealthCheckResult.Healthy("đủ dung lượng")
            : HealthCheckResult.Degraded($"chỉ còn {freeMb} MB");
    })
    .AddCheck("payment-api", () => HealthCheckResult.Unhealthy("không kết nối được (giả lập)"), tags: ["external"]);

var app = builder.Build();

// Bài 2: middleware ghi log mỗi request với scope CorrelationId
app.Use(async (ctx, next) =>
{
    var logger = ctx.RequestServices.GetRequiredService<ILogger<Program>>();
    var correlationId = ctx.Request.Headers["X-Correlation-Id"].FirstOrDefault() ?? "none";
    using (logger.BeginScope("CorrelationId:{CorrelationId}", correlationId))
    {
        await next(ctx);
        Log.RequestFinished(logger, ctx.Request.Method, ctx.Request.Path, ctx.Response.StatusCode);
    }
});

// Bài 3: tách health check "live" (không kiểm tra phụ thuộc ngoài) và "ready"
app.MapHealthChecks("/health/live", new() { Predicate = c => !c.Tags.Contains("external") });
app.MapHealthChecks("/health/ready");

await app.StartAsync();
using var http = new HttpClient { BaseAddress = new Uri("http://127.0.0.1:5197") };
http.DefaultRequestHeaders.Add("X-Correlation-Id", "abc-123");
foreach (var path in new[] { "/health/live", "/health/ready" })
{
    var res = await http.GetAsync(path);
    Console.WriteLine($"{path} -> {(int)res.StatusCode} {await res.Content.ReadAsStringAsync()}");
}
await Task.Delay(200);   // cho console logger kịp ghi
await app.StopAsync();

static partial class Log
{
    [LoggerMessage(Level = LogLevel.Information, Message = "{Method} {Path} -> {StatusCode}")]
    public static partial void RequestFinished(ILogger logger, string method, string path, int statusCode);
}
```

<!-- output: examples/V3Ch06.Solutions -->
```text
info: Program[856139748] => SpanId:636c75dded2188c9, TraceId:c2edf7e602e1ae0b0bb895b9a325b0bd, ParentId:0000000000000000 => ConnectionId:0HNOTEFEDBD2V => RequestPath:/health/live RequestId:0HNOTEFEDBD2V:00000001 => CorrelationId:abc-123 GET /health/live -> 200
/health/live -> 200 Healthy
fail: Microsoft.Extensions.Diagnostics.HealthChecks.DefaultHealthCheckService[103] => SpanId:e508341a5dd8dfa3, TraceId:4d83381fbb064ff46b9ac611aea69469, ParentId:0000000000000000 => ConnectionId:0HNOTEFEDBD2V => RequestPath:/health/ready RequestId:0HNOTEFEDBD2V:00000002 => CorrelationId:abc-123 => Microsoft.Extensions.Diagnostics.HealthChecks.HealthCheckLogScope Health check payment-api with status Unhealthy completed after 0.3381ms with message 'không kết nối được (giả lập)'
info: Program[856139748] => SpanId:e508341a5dd8dfa3, TraceId:4d83381fbb064ff46b9ac611aea69469, ParentId:0000000000000000 => ConnectionId:0HNOTEFEDBD2V => RequestPath:/health/ready RequestId:0HNOTEFEDBD2V:00000002 => CorrelationId:abc-123 GET /health/ready -> 503
/health/ready -> 503 Unhealthy
```

`/health/live` trả 200 vì bỏ qua check `external`; `/health/ready` trả 503 vì "payment-api" Unhealthy.
Mỗi dòng log đều mang `CorrelationId:abc-123` từ scope.
</details>

## Nguồn tham khảo (Sources)

- Logging in .NET: https://github.com/dotnet/docs/blob/main/docs/core/extensions/logging/overview.md
- Compile-time logging source generation: https://github.com/dotnet/docs/blob/main/docs/core/extensions/logging/source-generation.md
- Console log formatting (JSON): https://github.com/dotnet/docs/blob/main/docs/core/extensions/logging/console-log-formatter.md
- Logging in ASP.NET Core: https://github.com/dotnet/AspNetCore.Docs/blob/main/aspnetcore/fundamentals/logging/index.md
- Health checks in ASP.NET Core: https://github.com/dotnet/AspNetCore.Docs/blob/main/aspnetcore/host-and-deploy/health-checks.md
- .NET observability with OpenTelemetry: https://github.com/dotnet/docs/blob/main/docs/core/diagnostics/observability-with-otel.md
- OpenTelemetry .NET: https://github.com/open-telemetry/opentelemetry-dotnet
- OpenTelemetry.Exporter.Console on NuGet: https://www.nuget.org/packages/OpenTelemetry.Exporter.Console/1.19.1
