using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace V3Ch02.EfCore;

public class Author
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public List<Book> Books { get; } = [];          // navigation: 1 author - n books
}

public class Book
{
    public int Id { get; set; }
    public required string Title { get; set; }
    public decimal Price { get; set; }
    public int Year { get; set; }
    public int AuthorId { get; set; }               // foreign key
    public Author Author { get; set; } = null!;     // navigation
}

public class LibraryContext(string connectionString) : DbContext
{
    public DbSet<Author> Authors => Set<Author>();
    public DbSet<Book> Books => Set<Book>();

    /// <summary>When true, the SQL that EF Core sends to SQLite is printed.</summary>
    public static bool ShowSql { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder options) => options
        .UseSqlite(connectionString)
        .LogTo(sql => { if (ShowSql) Console.WriteLine("   SQL> " + OneLine(sql)); },
               [DbLoggerCategory.Database.Command.Name], LogLevel.Information);

    protected override void OnModelCreating(ModelBuilder model)
    {
        model.Entity<Author>().Property(a => a.Name).HasMaxLength(100);
        model.Entity<Book>().Property(b => b.Title).HasMaxLength(200);
        model.Entity<Book>().HasIndex(b => b.Title);
        model.Entity<Book>().Property(b => b.Price).HasConversion<double>(); // SQLite has no decimal type
    }

    private static string OneLine(string log)
    {
        // Keep only the SQL text (after the first blank line) on one line.
        var idx = log.IndexOf(Environment.NewLine, StringComparison.Ordinal);
        var sql = idx >= 0 ? log[(idx + Environment.NewLine.Length)..] : log;
        return string.Join(' ', sql.Split(Environment.NewLine, StringSplitOptions.RemoveEmptyEntries).Select(s => s.Trim()));
    }
}
