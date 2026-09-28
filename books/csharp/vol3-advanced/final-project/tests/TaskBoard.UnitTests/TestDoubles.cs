using TaskBoard.Application;
using TaskBoard.Domain;

namespace TaskBoard.UnitTests;

public sealed class FixedTimeProvider(DateTimeOffset now) : TimeProvider
{
    public DateTimeOffset Now { get; set; } = now;
    public override DateTimeOffset GetUtcNow() => Now;
}

/// <summary>In-memory fake of the repository port. No database needed for unit tests.</summary>
public sealed class InMemoryTaskRepository : ITaskRepository
{
    private readonly List<TaskItem> _items = [];
    private int _nextId = 1;
    public int SaveCount { get; private set; }

    public Task<TaskItem?> FindAsync(int id, CancellationToken ct) => Task.FromResult(_items.FirstOrDefault(t => t.Id == id));

    public Task<(IReadOnlyList<TaskItem> Items, int Total)> ListAsync(TaskQuery query, CancellationToken ct)
    {
        var q = _items.AsEnumerable();
        if (query.Status is { } s) q = q.Where(t => t.Status == s);
        if (!string.IsNullOrWhiteSpace(query.Search)) q = q.Where(t => t.Title.Contains(query.Search, StringComparison.OrdinalIgnoreCase));
        var all = q.ToList();
        IReadOnlyList<TaskItem> page = all.Skip((query.Page - 1) * query.PageSize).Take(query.PageSize).ToList();
        return Task.FromResult((page, all.Count));
    }

    public Task AddAsync(TaskItem task, CancellationToken ct)
    {
        // Simulate the database generating the Id.
        typeof(TaskItem).GetProperty(nameof(TaskItem.Id))!.SetValue(task, _nextId++);
        _items.Add(task);
        return Task.CompletedTask;
    }

    public void Remove(TaskItem task) => _items.Remove(task);

    public Task SaveChangesAsync(CancellationToken ct) { SaveCount++; return Task.CompletedTask; }
}
