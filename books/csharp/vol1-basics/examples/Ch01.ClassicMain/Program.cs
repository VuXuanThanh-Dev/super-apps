namespace Ch01.ClassicMain;

// Cách viết "cổ điển" trước C# 9: class Program + hàm Main.
internal class Program
{
    private static void Main(string[] args)
    {
        Console.WriteLine("Xin chào, C#! (kiểu cổ điển với Main)");
        Console.WriteLine($"Số tham số dòng lệnh: {args.Length}");
    }
}
