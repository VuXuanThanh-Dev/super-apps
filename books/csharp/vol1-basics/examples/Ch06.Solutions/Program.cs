using System.Text;

string dir = Path.Combine(Path.GetTempPath(), "csharp-book-ch06-sol");
Directory.CreateDirectory(dir);
string log = Path.Combine(dir, "app.log");

// Bài 1: ghi log và đếm số dòng ERROR
File.WriteAllLines(log, ["INFO start", "ERROR db timeout", "INFO retry", "ERROR db timeout"], Encoding.UTF8);
int errors = File.ReadLines(log).Count(l => l.StartsWith("ERROR"));
Console.WriteLine($"Bài 1: số dòng ERROR = {errors}");

// Bài 2: hàm đọc file an toàn, trả về null nếu không có file
Console.WriteLine($"Bài 2: có file -> {ReadOrNull(log)?.Length} ký tự; không có file -> {ReadOrNull(Path.Combine(dir, "x.txt")) ?? "null"}");

// Bài 3: custom exception + finally
try
{
    Withdraw(balance: 100, amount: 150);
}
catch (InsufficientFundsException ex)
{
    Console.WriteLine($"Bài 3: {ex.Message}");
}
finally
{
    Directory.Delete(dir, recursive: true);
    Console.WriteLine("Bài 3: finally đã dọn thư mục tạm");
}

static string? ReadOrNull(string path)
{
    try { return File.ReadAllText(path); }
    catch (FileNotFoundException) { return null; }
}

static void Withdraw(decimal balance, decimal amount)
{
    if (amount > balance) throw new InsufficientFundsException(amount - balance);
}

public class InsufficientFundsException(decimal missing)
    : Exception($"Thiếu {missing} để rút tiền")
{
    public decimal Missing { get; } = missing;
}
