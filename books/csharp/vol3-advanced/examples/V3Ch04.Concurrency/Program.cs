using System.Collections.Concurrent;
using System.Diagnostics;
using System.Threading.Channels;

Console.WriteLine($"Số CPU logic: {Environment.ProcessorCount}");
const int N = 1_000_000;

// 1. Race condition: nhiều luồng cùng sửa một biến
int unsafeCounter = 0;
Parallel.For(0, N, _ => unsafeCounter++);            // ++ không phải thao tác nguyên tử
Console.WriteLine($"Không đồng bộ: {unsafeCounter:N0} (mong đợi {N:N0})");

// 2. lock với System.Threading.Lock (C# 13 / .NET 9)
var gate = new Lock();
int lockedCounter = 0;
Parallel.For(0, N, _ => { lock (gate) { lockedCounter++; } });
Console.WriteLine($"lock:          {lockedCounter:N0}");

// 3. Interlocked: nguyên tử, nhanh cho phép toán đơn giản
int atomicCounter = 0;
Parallel.For(0, N, _ => Interlocked.Increment(ref atomicCounter));
Console.WriteLine($"Interlocked:   {atomicCounter:N0}");

// 4. ConcurrentDictionary: collection an toàn đa luồng
var wordCounts = new ConcurrentDictionary<string, int>();
string[] words = ["c#", "java", "c#", "ts", "c#", "java"];
Parallel.ForEach(Enumerable.Range(0, 1000), i =>
    wordCounts.AddOrUpdate(words[i % words.Length], 1, (_, old) => old + 1));
Console.WriteLine("ConcurrentDictionary: " + string.Join(", ", wordCounts.OrderBy(kv => kv.Key).Select(kv => $"{kv.Key}={kv.Value}")));

// 5. Việc nặng CPU: tuần tự vs Task.Run vs PLINQ
static bool IsPrime(int n)
{
    if (n < 2) return false;
    for (int d = 2; d * d <= n; d++) if (n % d == 0) return false;
    return true;
}
const int Limit = 3_000_000;
var sw = Stopwatch.StartNew();
int seq = Enumerable.Range(0, Limit).Count(IsPrime);
var seqMs = sw.ElapsedMilliseconds;

sw.Restart();
// Chia đều theo kiểu "xen kẽ" (i, i+4, i+8...) để 4 task có lượng việc gần bằng nhau
var tasks = Enumerable.Range(0, 4).Select(offset => Task.Run(() =>
{
    int count = 0;
    for (int n = offset; n < Limit; n += 4) if (IsPrime(n)) count++;
    return count;
}));
int par = (await Task.WhenAll(tasks)).Sum();
var parMs = sw.ElapsedMilliseconds;

sw.Restart();
int plinq = Enumerable.Range(0, Limit).AsParallel().Count(IsPrime);
var plinqMs = sw.ElapsedMilliseconds;
Console.WriteLine($"Số nguyên tố < 3 triệu: tuần tự={seq:N0} ({seqMs} ms), 4 task={par:N0} ({parMs} ms), PLINQ={plinq:N0} ({plinqMs} ms)");

// 6. Parallel.ForEachAsync: giới hạn số việc I/O chạy cùng lúc
int inFlight = 0, maxInFlight = 0;
await Parallel.ForEachAsync(Enumerable.Range(1, 12), new ParallelOptions { MaxDegreeOfParallelism = 3 }, async (i, ct) =>
{
    int now = Interlocked.Increment(ref inFlight);
    int seen;
    while (now > (seen = Volatile.Read(ref maxInFlight)) && Interlocked.CompareExchange(ref maxInFlight, now, seen) != seen) { }
    await Task.Delay(30, ct);
    Interlocked.Decrement(ref inFlight);
});
Console.WriteLine($"ForEachAsync: tối đa {maxInFlight} việc cùng lúc (giới hạn 3)");

// 7. Channel<T>: producer / consumer có giới hạn (back-pressure)
var channel = Channel.CreateBounded<int>(new BoundedChannelOptions(capacity: 5)
{
    FullMode = BoundedChannelFullMode.Wait,
});
var producer = Task.Run(async () =>
{
    for (int i = 1; i <= 20; i++) await channel.Writer.WriteAsync(i);
    channel.Writer.Complete();
});
var consumers = Enumerable.Range(1, 2).Select(id => Task.Run(async () =>
{
    int handled = 0, total = 0;
    await foreach (var item in channel.Reader.ReadAllAsync())
    {
        handled++;
        total += item;
        await Task.Delay(5);
    }
    return (id, handled, total);
})).ToArray();
await producer;
var results = await Task.WhenAll(consumers);
Console.WriteLine($"Channel: tổng xử lý = {results.Sum(r => r.handled)} việc, tổng giá trị = {results.Sum(r => r.total)} " +
                  $"(consumer 1 làm {results[0].handled}, consumer 2 làm {results[1].handled})");

// Máy build dùng chung với tiến trình khác? Load average cao làm song song kém hiệu quả.
if (File.Exists("/proc/loadavg"))
    Console.WriteLine($"Load average (1/5/15 phút): {string.Join(" ", File.ReadAllText("/proc/loadavg").Split(' ')[..3])}");
