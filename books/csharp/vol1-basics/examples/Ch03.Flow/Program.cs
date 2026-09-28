// if / else
int score = 82;
if (score >= 90) Console.WriteLine("Xuất sắc");
else if (score >= 80) Console.WriteLine("Giỏi");
else Console.WriteLine("Cố gắng thêm");

// switch statement
string day = "Sat";
switch (day)
{
    case "Sat":
    case "Sun":
        Console.WriteLine("Cuối tuần");
        break;
    default:
        Console.WriteLine("Ngày làm việc");
        break;
}

// switch expression (ngắn gọn hơn)
string Rank(int s) => s switch
{
    >= 90 => "A",
    >= 80 => "B",
    >= 65 => "C",
    _ => "D",
};
Console.WriteLine($"Rank(82)={Rank(82)}, Rank(50)={Rank(50)}");

// Vòng lặp
for (int i = 0; i < 3; i++) Console.Write($"for{i} ");
Console.WriteLine();

int n = 0;
while (n < 3) { Console.Write($"while{n} "); n++; }
Console.WriteLine();

do { Console.Write("do-chạy-ít-nhất-1-lần "); } while (false);
Console.WriteLine();

foreach (var fruit in new[] { "táo", "cam", "xoài" })
{
    if (fruit == "cam") continue;   // bỏ qua phần tử này
    Console.Write($"{fruit} ");
}
Console.WriteLine();

// Gọi phương thức (local functions ở dưới cùng file)
Console.WriteLine($"Add(2, 3) = {Add(2, 3)}");
Console.WriteLine($"Greet() = {Greet()}, Greet(\"An\", \"Hi\") = {Greet("An", "Hi")}");
Console.WriteLine($"Named args: {Greet(greeting: "Chào", name: "Bình")}");
Console.WriteLine($"params: Sum(1,2,3,4) = {Sum(1, 2, 3, 4)}");

// ref và out
int counter = 10;
Increase(ref counter);
Console.WriteLine($"Sau Increase(ref): {counter}");

if (TryDivide(10, 3, out int q, out int r))
    Console.WriteLine($"10 / 3 = {q} dư {r}");
if (!TryDivide(1, 0, out _, out _))
    Console.WriteLine("Không chia được cho 0");

// Tuple: trả về nhiều giá trị
var (min, max) = MinMax([4, 8, 1, 9]);
Console.WriteLine($"min={min}, max={max}");

// Đệ quy
Console.WriteLine($"Factorial(10) = {Factorial(10)}");

static int Add(int a, int b) => a + b;

static string Greet(string name = "bạn", string greeting = "Xin chào") => $"{greeting}, {name}!";

static int Sum(params int[] values)
{
    int total = 0;
    foreach (var v in values) total += v;
    return total;
}

static void Increase(ref int value) => value += 5;

static bool TryDivide(int a, int b, out int quotient, out int remainder)
{
    if (b == 0) { quotient = 0; remainder = 0; return false; }
    quotient = a / b;
    remainder = a % b;
    return true;
}

static (int Min, int Max) MinMax(int[] values)
{
    int min = int.MaxValue, max = int.MinValue;
    foreach (var v in values)
    {
        if (v < min) min = v;
        if (v > max) max = v;
    }
    return (min, max);
}

static long Factorial(int n) => n <= 1 ? 1 : n * Factorial(n - 1);
