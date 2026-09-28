using System.Buffers;
using System.Runtime.InteropServices;

const string line = "SKU-001,Bàn phím cơ,1200000,15";

// 1. Span<T> là "cửa sổ" nhìn vào bộ nhớ có sẵn, không copy
int[] numbers = [10, 20, 30, 40, 50];
Span<int> middle = numbers.AsSpan(1, 3);   // 20, 30, 40
middle[0] = 99;                            // sửa luôn mảng gốc
Console.WriteLine($"numbers = [{string.Join(", ", numbers)}], middle.Length = {middle.Length}");

// 2. ReadOnlySpan<char>: cắt chuỗi không tạo chuỗi mới
ReadOnlySpan<char> span = line;
int firstComma = span.IndexOf(',');
ReadOnlySpan<char> sku = span[..firstComma];
Console.WriteLine($"SKU = {sku.ToString()} (chỉ ToString() khi cần mới cấp phát)");

// 3. So sánh cấp phát bộ nhớ: string.Split vs Span
const int N = 100_000;
long before = GC.GetAllocatedBytesForCurrentThread();
long sum1 = 0;
for (int i = 0; i < N; i++) sum1 += ParseWithSplit(line);
long splitBytes = GC.GetAllocatedBytesForCurrentThread() - before;

before = GC.GetAllocatedBytesForCurrentThread();
long sum2 = 0;
for (int i = 0; i < N; i++) sum2 += ParseWithSpan(line);
long spanBytes = GC.GetAllocatedBytesForCurrentThread() - before;

Console.WriteLine($"Split: tổng={sum1}, cấp phát ~{splitBytes / N} bytes/lần");
Console.WriteLine($"Span : tổng={sum2}, cấp phát ~{spanBytes / N} bytes/lần");

// 4. stackalloc: bộ nhớ tạm trên stack (nhỏ, ngắn hạn), không cần GC
Span<byte> buffer = stackalloc byte[16];
Random.Shared.NextBytes(buffer);
Console.WriteLine($"stackalloc 16 bytes, Length = {buffer.Length}");

// 5. ArrayPool: mượn mảng lớn rồi trả lại, tránh cấp phát lặp lại
byte[] rented = ArrayPool<byte>.Shared.Rent(4096);
try
{
    Console.WriteLine($"Rent(4096) -> mảng dài {rented.Length} (có thể lớn hơn yêu cầu)");
}
finally
{
    ArrayPool<byte>.Shared.Return(rented);
}

// 6. C# 14 first-class span: mảng tự chuyển sang ReadOnlySpan khi gọi hàm
Console.WriteLine($"Sum(array) = {Sum(numbers)}");

// 7. CollectionsMarshal.AsSpan: duyệt List<T> không kiểm tra version
List<int> list = [1, 2, 3, 4];
foreach (ref int x in CollectionsMarshal.AsSpan(list)) x *= 10;
Console.WriteLine($"list = [{string.Join(", ", list)}]");

// 8. Thông tin GC
Console.WriteLine($"GC: gen0={GC.CollectionCount(0)}, gen1={GC.CollectionCount(1)}, gen2={GC.CollectionCount(2)}, server GC={System.Runtime.GCSettings.IsServerGC}");

static int ParseWithSplit(string csv)
{
    string[] parts = csv.Split(',');            // cấp phát mảng + 4 chuỗi
    return int.Parse(parts[3]);
}

static int ParseWithSpan(ReadOnlySpan<char> csv)
{
    int last = csv.LastIndexOf(',');
    return int.Parse(csv[(last + 1)..]);         // không cấp phát
}

static int Sum(ReadOnlySpan<int> values)
{
    int total = 0;
    foreach (var v in values) total += v;
    return total;
}
