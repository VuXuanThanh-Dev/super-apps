using System.Threading.Channels;

// Bài 1: chuyển tiền an toàn giữa 2 tài khoản, tránh deadlock bằng thứ tự lock theo Id
var a = new Account(1, 1_000);
var b = new Account(2, 1_000);
var transfers = Enumerable.Range(0, 10_000).Select(i => Task.Run(() =>
{
    if (i % 2 == 0) Account.Transfer(a, b, 1); else Account.Transfer(b, a, 1);
}));
await Task.WhenAll(transfers);
Console.WriteLine($"Bài 1: a={a.Balance}, b={b.Balance}, tổng={a.Balance + b.Balance} (luôn 2000)");

// Bài 2: pipeline 2 bước bằng Channel: đọc -> xử lý -> ghi
var raw = Channel.CreateUnbounded<string>();
var processed = Channel.CreateBounded<string>(10);
var stage1 = Task.Run(async () =>
{
    foreach (var line in new[] { "an", "bình", "chi", "dũng" }) await raw.Writer.WriteAsync(line);
    raw.Writer.Complete();
});
var stage2 = Task.Run(async () =>
{
    await foreach (var s in raw.Reader.ReadAllAsync()) await processed.Writer.WriteAsync(s.ToUpperInvariant());
    processed.Writer.Complete();
});
var output = new List<string>();
await foreach (var s in processed.Reader.ReadAllAsync()) output.Add(s);
await Task.WhenAll(stage1, stage2);
Console.WriteLine($"Bài 2: {string.Join(" -> ", output)}");

// Bài 3: bộ đếm request theo endpoint an toàn đa luồng
var counter = new RequestCounter();
Parallel.For(0, 3000, i => counter.Hit(i % 3 == 0 ? "/api/tasks" : "/health"));
Console.WriteLine($"Bài 3: {counter}");

public class Account(int id, decimal balance)
{
    private readonly Lock _gate = new();
    public int Id { get; } = id;
    public decimal Balance { get; private set; } = balance;

    public static void Transfer(Account from, Account to, decimal amount)
    {
        var (first, second) = from.Id < to.Id ? (from, to) : (to, from);   // luôn lock theo cùng thứ tự
        lock (first._gate)
        lock (second._gate)
        {
            if (from.Balance < amount) return;
            from.Balance -= amount;
            to.Balance += amount;
        }
    }
}

public class RequestCounter
{
    private readonly System.Collections.Concurrent.ConcurrentDictionary<string, long> _counts = new();
    public void Hit(string path) => _counts.AddOrUpdate(path, 1, (_, c) => c + 1);
    public override string ToString() => string.Join(", ", _counts.OrderBy(kv => kv.Key).Select(kv => $"{kv.Key}={kv.Value}"));
}
