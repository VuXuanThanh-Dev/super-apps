namespace TaskBoard.Domain;

public enum TaskStatus
{
    Todo = 0,
    InProgress = 1,
    Done = 2,
}

public enum Priority
{
    Low = 0,
    Medium = 1,
    High = 2,
}

/// <summary>Entity: a task on the board. Business rules live here, not in the API.</summary>
public class TaskItem
{
    public const int TitleMaxLength = 200;

    // For EF Core
    private TaskItem() { Title = ""; }

    public TaskItem(string title, string? description, Priority priority, DateOnly? dueDate, DateTimeOffset createdAt)
    {
        Title = ValidateTitle(title);
        Description = description?.Trim();
        Priority = priority;
        DueDate = dueDate;
        CreatedAt = createdAt;
        Status = TaskStatus.Todo;
    }

    public int Id { get; private set; }
    public string Title { get; private set; }
    public string? Description { get; private set; }
    public TaskStatus Status { get; private set; }
    public Priority Priority { get; private set; }
    public DateOnly? DueDate { get; private set; }
    public DateTimeOffset CreatedAt { get; private set; }
    public DateTimeOffset? CompletedAt { get; private set; }

    public void UpdateDetails(string title, string? description, Priority priority, DateOnly? dueDate)
    {
        if (Status == TaskStatus.Done)
            throw new DomainException("Không sửa được công việc đã hoàn thành.");
        Title = ValidateTitle(title);
        Description = description?.Trim();
        Priority = priority;
        DueDate = dueDate;
    }

    /// <summary>Allowed moves: Todo → InProgress → Done, and InProgress → Todo. Done is final.</summary>
    public void MoveTo(TaskStatus next, DateTimeOffset now)
    {
        var allowed = (Status, next) switch
        {
            (TaskStatus.Todo, TaskStatus.InProgress) => true,
            (TaskStatus.InProgress, TaskStatus.Done) => true,
            (TaskStatus.InProgress, TaskStatus.Todo) => true,
            _ => false,
        };
        if (!allowed)
            throw new DomainException($"Không chuyển được trạng thái từ {Status} sang {next}.");
        Status = next;
        CompletedAt = next == TaskStatus.Done ? now : null;
    }

    public bool IsOverdue(DateOnly today) => Status != TaskStatus.Done && DueDate is { } due && due < today;

    private static string ValidateTitle(string title)
    {
        if (string.IsNullOrWhiteSpace(title))
            throw new DomainException("Tiêu đề không được để trống.");
        title = title.Trim();
        if (title.Length > TitleMaxLength)
            throw new DomainException($"Tiêu đề tối đa {TitleMaxLength} ký tự.");
        return title;
    }
}

public class DomainException(string message) : Exception(message);
