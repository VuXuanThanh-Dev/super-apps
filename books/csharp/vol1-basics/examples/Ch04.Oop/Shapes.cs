namespace Ch04.Oop;

// Interface: "hợp đồng" mà class phải thực hiện
public interface IShape
{
    string Name { get; }
    double Area();
    // Default interface method (có thân hàm sẵn)
    string Describe() => $"{Name} có diện tích {Area():F2}";
}

// Abstract class: không tạo object trực tiếp được
public abstract class Shape : IShape
{
    public abstract string Name { get; }
    public abstract double Area();
    public override string ToString() => ((IShape)this).Describe();
}

// Primary constructor (C# 12): tham số (width, height) dùng trong cả class
public class Rectangle(double width, double height) : Shape
{
    public double Width { get; } = width;
    public double Height { get; } = height;
    public override string Name => "Hình chữ nhật";
    public override double Area() => Width * Height;
}

public sealed class Square(double side) : Rectangle(side, side)
{
    public override string Name => "Hình vuông";
}

public class Circle(double radius) : Shape
{
    public override string Name => "Hình tròn";
    public override double Area() => Math.PI * radius * radius;
}

// struct: value type, thích hợp cho dữ liệu nhỏ, bất biến
public readonly struct Point(int x, int y)
{
    public int X { get; } = x;
    public int Y { get; } = y;
    public Point Move(int dx, int dy) => new(X + dx, Y + dy);
    public override string ToString() => $"({X}, {Y})";
}

// required + init: bắt buộc gán khi khởi tạo, không sửa được sau đó
public class Product
{
    public required string Sku { get; init; }
    public required string Name { get; init; }
    public decimal Price { get; init; }
    public static int CreatedCount { get; private set; }   // static: thuộc về class
    public Product() => CreatedCount++;
}
