using Ch04.Oop;

// 1. Class và object
var account = new BankAccount("Nobin", 1_000_000);
account.Deposit(500_000);
bool ok = account.TryWithdraw(2_000_000);
Console.WriteLine($"Rút 2 triệu thành công? {ok}");
account.TryWithdraw(300_000);
account.Note = "   tài khoản lương   ";
Console.WriteLine(account);
Console.WriteLine($"Note: '{account.Note}'");
Console.WriteLine("Lịch sử: " + string.Join("; ", account.History));

try
{
    account.Deposit(-5);
}
catch (ArgumentOutOfRangeException ex)
{
    Console.WriteLine($"Lỗi: {ex.Message}");
}

// 2. Kế thừa và đa hình (polymorphism)
List<IShape> shapes = [new Rectangle(3, 4), new Square(2), new Circle(1)];
foreach (var shape in shapes)
{
    Console.WriteLine(shape.Describe());
}
Console.WriteLine($"Square là Rectangle? {shapes[1] is Rectangle}");

// 3. struct là value type: copy khi gán
var p1 = new Point(1, 2);
var p2 = p1.Move(10, 0);
Console.WriteLine($"p1={p1}, p2={p2}");

// 4. required / init / static
var product = new Product { Sku = "SKU-1", Name = "Bàn phím", Price = 750_000 };
_ = new Product { Sku = "SKU-2", Name = "Chuột" };
Console.WriteLine($"{product.Name} giá {product.Price:N0}; đã tạo {Product.CreatedCount} sản phẩm");
