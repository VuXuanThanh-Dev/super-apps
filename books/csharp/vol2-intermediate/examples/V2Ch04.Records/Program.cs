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
