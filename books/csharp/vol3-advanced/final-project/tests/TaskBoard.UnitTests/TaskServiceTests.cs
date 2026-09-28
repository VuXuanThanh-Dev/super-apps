using Microsoft.Extensions.Logging.Abstractions;
using TaskBoard.Application;
using TaskBoard.Domain;
using TaskStatus = TaskBoard.Domain.TaskStatus;

namespace TaskBoard.UnitTests;

public class TaskServiceTests
{
    private readonly InMemoryTaskRepository _repo = new();
    private readonly FixedTimeProvider _clock = new(new DateTimeOffset(2026, 9, 28, 8, 0, 0, TimeSpan.Zero));
    private readonly TaskService _service;

    public TaskServiceTests() => _service = new TaskService(_repo, _clock, NullLogger<TaskService>.Instance);

    [Fact]
    public async Task Create_ReturnsDto_AndSaves()
    {
        var dto = await _service.CreateAsync(new CreateTaskRequest("Viết test", "xUnit", Priority.High, new DateOnly(2026, 10, 1)), TestContext.Current.CancellationToken);

        Assert.Equal(1, dto.Id);
        Assert.Equal(TaskStatus.Todo, dto.Status);
        Assert.False(dto.IsOverdue);
        Assert.Equal(1, _repo.SaveCount);
    }

    [Fact]
    public async Task Create_InvalidInput_ThrowsValidationWithAllErrors()
    {
        var ex = await Assert.ThrowsAsync<ValidationException>(() =>
            _service.CreateAsync(new CreateTaskRequest("", null, Priority.Low, new DateOnly(2020, 1, 1)), TestContext.Current.CancellationToken));

        Assert.Contains("title", ex.Errors.Keys);
        Assert.Contains("dueDate", ex.Errors.Keys);
        Assert.Equal(0, _repo.SaveCount);
    }

    [Fact]
    public async Task Get_Missing_ThrowsNotFound() =>
        await Assert.ThrowsAsync<NotFoundException>(() => _service.GetAsync(42, TestContext.Current.CancellationToken));

    [Fact]
    public async Task ChangeStatus_ToDone_SetsCompletedAtFromClock()
    {
        var ct = TestContext.Current.CancellationToken;
        var created = await _service.CreateAsync(new CreateTaskRequest("Deploy", null), ct);
        await _service.ChangeStatusAsync(created.Id, new ChangeStatusRequest(TaskStatus.InProgress), ct);
        _clock.Now = _clock.Now.AddHours(3);

        var done = await _service.ChangeStatusAsync(created.Id, new ChangeStatusRequest(TaskStatus.Done), ct);

        Assert.Equal(TaskStatus.Done, done.Status);
        Assert.Equal(_clock.Now, done.CompletedAt);
    }

    [Fact]
    public async Task Overdue_IsComputedFromClock()
    {
        var ct = TestContext.Current.CancellationToken;
        var created = await _service.CreateAsync(new CreateTaskRequest("Báo cáo", null, Priority.Medium, new DateOnly(2026, 9, 30)), ct);
        _clock.Now = new DateTimeOffset(2026, 10, 2, 0, 0, 0, TimeSpan.Zero);

        var dto = await _service.GetAsync(created.Id, ct);

        Assert.True(dto.IsOverdue);
    }

    [Theory]
    [InlineData(0, 20)]
    [InlineData(1, 0)]
    [InlineData(1, 101)]
    public async Task List_InvalidPaging_Throws(int page, int pageSize) =>
        await Assert.ThrowsAsync<ValidationException>(() => _service.ListAsync(new TaskQuery(Page: page, PageSize: pageSize), TestContext.Current.CancellationToken));

    [Fact]
    public async Task List_FiltersBySearch()
    {
        var ct = TestContext.Current.CancellationToken;
        await _service.CreateAsync(new CreateTaskRequest("Học LINQ", null), ct);
        await _service.CreateAsync(new CreateTaskRequest("Học EF Core", null), ct);
        await _service.CreateAsync(new CreateTaskRequest("Đi chợ", null), ct);

        var result = await _service.ListAsync(new TaskQuery(Search: "học"), ct);

        Assert.Equal(2, result.TotalCount);
    }
}
