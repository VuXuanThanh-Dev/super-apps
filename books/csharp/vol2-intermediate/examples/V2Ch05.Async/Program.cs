using System.Diagnostics;
using System.Runtime.CompilerServices;

var sw = Stopwatch.StartNew();

// 1. await tuần tự: tổng thời gian = cộng dồn
var user = await GetUserAsync(1);
var orders = await GetOrdersAsync(1);
Console.WriteLine($"Tuần tự: {user}, {orders} đơn — ~{Round(sw.ElapsedMilliseconds)} ms");

// 2. Chạy song song với Task.WhenAll: tổng thời gian = task lâu nhất
sw.Restart();
Task<string> userTask = GetUserAsync(2);
Task<int> ordersTask = GetOrdersAsync(2);
await Task.WhenAll(userTask, ordersTask);
Console.WriteLine($"WhenAll: {userTask.Result}, {ordersTask.Result} đơn — ~{Round(sw.ElapsedMilliseconds)} ms");

// 3. WhenAll trả về mảng kết quả
int[] ids = [1, 2, 3];
string[] names = await Task.WhenAll(ids.Select(GetUserAsync));
Console.WriteLine($"Nhiều user: {string.Join(", ", names)}");

// 4. Exception trong async
try
{
    await GetUserAsync(-1);
}
catch (ArgumentException ex)
{
    Console.WriteLine($"Bắt lỗi async: {ex.Message}");
}

// 5. Cancellation với timeout
using var cts = new CancellationTokenSource(TimeSpan.FromMilliseconds(150));
try
{
    await SlowReportAsync(cts.Token);
}
catch (OperationCanceledException)
{
    Console.WriteLine("Báo cáo bị hủy sau 150 ms (timeout)");
}

// 6. IAsyncEnumerable + await foreach: stream dữ liệu
await foreach (var price in StreamPricesAsync(3))
    Console.WriteLine($"  giá mới: {price}");

// 7. Task.WhenAny: lấy kết quả đầu tiên
var fast = Task.Delay(50).ContinueWith(_ => "server A");
var slow = Task.Delay(300).ContinueWith(_ => "server B");
var winner = await Task.WhenAny(fast, slow);
Console.WriteLine($"Nhanh nhất: {await winner}");

// 8. ValueTask cho đường đi nhanh có cache
var cache = new PriceCache();
Console.WriteLine($"Lần 1: {await cache.GetAsync("AAPL")} (từ nguồn), lần 2: {await cache.GetAsync("AAPL")} (cache), số lần gọi nguồn = {cache.SourceCalls}");

static long Round(long ms) => (ms + 50) / 100 * 100;   // làm tròn 100 ms để output ổn định

static async Task<string> GetUserAsync(int id)
{
    if (id < 0) throw new ArgumentException($"id không hợp lệ: {id}");
    await Task.Delay(200);           // giả lập gọi DB
    return $"User{id}";
}

static async Task<int> GetOrdersAsync(int userId)
{
    await Task.Delay(300);           // giả lập gọi API khác
    return userId * 2;
}

static async Task SlowReportAsync(CancellationToken ct)
{
    for (int i = 0; i < 10; i++)
    {
        await Task.Delay(100, ct);    // ném OperationCanceledException khi token bị hủy
    }
}

static async IAsyncEnumerable<decimal> StreamPricesAsync(int count, [EnumeratorCancellation] CancellationToken ct = default)
{
    decimal price = 100m;
    for (int i = 0; i < count; i++)
    {
        await Task.Delay(20, ct);
        price += 1.5m;
        yield return price;
    }
}

class PriceCache
{
    private readonly Dictionary<string, decimal> _cache = [];
    public int SourceCalls { get; private set; }

    public ValueTask<decimal> GetAsync(string symbol)
    {
        if (_cache.TryGetValue(symbol, out var cached))
            return ValueTask.FromResult(cached);     // không cấp phát Task
        return new ValueTask<decimal>(LoadAsync(symbol));
    }

    private async Task<decimal> LoadAsync(string symbol)
    {
        SourceCalls++;
        await Task.Delay(10);
        return _cache[symbol] = 123.45m;
    }
}
