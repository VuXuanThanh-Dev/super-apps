using System.Text;
using Ch06.Files;

// ---------- Phần 1: Exceptions ----------
static int ParseQuantity(string input)
{
    try
    {
        return int.Parse(input);
    }
    catch (FormatException)
    {
        Console.WriteLine($"  '{input}' không phải số -> dùng 0");
        return 0;
    }
    finally
    {
        Console.WriteLine($"  finally luôn chạy (input='{input}')");
    }
}

Console.WriteLine($"ParseQuantity(\"12\") = {ParseQuantity("12")}");
Console.WriteLine($"ParseQuantity(\"x\") = {ParseQuantity("x")}");

static void Reserve(string sku, int requested, int available)
{
    if (requested > available)
        throw new InsufficientStockException(sku, requested, available);
    Console.WriteLine($"  Đã giữ {requested} {sku}");
}

try
{
    Reserve("SKU-1", 2, 5);
    Reserve("SKU-2", 9, 3);
}
catch (InsufficientStockException ex) when (ex.Available > 0)   // exception filter
{
    Console.WriteLine($"  Bắt được: {ex.Message} (thiếu {ex.Requested - ex.Available})");
}

// Bọc exception để thêm ngữ cảnh, giữ InnerException
try
{
    try { _ = int.Parse("abc"); }
    catch (FormatException inner) { throw new InvalidOperationException("Đọc cấu hình thất bại", inner); }
}
catch (InvalidOperationException ex)
{
    Console.WriteLine($"  {ex.Message} <- {ex.InnerException?.GetType().Name}");
}

// ---------- Phần 2: File và thư mục ----------
string dir = Path.Combine(Path.GetTempPath(), "csharp-book-ch06");
Directory.CreateDirectory(dir);
string csvPath = Path.Combine(dir, "products.csv");

// Ghi toàn bộ file một lần
string[] lines =
[
    "sku,name,price",
    "SKU-1,Bàn phím,750000",
    "SKU-2,Chuột,250000",
    "SKU-3,Màn hình,3200000",
];
File.WriteAllLines(csvPath, lines, Encoding.UTF8);
Console.WriteLine($"Đã ghi {lines.Length} dòng vào {Path.GetFileName(csvPath)}");

// Đọc từng dòng bằng StreamReader + using (tự Dispose khi ra khỏi scope)
decimal total = 0;
using (var reader = new StreamReader(csvPath, Encoding.UTF8))
{
    _ = reader.ReadLine(); // bỏ header
    string? line;
    while ((line = reader.ReadLine()) is not null)
    {
        var cols = line.Split(',');
        total += decimal.Parse(cols[2]);
        Console.WriteLine($"  {cols[0]} | {cols[1],-10} | {decimal.Parse(cols[2]),12:N0}");
    }
}
Console.WriteLine($"Tổng giá: {total:N0}");

// Ghi thêm (append) bằng using declaration (C# 8)
{
    using var writer = new StreamWriter(csvPath, append: true, Encoding.UTF8);
    writer.WriteLine("SKU-4,Tai nghe,990000");
}
Console.WriteLine($"Số dòng sau khi append: {File.ReadAllLines(csvPath).Length}");

// Thông tin file
var info = new FileInfo(csvPath);
Console.WriteLine($"Kích thước: {info.Length} bytes, đuôi: {info.Extension}");

// File không tồn tại
try
{
    File.ReadAllText(Path.Combine(dir, "missing.txt"));
}
catch (FileNotFoundException ex)
{
    Console.WriteLine($"FileNotFoundException: {Path.GetFileName(ex.FileName)}");
}

// Dọn dẹp
Directory.Delete(dir, recursive: true);
Console.WriteLine($"Đã xóa thư mục tạm? {!Directory.Exists(dir)}");
