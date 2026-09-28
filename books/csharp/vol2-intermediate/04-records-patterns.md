# Chương 4 — Records và pattern matching

## Mục tiêu

- Dùng `record` và `record struct` cho dữ liệu bất biến, so sánh theo giá trị.
- Tạo bản sao bằng `with`, tách dữ liệu bằng *deconstruction*.
- Dùng pattern matching: type, property, positional, relational, logical, list, tuple pattern.
- Mô hình hóa dữ liệu kiểu "một trong nhiều loại" bằng record kế thừa + switch expression.

## Giải thích đơn giản

**Record** là class (hoặc struct) mà compiler viết sẵn cho bạn:

- constructor, property `init` từ danh sách tham số,
- `Equals`/`==` so sánh **theo giá trị** (không theo địa chỉ),
- `ToString()` đẹp: `Person { Name = An, Age = 28 }`,
- `Deconstruct` và biểu thức `with` để copy có sửa.

Với TypeScript, nó giống `type Person = { readonly name: string; readonly age: number }`
cộng thêm so sánh theo giá trị. Với Java, nó giống `record Person(String name, int age)`,
cộng thêm `with`.

**Pattern matching** (so khớp mẫu) là cách hỏi "giá trị này có hình dạng thế nào?" và lấy dữ
liệu ra cùng lúc. Nó giống *discriminated union* + `switch (x.kind)` trong TypeScript,
nhưng mạnh hơn.

## Ví dụ

<!-- include: examples/V2Ch04.Records/Program.cs -->
```csharp
// 1. Record: so sánh theo giá trị, ToString đẹp, with-expression
var p1 = new Person("An", 28);
var p2 = new Person("An", 28);
var p3 = p1 with { Age = 29 };
Console.WriteLine(p1);
Console.WriteLine($"p1 == p2: {p1 == p2}; ReferenceEquals: {ReferenceEquals(p1, p2)}; p3 = {p3}");

// Deconstruct
var (name, age) = p3;
Console.WriteLine($"Deconstruct: {name}, {age}");

// 2. record struct
var a = new Point(1, 2);
var b = a with { X = 5 };
Console.WriteLine($"{a} -> {b}");

// 3. Type pattern + property pattern + switch expression
Shape[] shapes = [new Circle(1), new Rectangle(2, 3), new Rectangle(4, 4), new Triangle(3, 4)];
foreach (var s in shapes)
{
    string desc = s switch
    {
        Circle { Radius: var r } => $"Hình tròn r={r}, S={Math.PI * r * r:F2}",
        Rectangle { Width: var w, Height: var h } when w == h => $"Hình vuông cạnh {w}",
        Rectangle(var w, var h) => $"Chữ nhật {w}x{h}",   // positional pattern
        _ => $"Hình khác: {s.GetType().Name}",
    };
    Console.WriteLine("  " + desc);
}

// 4. is + declaration pattern
object value = 42;
if (value is int n && n > 40) Console.WriteLine($"value là int lớn hơn 40: {n}");

// 5. Relational + logical patterns
static string Classify(int t) => t switch
{
    < 0 => "đóng băng",
    >= 0 and < 20 => "lạnh",
    >= 20 and < 30 => "dễ chịu",
    _ => "nóng",
};
Console.WriteLine($"Classify: {Classify(-5)}, {Classify(15)}, {Classify(25)}, {Classify(35)}");

// 6. List patterns
static string Describe(int[] xs) => xs switch
{
    [] => "rỗng",
    [var one] => $"một phần tử: {one}",
    [var first, .., var last] when first == last => $"đầu = cuối = {first}",
    [var first, .. var middle, var last] => $"đầu={first}, giữa có {middle.Length}, cuối={last}",
};
Console.WriteLine($"{Describe([])} | {Describe([7])} | {Describe([1, 2, 1])} | {Describe([1, 2, 3, 4])}");

// 7. Tuple pattern: máy trạng thái đơn giản
static string Next(string state, string action) => (state, action) switch
{
    ("Draft", "submit") => "Review",
    ("Review", "approve") => "Published",
    ("Review", "reject") => "Draft",
    (_, _) => state,
};
Console.WriteLine($"Draft -submit-> {Next("Draft", "submit")}; Review -reject-> {Next("Review", "reject")}; Published -submit-> {Next("Published", "submit")}");

// 8. Record kế thừa và so sánh theo kiểu
Order o1 = new OnlineOrder(1, 100m, "an@example.com");
Order o2 = new Order(1, 100m);
Console.WriteLine($"OnlineOrder == Order cùng dữ liệu? {o1 == o2}");

public record Person(string Name, int Age);
public readonly record struct Point(int X, int Y);

public abstract record Shape;
public record Circle(double Radius) : Shape;
public record Rectangle(double Width, double Height) : Shape;
public record Triangle(double A, double B) : Shape;

public record Order(int Id, decimal Total);
public record OnlineOrder(int Id, decimal Total, string Email) : Order(Id, Total);
```

Output thật:

<!-- output: examples/V2Ch04.Records -->
```text
Person { Name = An, Age = 28 }
p1 == p2: True; ReferenceEquals: False; p3 = Person { Name = An, Age = 29 }
Deconstruct: An, 29
Point { X = 1, Y = 2 } -> Point { X = 5, Y = 2 }
  Hình tròn r=1, S=3.14
  Chữ nhật 2x3
  Hình vuông cạnh 4
  Hình khác: Triangle
value là int lớn hơn 40: 42
Classify: đóng băng, lạnh, dễ chịu, nóng
rỗng | một phần tử: 7 | đầu = cuối = 1 | đầu=1, giữa có 2, cuối=4
Draft -submit-> Review; Review -reject-> Draft; Published -submit-> Published
OnlineOrder == Order cùng dữ liệu? False
```

## Đi sâu

### Các loại pattern

| Pattern | Ví dụ | Ý nghĩa |
|---|---|---|
| Type / declaration | `x is int n` | x là `int`, gán vào `n` |
| Constant | `x is null`, `"Sat"` | bằng hằng số |
| Relational | `< 0`, `>= 20` | so sánh |
| Logical | `>= 0 and < 20`, `not null`, `A or B` | kết hợp |
| Property | `Circle { Radius: var r }` | kiểm tra/lấy property |
| Positional | `Rectangle(var w, var h)` | dùng `Deconstruct` |
| List | `[var first, .., var last]` | khớp mảng/list theo vị trí |
| Tuple | `(state, action) switch { ("Draft", "submit") => ... }` | khớp nhiều giá trị |
| Discard | `_` | mọi giá trị |

### Thứ tự nhánh quan trọng

Trong ví dụ, nhánh "Hình vuông" (có `when w == h`) phải đứng **trước** nhánh `Rectangle(var w, var h)`.
Nếu đảo lại, nhánh tổng quát sẽ bắt hết. Compiler báo lỗi nếu một nhánh không bao giờ tới được
(CS8510).

### Record kế thừa và so sánh

`OnlineOrder == Order` trả về `False` dù `Id` và `Total` giống nhau: record so sánh cả
**kiểu thực tế** (qua property ẩn `EqualityContract`). Điều này tránh lỗi coi hai loại khác
nhau là bằng nhau.

### `record class` vs `record struct` vs `class`

| | `record` (class) | `readonly record struct` | `class` |
|---|---|---|---|
| Loại | reference | value | reference |
| `==` | theo giá trị | theo giá trị | theo tham chiếu |
| `with` | có | có | không |
| Dùng cho | DTO, event, kết quả query, value object | dữ liệu rất nhỏ (Point, Money nhỏ) | entity có hành vi và định danh |

Trong Web API (Tập 3), record rất hợp cho **DTO** (Data Transfer Object — object chở dữ liệu
request/response).

### Mô hình "một trong nhiều loại"

`abstract record Shape` + các record con + switch expression = cách phổ biến hiện nay để làm
*discriminated union*. C# 15 (cùng .NET 11, đang preview) bổ sung `union` và *closed hierarchies*
để compiler kiểm tra đủ mọi trường hợp — **UNVERIFIED** cú pháp cuối cùng khi phát hành chính thức.

## Lỗi và bẫy thường gặp

- **Record chứa collection** (`List<T>`): `==` so sánh tham chiếu của list, không so sánh
  từng phần tử. `with` copy nông (shallow copy) — hai record dùng chung một list.
- **Dùng record cho EF Core entity**: entity cần định danh và thường bị sửa; so sánh theo giá
  trị gây khó hiểu. Dùng `class` cho entity, record cho DTO.
- **Quên `_` trong switch expression**: compiler cảnh báo (thành lỗi khi `TreatWarningsAsErrors`),
  lúc chạy có thể ném `SwitchExpressionException`.
- **Đặt nhánh tổng quát trước nhánh cụ thể** → lỗi CS8510 hoặc logic sai với `when`.

## Tóm tắt

- `record` = dữ liệu bất biến, so sánh theo giá trị, `with`, `ToString` đẹp.
- Pattern matching giúp code phân nhánh ngắn, an toàn, dễ đọc.
- Abstract record + switch expression là cách mô hình hóa "một trong nhiều loại".

## Bài tập (có lời giải)

1. Viết `record Money(decimal Amount, string Currency)` với toán tử `+`; ném exception nếu khác loại tiền.
2. Tính phí thanh toán: thẻ VISA 2%, thẻ khác 3%, chuyển khoản > 2 triệu miễn phí (còn lại 5.000),
   tiền mặt 0 — dùng switch expression với property pattern.
3. Phân tích lệnh `"add milk 2"`, `"remove milk"`, `"list"`... bằng list pattern.

<details>
<summary>Lời giải</summary>

<!-- include: examples/V2Ch04.Solutions/Program.cs -->
```csharp
// Bài 1: record Money với phép cộng, kiểm tra cùng loại tiền
var a = new Money(100m, "VND");
var b = a with { Amount = 50m };
Console.WriteLine($"Bài 1: {a} + {b} = {a + b}; a == new Money(100, VND)? {a == new Money(100m, "VND")}");
try { _ = a + new Money(1m, "USD"); }
catch (InvalidOperationException ex) { Console.WriteLine($"Bài 1: {ex.Message}"); }

// Bài 2: tính phí thanh toán bằng switch expression + property pattern
Payment[] payments = [new Card(1_000_000m, "VISA"), new Card(1_000_000m, "JCB"), new BankTransfer(5_000_000m), new Cash(200_000m)];
foreach (var p in payments) Console.WriteLine($"Bài 2: {p} -> phí {Fee(p):N0}");

// Bài 3: phân tích lệnh bằng list pattern
foreach (var cmd in new[] { "add milk 2", "remove milk", "list", "add", "clear all now" })
    Console.WriteLine($"Bài 3: '{cmd}' -> {Parse(cmd.Split(' '))}");

static decimal Fee(Payment p) => p switch
{
    Card { Brand: "VISA" } c => c.Amount * 0.02m,
    Card c => c.Amount * 0.03m,
    BankTransfer { Amount: > 2_000_000m } => 0m,
    BankTransfer => 5_000m,
    Cash => 0m,
    _ => throw new ArgumentOutOfRangeException(nameof(p)),
};

static string Parse(string[] parts) => parts switch
{
    ["add", var item, var qty] when int.TryParse(qty, out var n) => $"Thêm {n} {item}",
    ["add", var item] => $"Thêm 1 {item}",
    ["remove", var item] => $"Xóa {item}",
    ["list"] => "Liệt kê",
    [var verb, ..] => $"Không hiểu lệnh '{verb}' với {parts.Length - 1} tham số",
    [] => "Lệnh rỗng",
};

public record Money(decimal Amount, string Currency)
{
    public static Money operator +(Money x, Money y) =>
        x.Currency == y.Currency
            ? x with { Amount = x.Amount + y.Amount }
            : throw new InvalidOperationException($"Không cộng được {x.Currency} với {y.Currency}");
    public override string ToString() => $"{Amount:N0} {Currency}";
}

public abstract record Payment(decimal Amount);
public record Card(decimal Amount, string Brand) : Payment(Amount);
public record BankTransfer(decimal Amount) : Payment(Amount);
public record Cash(decimal Amount) : Payment(Amount);
```

<!-- output: examples/V2Ch04.Solutions -->
```text
Bài 1: 100 VND + 50 VND = 150 VND; a == new Money(100, VND)? True
Bài 1: Không cộng được VND với USD
Bài 2: Card { Amount = 1000000, Brand = VISA } -> phí 20,000
Bài 2: Card { Amount = 1000000, Brand = JCB } -> phí 30,000
Bài 2: BankTransfer { Amount = 5000000 } -> phí 0
Bài 2: Cash { Amount = 200000 } -> phí 0
Bài 3: 'add milk 2' -> Thêm 2 milk
Bài 3: 'remove milk' -> Xóa milk
Bài 3: 'list' -> Liệt kê
Bài 3: 'add' -> Không hiểu lệnh 'add' với 0 tham số
Bài 3: 'clear all now' -> Không hiểu lệnh 'clear' với 2 tham số
```

Bài 3: nhánh `["add", var item, var qty] when int.TryParse(...)` vừa khớp vị trí vừa kiểm tra
số lượng hợp lệ.
</details>

## Nguồn tham khảo (Sources)

- Records (C# fundamentals): https://github.com/dotnet/docs/blob/main/docs/csharp/fundamentals/types/records.md
- Record (language reference): https://github.com/dotnet/docs/blob/main/docs/csharp/language-reference/builtin-types/record.md
- Pattern matching overview: https://github.com/dotnet/docs/blob/main/docs/csharp/fundamentals/patterns/pattern-matching.md
- Patterns (language reference): https://github.com/dotnet/docs/blob/main/docs/csharp/language-reference/operators/patterns.md
- List patterns: https://github.com/dotnet/docs/blob/main/docs/csharp/fundamentals/patterns/list-patterns.md
- C# 15 proposals (unions, closed hierarchies): https://github.com/dotnet/csharplang/blob/main/Language-Version-History.md
