# Chương 3 — Điều kiện, vòng lặp và phương thức

## Mục tiêu

- Viết `if`, `switch` statement và *switch expression*.
- Dùng các vòng lặp `for`, `while`, `do-while`, `foreach`, cùng `break` và `continue`.
- Viết phương thức (method): tham số mặc định, *named arguments*, `params`, `ref`, `out`.
- Trả nhiều giá trị bằng *tuple*.

## Giải thích đơn giản

Phần lớn cú pháp điều khiển của C# **giống hệt** TypeScript và Java: `if`, `for`, `while`,
`break`, `continue`, `return`. Những điểm mới đáng học:

- **switch expression**: `x switch { ... }` trả về một giá trị, ngắn hơn `switch` truyền thống.
- **`foreach`**: giống `for...of` trong TypeScript.
- **`ref` / `out`**: truyền biến theo tham chiếu, hàm có thể sửa biến của người gọi.
  TypeScript và Java không có.
- **Tuple có tên**: `(int Min, int Max)` — trả nhiều giá trị mà không cần tạo class.

## Ví dụ

<!-- include: examples/Ch03.Flow/Program.cs -->
```csharp
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
```

Output thật:

<!-- output: examples/Ch03.Flow -->
```text
Giỏi
Cuối tuần
Rank(82)=B, Rank(50)=D
for0 for1 for2 
while0 while1 while2 
do-chạy-ít-nhất-1-lần 
táo xoài 
Add(2, 3) = 5
Greet() = Xin chào, bạn!, Greet("An", "Hi") = Hi, An!
Named args: Chào, Bình!
params: Sum(1,2,3,4) = 10
Sau Increase(ref): 15
10 / 3 = 3 dư 1
Không chia được cho 0
min=1, max=9
Factorial(10) = 3628800
```

## Đi sâu

### switch expression và pattern

```csharp
string Rank(int s) => s switch
{
    >= 90 => "A",
    >= 80 => "B",
    _ => "D",      // _ = "mọi trường hợp còn lại" (discard)
};
```

- Mỗi nhánh là một *pattern* (mẫu). `>= 90` là *relational pattern*.
- Compiler kiểm tra các nhánh theo thứ tự từ trên xuống.
- Nếu thiếu `_` và không nhánh nào khớp → ném `SwitchExpressionException` lúc chạy
  (compiler cũng cảnh báo). Tập 2 (Chương 4) học pattern matching sâu hơn.

### Local function và `static`

Trong `Program.cs`, các hàm khai báo ở cuối file là *local function* của top-level statements.
Từ khóa `static` nghĩa là hàm **không** dùng biến bên ngoài nó → an toàn, rõ ràng hơn.
Hàm được gọi trước khi khai báo vẫn được, vì compiler xử lý cả file.

### Truyền tham số

| Cách | Ví dụ | Hàm có sửa được biến người gọi? | Yêu cầu |
|---|---|---|---|
| mặc định (by value) | `Add(a, b)` | không | — |
| `ref` | `Increase(ref x)` | có | biến phải được gán trước |
| `out` | `TryDivide(10, 3, out q, out r)` | có (phải gán) | hàm **bắt buộc** gán trước khi return |
| `in` | `Print(in bigStruct)` | không (chỉ đọc) | dùng cho struct lớn |

Mẫu `bool TryXxx(..., out T result)` rất phổ biến trong .NET: `int.TryParse`,
`Dictionary.TryGetValue`. Dùng `out _` để bỏ qua giá trị không cần.

### Tham số mặc định, named arguments, params

- `Greet(string name = "bạn")`: tham số mặc định (giống TS).
- `Greet(greeting: "Chào", name: "Bình")`: gọi theo tên, không cần đúng thứ tự.
- `Sum(params int[] values)`: nhận số lượng tham số tùy ý (giống `...values` trong TS).

### Expression-bodied member

`static int Add(int a, int b) => a + b;` là cách viết ngắn cho hàm chỉ có một biểu thức,
giống arrow function trong TS.

## Lỗi và bẫy thường gặp

- **Quên `break` trong `switch` statement**: C# không cho "rơi" (fall through) từ case có code
  sang case khác → lỗi CS0163. Case rỗng thì được gộp (như `"Sat"` và `"Sun"`).
- **Quên gán tham số `out`** trong mọi nhánh → lỗi CS0177.
- **`=` thay vì `==` trong `if`**: C# báo lỗi nếu kết quả không phải `bool` — an toàn hơn JS.
- **Đệ quy quá sâu** → `StackOverflowException`, không bắt được, chương trình dừng.
- **Sửa biến đếm trong `foreach`**: biến lặp của `foreach` là chỉ đọc.

## Tóm tắt

- Cú pháp `if`/`for`/`while` giống TS/Java.
- Switch expression + pattern cho code ngắn và an toàn.
- `ref`/`out` truyền theo tham chiếu; mẫu `TryXxx(out ...)` rất phổ biến.
- Tuple `(int Min, int Max)` để trả nhiều giá trị.

## Bài tập (có lời giải)

1. In FizzBuzz từ 1 đến 15 bằng switch expression trên tuple `(i % 3, i % 5)`.
2. Viết `IsPrime(int n)` và in các số nguyên tố nhỏ hơn 30.
3. Viết hàm trả về tuple `(Total, Average)` của một mảng số.
4. Viết `TryParseTime("12:30", out hour, out minute)` kiểm tra giờ hợp lệ.

<details>
<summary>Lời giải</summary>

<!-- include: examples/Ch03.Solutions/Program.cs -->
```csharp
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
```

<!-- output: examples/Ch03.Solutions -->
```text
Bài 1: 1 2 Fizz 4 Buzz Fizz 7 8 Fizz Buzz 11 Fizz 13 14 FizzBuzz
Bài 2: số nguyên tố < 30: 2, 3, 5, 7, 11, 13, 17, 19, 23, 29
Bài 3: tổng=108, trung bình=18.00
Bài 4: '12:30' hợp lệ? True -> 12h30
Bài 4: '25:99' hợp lệ? False
```

Chú ý bài 4: `hour is >= 0 and < 24` là *pattern* kết hợp `and`, dễ đọc hơn `hour >= 0 && hour < 24`.
</details>

## Nguồn tham khảo (Sources)

- Selection statements: https://github.com/dotnet/docs/blob/main/docs/csharp/fundamentals/statements/selection.md
- Iteration statements: https://github.com/dotnet/docs/blob/main/docs/csharp/fundamentals/statements/iteration.md
- Relational and logical patterns: https://github.com/dotnet/docs/blob/main/docs/csharp/fundamentals/patterns/relational-logical-patterns.md
- Tuples: https://github.com/dotnet/docs/blob/main/docs/csharp/fundamentals/types/tuples.md
- Discards: https://github.com/dotnet/docs/blob/main/docs/csharp/fundamentals/patterns/discards.md
