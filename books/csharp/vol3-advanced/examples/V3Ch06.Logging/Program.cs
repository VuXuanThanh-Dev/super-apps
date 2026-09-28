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
