// Top-level statements: không cần class Program hay hàm Main.
Console.WriteLine("Xin chào, C#!");

string name = args.Length > 0 ? args[0] : "Nobin";
int year = DateTime.Now.Year;
Console.WriteLine($"Chào {name}. Năm nay là {year}.");

// Thông tin môi trường chạy
Console.WriteLine($".NET runtime: {Environment.Version}");
Console.WriteLine($"OS: {Environment.OSVersion.Platform}");
Console.WriteLine($"C# ví dụ tính toán: 7 / 2 = {7 / 2}, 7 / 2.0 = {7 / 2.0}");
