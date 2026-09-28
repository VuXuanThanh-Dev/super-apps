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
