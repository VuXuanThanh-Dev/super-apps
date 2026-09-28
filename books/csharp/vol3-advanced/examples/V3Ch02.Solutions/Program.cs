using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;

// In-memory SQLite: DB sống khi connection còn mở (tiện cho demo và test)
await using var connection = new SqliteConnection("Data Source=:memory:");
await connection.OpenAsync();
var options = new DbContextOptionsBuilder<ShopContext>().UseSqlite(connection).Options;

await using (var db = new ShopContext(options))
{
    await db.Database.EnsureCreatedAsync();
    var fruits = new Category { Name = "Trái cây" };
    var drinks = new Category { Name = "Đồ uống" };
    db.Products.AddRange(
        new Product { Name = "Cam", Price = 30_000, Category = fruits },
        new Product { Name = "Xoài", Price = 45_000, Category = fruits },
        new Product { Name = "Trà sữa", Price = 35_000, Category = drinks },
        new Product { Name = "Cà phê", Price = 25_000, Category = drinks },
        new Product { Name = "Nước cam", Price = 20_000, Category = drinks });
    await db.SaveChangesAsync();
}

await using (var db = new ShopContext(options))
{
    // Bài 1: danh mục có tổng giá cao nhất
    var top = await db.Categories
        .Select(c => new { c.Name, Total = c.Products.Sum(p => p.Price) })
        .OrderByDescending(x => x.Total)
        .FirstAsync();
    Console.WriteLine($"Bài 1: {top.Name} (tổng {top.Total:N0})");

    // Bài 2: phân trang, trang 2, mỗi trang 2 sản phẩm, sắp theo tên
    var page2 = await db.Products.OrderBy(p => p.Name).Skip(2).Take(2).Select(p => p.Name).ToListAsync();
    Console.WriteLine($"Bài 2: trang 2 = {string.Join(", ", page2)}");

    // Bài 3: soft delete với global query filter
    var coffee = await db.Products.SingleAsync(p => p.Name == "Cà phê");
    coffee.IsDeleted = true;
    await db.SaveChangesAsync();
}

await using (var db = new ShopContext(options))
{
    Console.WriteLine($"Bài 3: số sản phẩm thấy được = {await db.Products.CountAsync()}");
    Console.WriteLine($"Bài 3: kể cả đã xóa mềm = {await db.Products.IgnoreQueryFilters().CountAsync()}");
}

public class Category
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public List<Product> Products { get; } = [];
}

public class Product
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public long Price { get; set; }            // lưu tiền VND dạng số nguyên (đồng)
    public bool IsDeleted { get; set; }
    public int CategoryId { get; set; }
    public Category Category { get; set; } = null!;
}

public class ShopContext(DbContextOptions<ShopContext> options) : DbContext(options)
{
    public DbSet<Product> Products => Set<Product>();
    public DbSet<Category> Categories => Set<Category>();

    protected override void OnModelCreating(ModelBuilder model) =>
        model.Entity<Product>().HasQueryFilter(p => !p.IsDeleted);
}
