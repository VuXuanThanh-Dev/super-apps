using System.Diagnostics;

// Bài 1: tải 6 "trang" nhưng tối đa 2 cùng lúc (SemaphoreSlim)
var gate = new SemaphoreSlim(2);
int running = 0, maxRunning = 0;
var sw = Stopwatch.StartNew();
var pages = await Task.WhenAll(Enumerable.Range(1, 6).Select(async i =>
{
    await gate.WaitAsync();
    try
    {
        int now = Interlocked.Increment(ref running);
        InterlockedMax(ref maxRunning, now);
        await Task.Delay(100);
        return $"page{i}";
    }
    finally
    {
        Interlocked.Decrement(ref running);
        gate.Release();
    }
}));
Console.WriteLine($"Bài 1: {pages.Length} trang, tối đa đồng thời = {maxRunning}, ~{(sw.ElapsedMilliseconds + 50) / 100 * 100} ms");

// Bài 2: WithTimeout — hủy nếu quá thời gian
Console.WriteLine($"Bài 2: nhanh -> {await WithTimeout(ct => WorkAsync(50, ct), 200)}");
Console.WriteLine($"Bài 2: chậm  -> {await WithTimeout(ct => WorkAsync(500, ct), 200)}");

// Bài 3: RetryAsync với backoff
int calls = 0;
var value = await RetryAsync(async () =>
{
    calls++;
    await Task.Delay(10);
    if (calls < 3) throw new HttpRequestException($"503 lần {calls}");
    return "OK";
}, maxAttempts: 4);
Console.WriteLine($"Bài 3: {value} sau {calls} lần gọi");

static async Task<string> WorkAsync(int ms, CancellationToken ct)
{
    await Task.Delay(ms, ct);
    return $"xong sau {ms} ms";
}

static async Task<string> WithTimeout(Func<CancellationToken, Task<string>> work, int timeoutMs)
{
    using var cts = new CancellationTokenSource(timeoutMs);
    try { return await work(cts.Token); }
    catch (OperationCanceledException) { return $"timeout ({timeoutMs} ms)"; }
}

static async Task<T> RetryAsync<T>(Func<Task<T>> action, int maxAttempts)
{
    for (int attempt = 1; ; attempt++)
    {
        try { return await action(); }
        catch (HttpRequestException ex) when (attempt < maxAttempts)
        {
            var delay = TimeSpan.FromMilliseconds(20 * Math.Pow(2, attempt - 1));
            Console.WriteLine($"Bài 3: lỗi '{ex.Message}', chờ {delay.TotalMilliseconds} ms");
            await Task.Delay(delay);
        }
    }
}

static void InterlockedMax(ref int target, int value)
{
    int current;
    while (value > (current = Volatile.Read(ref target)))
        Interlocked.CompareExchange(ref target, value, current);
}
