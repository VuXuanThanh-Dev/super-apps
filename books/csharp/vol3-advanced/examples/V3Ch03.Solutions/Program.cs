using System.Buffers;

// Bài 1: đếm số từ trong câu mà không cấp phát (không Split)
const string text = "  Span giúp   xử lý chuỗi  nhanh và ít rác ";
long before = GC.GetAllocatedBytesForCurrentThread();
int words = CountWords(text);
long allocated = GC.GetAllocatedBytesForCurrentThread() - before;
Console.WriteLine($"Bài 1: {words} từ, cấp phát {allocated} bytes");

// Bài 2: định dạng mã đơn hàng vào buffer stackalloc bằng TryFormat
Span<char> buffer = stackalloc char[32];
int written = FormatOrderCode(buffer, 2026, 42);
Console.WriteLine($"Bài 2: {buffer[..written].ToString()}");

// Bài 3: tổng các số trong một chuỗi CSV dài dùng buffer mượn từ ArrayPool
string csv = string.Join(",", Enumerable.Range(1, 1000));
Console.WriteLine($"Bài 3: tổng = {SumCsv(csv)}");

static int CountWords(ReadOnlySpan<char> s)
{
    int count = 0;
    bool inWord = false;
    foreach (char c in s)
    {
        if (char.IsWhiteSpace(c)) inWord = false;
        else if (!inWord) { inWord = true; count++; }
    }
    return count;
}

static int FormatOrderCode(Span<char> destination, int year, int number)
{
    "ORD-".CopyTo(destination);
    int pos = 4;
    year.TryFormat(destination[pos..], out int w1); pos += w1;
    destination[pos++] = '-';
    number.TryFormat(destination[pos..], out int w2, "D6"); pos += w2;
    return pos;
}

static long SumCsv(string csv)
{
    int[] values = ArrayPool<int>.Shared.Rent(csv.Length / 2 + 1);
    try
    {
        int n = 0;
        foreach (var range in csv.AsSpan().Split(','))       // MemoryExtensions.Split (.NET 9): không cấp phát
            values[n++] = int.Parse(csv.AsSpan()[range]);
        long sum = 0;
        foreach (var v in values.AsSpan(0, n)) sum += v;
        return sum;
    }
    finally
    {
        ArrayPool<int>.Shared.Return(values);
    }
}
