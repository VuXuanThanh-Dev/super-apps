using Microsoft.EntityFrameworkCore;
using TaskBoard.Domain;

namespace TaskBoard.Infrastructure;

public class TaskBoardDbContext(DbContextOptions<TaskBoardDbContext> options) : DbContext(options)
{
    public DbSet<TaskItem> Tasks => Set<TaskItem>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        var task = modelBuilder.Entity<TaskItem>();
        task.ToTable("tasks");
        task.HasKey(t => t.Id);
        task.Property(t => t.Title).HasMaxLength(TaskItem.TitleMaxLength).IsRequired();
        task.Property(t => t.Description).HasMaxLength(2000);
        task.Property(t => t.Status).HasConversion<string>().HasMaxLength(20);
        // Priority stays an int column, so ORDER BY Priority sorts Low < Medium < High.
        task.HasIndex(t => t.Status);
    }
}
