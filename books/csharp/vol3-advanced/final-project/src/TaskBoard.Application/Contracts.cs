using TaskBoard.Domain;
using TaskStatus = TaskBoard.Domain.TaskStatus;

namespace TaskBoard.Application;

// DTOs: what the API receives and returns. Records = immutable, value equality.
public record CreateTaskRequest(string Title, string? Description, Priority Priority = Priority.Medium, DateOnly? DueDate = null);

public record UpdateTaskRequest(string Title, string? Description, Priority Priority, DateOnly? DueDate);

public record ChangeStatusRequest(TaskStatus Status);

public record TaskDto(
    int Id,
    string Title,
    string? Description,
    TaskStatus Status,
    Priority Priority,
    DateOnly? DueDate,
    bool IsOverdue,
    DateTimeOffset CreatedAt,
    DateTimeOffset? CompletedAt);

public record TaskQuery(TaskStatus? Status = null, string? Search = null, int Page = 1, int PageSize = 20);

public record PagedResult<T>(IReadOnlyList<T> Items, int Page, int PageSize, int TotalCount);

/// <summary>Port: implemented by Infrastructure (EF Core). Application does not know about EF.</summary>
public interface ITaskRepository
{
    Task<TaskItem?> FindAsync(int id, CancellationToken ct);
    Task<(IReadOnlyList<TaskItem> Items, int Total)> ListAsync(TaskQuery query, CancellationToken ct);
    Task AddAsync(TaskItem task, CancellationToken ct);
    void Remove(TaskItem task);
    Task SaveChangesAsync(CancellationToken ct);
}

public class NotFoundException(string message) : Exception(message);

public class ValidationException(IDictionary<string, string[]> errors) : Exception("Dữ liệu không hợp lệ.")
{
    public IDictionary<string, string[]> Errors { get; } = errors;
}
