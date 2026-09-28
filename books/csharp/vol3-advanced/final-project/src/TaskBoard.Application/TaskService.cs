using Microsoft.Extensions.Logging;
using TaskBoard.Domain;

namespace TaskBoard.Application;

/// <summary>Use cases of the application. Depends only on abstractions (ports).</summary>
public class TaskService(ITaskRepository repository, TimeProvider clock, ILogger<TaskService> logger)
{
    private DateOnly Today => DateOnly.FromDateTime(clock.GetUtcNow().UtcDateTime);

    public async Task<TaskDto> CreateAsync(CreateTaskRequest request, CancellationToken ct = default)
    {
        Validate(request.Title, request.DueDate, isNew: true);
        var task = new TaskItem(request.Title, request.Description, request.Priority, request.DueDate, clock.GetUtcNow());
        await repository.AddAsync(task, ct);
        await repository.SaveChangesAsync(ct);
        logger.LogInformation("Created task {TaskId} with priority {Priority}", task.Id, task.Priority);
        return ToDto(task);
    }

    public async Task<TaskDto> GetAsync(int id, CancellationToken ct = default)
        => ToDto(await FindOrThrowAsync(id, ct));

    public async Task<PagedResult<TaskDto>> ListAsync(TaskQuery query, CancellationToken ct = default)
    {
        var errors = new Dictionary<string, string[]>();
        if (query.Page < 1) errors["page"] = ["page phải >= 1."];
        if (query.PageSize is < 1 or > 100) errors["pageSize"] = ["pageSize phải từ 1 đến 100."];
        if (errors.Count > 0) throw new ValidationException(errors);

        var (items, total) = await repository.ListAsync(query, ct);
        return new PagedResult<TaskDto>(items.Select(ToDto).ToList(), query.Page, query.PageSize, total);
    }

    public async Task<TaskDto> UpdateAsync(int id, UpdateTaskRequest request, CancellationToken ct = default)
    {
        Validate(request.Title, request.DueDate, isNew: false);
        var task = await FindOrThrowAsync(id, ct);
        task.UpdateDetails(request.Title, request.Description, request.Priority, request.DueDate);
        await repository.SaveChangesAsync(ct);
        return ToDto(task);
    }

    public async Task<TaskDto> ChangeStatusAsync(int id, ChangeStatusRequest request, CancellationToken ct = default)
    {
        var task = await FindOrThrowAsync(id, ct);
        var old = task.Status;
        task.MoveTo(request.Status, clock.GetUtcNow());
        await repository.SaveChangesAsync(ct);
        logger.LogInformation("Task {TaskId} moved {OldStatus} -> {NewStatus}", id, old, task.Status);
        return ToDto(task);
    }

    public async Task DeleteAsync(int id, CancellationToken ct = default)
    {
        var task = await FindOrThrowAsync(id, ct);
        repository.Remove(task);
        await repository.SaveChangesAsync(ct);
        logger.LogInformation("Deleted task {TaskId}", id);
    }

    private async Task<TaskItem> FindOrThrowAsync(int id, CancellationToken ct)
        => await repository.FindAsync(id, ct) ?? throw new NotFoundException($"Không tìm thấy công việc {id}.");

    private void Validate(string? title, DateOnly? dueDate, bool isNew)
    {
        var errors = new Dictionary<string, string[]>();
        if (string.IsNullOrWhiteSpace(title))
            errors["title"] = ["Tiêu đề là bắt buộc."];
        else if (title.Trim().Length > TaskItem.TitleMaxLength)
            errors["title"] = [$"Tiêu đề tối đa {TaskItem.TitleMaxLength} ký tự."];
        if (isNew && dueDate is { } due && due < Today)
            errors["dueDate"] = ["Hạn chót không được ở quá khứ."];
        if (errors.Count > 0) throw new ValidationException(errors);
    }

    private TaskDto ToDto(TaskItem t) => new(
        t.Id, t.Title, t.Description, t.Status, t.Priority, t.DueDate, t.IsOverdue(Today), t.CreatedAt, t.CompletedAt);
}
