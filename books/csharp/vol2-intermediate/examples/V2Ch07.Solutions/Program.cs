using Microsoft.Extensions.DependencyInjection;

var services = new ServiceCollection();

// Bài 1: nhiều implementation cho cùng interface -> inject IEnumerable<T>
services.AddSingleton<INotifier, EmailNotifier>();
services.AddSingleton<INotifier, SmsNotifier>();
services.AddSingleton<AlertService>();

// Bài 2: keyed services (.NET 8+): chọn implementation theo khóa
services.AddKeyedSingleton<IPaymentGateway, MomoGateway>("momo");
services.AddKeyedSingleton<IPaymentGateway, VnPayGateway>("vnpay");

// Bài 3: decorator thủ công: thêm log quanh repository thật
services.AddSingleton<SqlProductRepository>();
services.AddSingleton<IProductRepository>(sp => new LoggingProductRepository(sp.GetRequiredService<SqlProductRepository>()));

using var provider = services.BuildServiceProvider();

provider.GetRequiredService<AlertService>().Alert("Server CPU 95%");

foreach (var key in new[] { "momo", "vnpay" })
    Console.WriteLine($"Bài 2: {provider.GetRequiredKeyedService<IPaymentGateway>(key).Pay(150_000m)}");

var repo = provider.GetRequiredService<IProductRepository>();
Console.WriteLine($"Bài 3: kết quả = {repo.GetName(7)}");

public interface INotifier { string Channel { get; } void Send(string message); }
public sealed class EmailNotifier : INotifier { public string Channel => "email"; public void Send(string m) => Console.WriteLine($"Bài 1: [email] {m}"); }
public sealed class SmsNotifier : INotifier { public string Channel => "sms"; public void Send(string m) => Console.WriteLine($"Bài 1: [sms] {m}"); }

public sealed class AlertService(IEnumerable<INotifier> notifiers)
{
    public void Alert(string message)
    {
        foreach (var n in notifiers) n.Send(message);
    }
}

public interface IPaymentGateway { string Pay(decimal amount); }
public sealed class MomoGateway : IPaymentGateway { public string Pay(decimal a) => $"MoMo thanh toán {a:N0}"; }
public sealed class VnPayGateway : IPaymentGateway { public string Pay(decimal a) => $"VNPay thanh toán {a:N0}"; }

public interface IProductRepository { string GetName(int id); }
public sealed class SqlProductRepository : IProductRepository { public string GetName(int id) => $"Sản phẩm #{id}"; }
public sealed class LoggingProductRepository(IProductRepository inner) : IProductRepository
{
    public string GetName(int id)
    {
        Console.WriteLine($"Bài 3: [log] GetName({id}) bắt đầu");
        var result = inner.GetName(id);
        Console.WriteLine("Bài 3: [log] GetName xong");
        return result;
    }
}
