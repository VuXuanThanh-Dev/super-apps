// Bài 1: FizzBuzz 1..15 bằng switch expression với tuple
Console.Write("Bài 1: ");
for (int i = 1; i <= 15; i++)
{
    string s = (i % 3, i % 5) switch
    {
        (0, 0) => "FizzBuzz",
        (0, _) => "Fizz",
        (_, 0) => "Buzz",
        _ => i.ToString(),
    };
    Console.Write(s + (i < 15 ? " " : "\n"));
}

// Bài 2: kiểm tra số nguyên tố
Console.WriteLine($"Bài 2: số nguyên tố < 30: {string.Join(", ", Enumerable.Range(1, 29).Where(IsPrime))}");

// Bài 3: hàm trả về tuple (tổng, trung bình)
var (total, average) = Stats([4, 8, 15, 16, 23, 42]);
Console.WriteLine($"Bài 3: tổng={total}, trung bình={average:F2}");

// Bài 4: TryParse kiểu riêng với out
Console.WriteLine($"Bài 4: '12:30' hợp lệ? {TryParseTime("12:30", out var h, out var m)} -> {h}h{m}");
Console.WriteLine($"Bài 4: '25:99' hợp lệ? {TryParseTime("25:99", out _, out _)}");

static bool IsPrime(int n)
{
    if (n < 2) return false;
    for (int d = 2; d * d <= n; d++)
        if (n % d == 0) return false;
    return true;
}

static (int Total, double Average) Stats(int[] values)
{
    int total = 0;
    foreach (var v in values) total += v;
    return (total, (double)total / values.Length);
}

static bool TryParseTime(string text, out int hour, out int minute)
{
    hour = minute = 0;
    var parts = text.Split(':');
    return parts.Length == 2
        && int.TryParse(parts[0], out hour) && hour is >= 0 and < 24
        && int.TryParse(parts[1], out minute) && minute is >= 0 and < 60;
}
