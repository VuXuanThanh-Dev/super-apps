using Microsoft.EntityFrameworkCore;
using V3Ch02.EfCore;

string dbPath = Path.Combine(Path.GetTempPath(), "v3ch02-library.db");
File.Delete(dbPath);
string cs = $"Data Source={dbPath}";

// 1. Tạo database từ model (demo). Dự án thật dùng migrations (xem chương).
await using (var db = new LibraryContext(cs))
{
    await db.Database.EnsureCreatedAsync();
    Console.WriteLine($"Đã tạo DB: {Path.GetFileName(dbPath)}");
}

// 2. Thêm dữ liệu: Add + SaveChanges (1 transaction)
await using (var db = new LibraryContext(cs))
{
    var nam = new Author { Name = "Nguyễn Nhật Ánh" };
    nam.Books.Add(new Book { Title = "Mắt biếc", Price = 110_000m, Year = 1990 });
    nam.Books.Add(new Book { Title = "Cho tôi xin một vé đi tuổi thơ", Price = 85_000m, Year = 2008 });
    var to = new Author { Name = "Tô Hoài" };
    to.Books.Add(new Book { Title = "Dế Mèn phiêu lưu ký", Price = 60_000m, Year = 1941 });
    db.Authors.AddRange(nam, to);
    int rows = await db.SaveChangesAsync();
    Console.WriteLine($"SaveChanges: {rows} dòng; id tác giả = {nam.Id}, {to.Id}");
}

// 3. Query LINQ -> SQL
await using (var db = new LibraryContext(cs))
{
    LibraryContext.ShowSql = true;
    Console.WriteLine("Sách sau năm 1980, giá giảm dần:");
    var books = await db.Books
        .Where(b => b.Year > 1980)
        .OrderByDescending(b => b.Price)
        .Select(b => new { b.Title, b.Price, Author = b.Author.Name })   // projection: chỉ lấy cột cần
        .ToListAsync();
    LibraryContext.ShowSql = false;
    foreach (var b in books) Console.WriteLine($"  {b.Title} - {b.Author} - {b.Price:N0}");
}

// 4. Include (eager loading) và GroupBy
await using (var db = new LibraryContext(cs))
{
    var authors = await db.Authors.Include(a => a.Books).OrderBy(a => a.Name).ToListAsync();
    foreach (var a in authors) Console.WriteLine($"  {a.Name}: {a.Books.Count} cuốn");

    var stats = await db.Books.GroupBy(b => b.Author.Name)
        .Select(g => new { Author = g.Key, Avg = g.Average(b => (double)b.Price) })
        .ToListAsync();
    foreach (var s in stats) Console.WriteLine($"  Giá TB {s.Author}: {s.Avg:N0}");
}

// 5. Change tracking: sửa object rồi SaveChanges -> UPDATE
await using (var db = new LibraryContext(cs))
{
    var book = await db.Books.SingleAsync(b => b.Title == "Mắt biếc");
    book.Price = 120_000m;
    Console.WriteLine($"Trạng thái trước SaveChanges: {db.Entry(book).State}");
    LibraryContext.ShowSql = true;
    await db.SaveChangesAsync();
    LibraryContext.ShowSql = false;
    Console.WriteLine($"Trạng thái sau SaveChanges: {db.Entry(book).State}");

    var readOnly = await db.Books.AsNoTracking().FirstAsync();
    Console.WriteLine($"AsNoTracking -> trạng thái: {db.Entry(readOnly).State}");
}

// 6. ExecuteUpdate / ExecuteDelete: cập nhật hàng loạt, không nạp entity
await using (var db = new LibraryContext(cs))
{
    LibraryContext.ShowSql = true;
    int updated = await db.Books.Where(b => b.Year < 2000)
        .ExecuteUpdateAsync(s => s.SetProperty(b => b.Price, b => b.Price * 0.9m));
    LibraryContext.ShowSql = false;
    Console.WriteLine($"ExecuteUpdate: giảm giá 10% cho {updated} cuốn");
}

// 7. Transaction thủ công: hoặc tất cả, hoặc không gì cả
await using (var db = new LibraryContext(cs))
{
    await using var tx = await db.Database.BeginTransactionAsync();
    try
    {
        db.Books.Add(new Book { Title = "Sách tạm", Price = 1m, Year = 2026, AuthorId = 1 });
        await db.SaveChangesAsync();
        db.Books.Add(new Book { Title = "Sách lỗi", Price = 1m, Year = 2026, AuthorId = 999 }); // FK không tồn tại
        await db.SaveChangesAsync();
        await tx.CommitAsync();
    }
    catch (DbUpdateException ex)
    {
        await tx.RollbackAsync();
        Console.WriteLine($"Rollback vì: {ex.InnerException?.Message}");
    }
}

await using (var db = new LibraryContext(cs))
{
    Console.WriteLine($"Số sách cuối cùng: {await db.Books.CountAsync()} (không có 'Sách tạm')");
}
File.Delete(dbPath);
