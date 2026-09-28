using Microsoft.EntityFrameworkCore;
using TaskBoard.Application;
using TaskBoard.Domain;

namespace TaskBoard.Infrastructure;

public class EfTaskRepository(TaskBoardDbContext db) : ITaskRepository
{
    public Task<TaskItem?> FindAsync(int id, CancellationToken ct) =>
        db.Tasks.FirstOrDefaultAsync(t => t.Id == id, ct);

    public async Task<(IReadOnlyList<TaskItem> Items, int Total)> ListAsync(TaskQuery query, CancellationToken ct)
    {
        IQueryable<TaskItem> q = db.Tasks.AsNoTracking();
        if (query.Status is { } status) q = q.Where(t => t.Status == status);
        if (!string.IsNullOrWhiteSpace(query.Search))
            q = q.Where(t => EF.Functions.Like(t.Title, $"%{query.Search.Trim()}%"));

        int total = await q.CountAsync(ct);
        var items = await q
            .OrderBy(t => t.Status == Domain.TaskStatus.Done)   // unfinished first
            .ThenByDescending(t => t.Priority)
            .ThenBy(t => t.Id)
            .Skip((query.Page - 1) * query.PageSize)
            .Take(query.PageSize)
            .ToListAsync(ct);
        return (items, total);
    }

    public async Task AddAsync(TaskItem task, CancellationToken ct) => await db.Tasks.AddAsync(task, ct);

    public void Remove(TaskItem task) => db.Tasks.Remove(task);

    public Task SaveChangesAsync(CancellationToken ct) => db.SaveChangesAsync(ct);
}
