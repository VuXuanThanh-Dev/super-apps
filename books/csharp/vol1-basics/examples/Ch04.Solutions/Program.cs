// Bài 1 + 2: class Student với validation bằng `field`, và interface IGradable
var s = new Student("An") { Score = 8.5 };
Console.WriteLine($"Bài 1: {s.Name} điểm {s.Score}, xếp loại {s.Grade()}");
try
{
    s.Score = 11;
}
catch (ArgumentOutOfRangeException ex)
{
    Console.WriteLine($"Bài 1: lỗi -> {ex.ParamName}: {ex.Message.Split(" (")[0]}");
}

// Bài 3: kế thừa + override
Animal[] animals = [new Dog("Mực"), new Cat("Mướp")];
foreach (var a in animals) Console.WriteLine($"Bài 3: {a.Name} kêu {a.Speak()}");

// Bài 4: struct Money bất biến
var price = new Money(100_000, "VND");
var doubled = price.Multiply(2);
Console.WriteLine($"Bài 4: {price} x2 = {doubled}");

public interface IGradable
{
    string Grade();
}

public class Student(string name) : IGradable
{
    public string Name { get; } = name;

    public double Score
    {
        get;
        set => field = value is >= 0 and <= 10
            ? value
            : throw new ArgumentOutOfRangeException(nameof(Score), "Điểm phải từ 0 đến 10");
    }

    public string Grade() => Score switch { >= 8 => "Giỏi", >= 6.5 => "Khá", >= 5 => "TB", _ => "Yếu" };
}

public abstract class Animal(string name)
{
    public string Name { get; } = name;
    public abstract string Speak();
}

public class Dog(string name) : Animal(name) { public override string Speak() => "Gâu gâu"; }
public class Cat(string name) : Animal(name) { public override string Speak() => "Meo meo"; }

public readonly struct Money(decimal amount, string currency)
{
    public decimal Amount { get; } = amount;
    public string Currency { get; } = currency;
    public Money Multiply(decimal factor) => new(Amount * factor, Currency);
    public override string ToString() => $"{Amount:N0} {Currency}";
}
