using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

// 1. Container DI "trần": ServiceCollection
var services = new ServiceCollection();
services.AddSingleton<IClock, FixedClock>();          // 1 instance cho cả ứng dụng
services.AddScoped<RequestContext>();                  // 1 instance mỗi scope (mỗi HTTP request)
services.AddTransient<IGreeter, VietnameseGreeter>();  // instance mới mỗi lần xin

using (var provider = services.BuildServiceProvider(validateScopes: true))
{
    for (int request = 1; request <= 2; request++)
    {
        using var scope = provider.CreateScope();
        var sp = scope.ServiceProvider;
        var ctx1 = sp.GetRequiredService<RequestContext>();
        var ctx2 = sp.GetRequiredService<RequestContext>();
        var g1 = sp.GetRequiredService<IGreeter>();
        var g2 = sp.GetRequiredService<IGreeter>();
        bool sameClock = ReferenceEquals(sp.GetRequiredService<IClock>(), provider.GetRequiredService<IClock>());
        Console.WriteLine($"Request {request}: scoped cùng object? {ReferenceEquals(ctx1, ctx2)} (id={ctx1}), " +
                          $"transient cùng object? {ReferenceEquals(g1, g2)}, singleton cùng object? {sameClock}");
        Console.WriteLine("  " + g1.Greet("Nobin"));
    }
}

// 2. Generic Host: DI + configuration + logging + options (giống ASP.NET Core)
var builder = Host.CreateApplicationBuilder(args);
builder.Logging.ClearProviders();
builder.Logging.AddSimpleConsole(o => { o.SingleLine = true; o.IncludeScopes = false; });
builder.Configuration.AddInMemoryCollection(new Dictionary<string, string?>
{
    ["Email:Sender"] = "noreply@shop.vn",
    ["Email:MaxRetries"] = "3",
});
builder.Services.Configure<EmailOptions>(builder.Configuration.GetSection("Email"));
builder.Services.AddSingleton<IClock, FixedClock>();
builder.Services.AddTransient<IEmailSender, FakeEmailSender>();
builder.Services.AddTransient<OrderService>();

using var host = builder.Build();
var orderService = host.Services.GetRequiredService<OrderService>();
orderService.PlaceOrder("an@example.com", 250_000m);

// 3. Lỗi thường gặp: quên đăng ký service
try
{
    host.Services.GetRequiredService<IGreeter>();
}
catch (InvalidOperationException ex)
{
    Console.WriteLine($"Lỗi DI: {ex.Message}");
}

public interface IClock { DateTime Now { get; } }
public sealed class FixedClock : IClock { public DateTime Now => new(2026, 9, 28, 9, 0, 0); }

public sealed class RequestContext { public Guid Id { get; } = Guid.NewGuid(); public override string ToString() => Id.ToString()[..8]; }

public interface IGreeter { string Greet(string name); }
public sealed class VietnameseGreeter(IClock clock) : IGreeter
{
    public string Greet(string name) => $"Chào buổi {(clock.Now.Hour < 12 ? "sáng" : "chiều")}, {name}!";
}

public sealed class EmailOptions
{
    public string Sender { get; set; } = "";
    public int MaxRetries { get; set; }
}

public interface IEmailSender { void Send(string to, string subject); }

public sealed class FakeEmailSender(IOptions<EmailOptions> options, ILogger<FakeEmailSender> logger) : IEmailSender
{
    public void Send(string to, string subject) =>
        logger.LogInformation("Gửi email từ {Sender} tới {To}: {Subject} (retry tối đa {MaxRetries})",
            options.Value.Sender, to, subject, options.Value.MaxRetries);
}

// Constructor injection: OrderService không tự tạo dependency
public sealed class OrderService(IEmailSender email, IClock clock, ILogger<OrderService> logger)
{
    public void PlaceOrder(string customerEmail, decimal amount)
    {
        logger.LogInformation("Đặt hàng {Amount} lúc {Time:HH:mm}", amount, clock.Now);
        email.Send(customerEmail, $"Xác nhận đơn hàng {amount:N0} VND");
    }
}
