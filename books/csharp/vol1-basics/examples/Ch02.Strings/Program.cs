using System.Text;

string first = "Nguyễn";
string last = "Văn A";

// Nối chuỗi và nội suy chuỗi (string interpolation)
string full1 = first + " " + last;
string full2 = $"{first} {last}";
Console.WriteLine(full1 == full2);  // so sánh nội dung, không phải tham chiếu

// Định dạng số trong interpolation
decimal total = 1234567.891m;
Console.WriteLine($"Tổng: {total:N2} | {total,15:F1} | {0.256:P1}");

// Các phương thức hay dùng
string s = "  Hello, C# World  ";
Console.WriteLine($"[{s.Trim()}] upper={s.Trim().ToUpper()} len={s.Length}");
Console.WriteLine($"Contains C#: {s.Contains("C#")}, IndexOf World: {s.IndexOf("World")}");
Console.WriteLine($"Replace: {s.Trim().Replace("World", "Việt Nam")}");
string[] parts = "a,b,,c".Split(',', StringSplitOptions.RemoveEmptyEntries);
Console.WriteLine($"Split: {parts.Length} phần -> {string.Join(" | ", parts)}");

// So sánh không phân biệt hoa thường
Console.WriteLine(string.Equals("abc", "ABC", StringComparison.OrdinalIgnoreCase));

// Chuỗi là bất biến (immutable): mỗi lần "sửa" tạo chuỗi mới
string original = "abc";
string upper = original.ToUpper();
Console.WriteLine($"original={original}, upper={upper}");

// StringBuilder khi nối nhiều lần
var sb = new StringBuilder();
for (int i = 1; i <= 5; i++)
{
    sb.Append(i).Append(i < 5 ? "-" : "");
}
Console.WriteLine($"StringBuilder: {sb}");

// Verbatim và raw string literal
string path = @"C:\temp\file.txt";
string json = """
    { "name": "Nobin", "lang": "C#" }
    """;
Console.WriteLine(path);
Console.WriteLine(json);

// Truy cập ký tự, index từ cuối (^1) và range (..)
string word = "TypeScript";
Console.WriteLine($"{word[0]} {word[^1]} {word[..4]} {word[4..]}");
