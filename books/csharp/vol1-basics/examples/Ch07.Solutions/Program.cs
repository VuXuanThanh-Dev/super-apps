// Bài 1: dịch đoạn TypeScript sau sang C#:
//   const total = orders.filter(o => o.paid).reduce((s, o) => s + o.amount, 0);
Order[] orders = [new(1, 100m, true), new(2, 50m, false), new(3, 70m, true)];
decimal total = orders.Where(o => o.Paid).Sum(o => o.Amount);
Console.WriteLine($"Bài 1: tổng đã thanh toán = {total}");

// Bài 2: Java Optional<String> -> C# nullable
string? FindEmail(int id) => id == 1 ? "an@example.com" : null;
Console.WriteLine($"Bài 2: {FindEmail(1) ?? "(none)"} | {FindEmail(2) ?? "(none)"}");

// Bài 3: TS union type 'ok' | 'error' -> C# enum + switch expression
foreach (var st in Enum.GetValues<Status>())
    Console.WriteLine($"Bài 3: {st} -> {Describe(st)}");

static string Describe(Status s) => s switch
{
    Status.Ok => "thành công",
    Status.Error => "thất bại",
    _ => throw new ArgumentOutOfRangeException(nameof(s)),
};

record Order(int Id, decimal Amount, bool Paid);
enum Status { Ok, Error }
