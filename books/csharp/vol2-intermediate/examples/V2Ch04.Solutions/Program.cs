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
