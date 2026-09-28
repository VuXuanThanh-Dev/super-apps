using TaskBoard.Domain;
using TaskStatus = TaskBoard.Domain.TaskStatus;

namespace TaskBoard.UnitTests;

public class TaskItemTests
{
    private static readonly DateTimeOffset Now = new(2026, 9, 28, 8, 0, 0, TimeSpan.Zero);

    private static TaskItem NewTask(DateOnly? due = null) => new("Viết chương 1", null, Priority.High, due, Now);

    [Fact]
    public void NewTask_StartsInTodo_WithTrimmedTitle()
    {
        var task = new TaskItem("  Học EF Core  ", " ghi chú ", Priority.Low, null, Now);
        Assert.Equal(TaskStatus.Todo, task.Status);
        Assert.Equal("Học EF Core", task.Title);
        Assert.Equal("ghi chú", task.Description);
    }

    [Theory]
    [InlineData("")]
    [InlineData("   ")]
    public void NewTask_BlankTitle_Throws(string title) =>
        Assert.Throws<DomainException>(() => new TaskItem(title, null, Priority.Low, null, Now));

    [Fact]
    public void MoveTo_FollowsWorkflow_AndSetsCompletedAt()
    {
        var task = NewTask();
        task.MoveTo(TaskStatus.InProgress, Now);
        task.MoveTo(TaskStatus.Done, Now.AddHours(2));
        Assert.Equal(TaskStatus.Done, task.Status);
        Assert.Equal(Now.AddHours(2), task.CompletedAt);
    }

    [Theory]
    [InlineData(TaskStatus.Todo, TaskStatus.Done)]
    [InlineData(TaskStatus.Todo, TaskStatus.Todo)]
    public void MoveTo_InvalidTransition_Throws(TaskStatus from, TaskStatus to)
    {
        var task = NewTask();
        Assert.Equal(from, task.Status);
        var ex = Assert.Throws<DomainException>(() => task.MoveTo(to, Now));
        Assert.Contains("Không chuyển được", ex.Message);
    }

    [Fact]
    public void DoneTask_CannotBeEdited()
    {
        var task = NewTask();
        task.MoveTo(TaskStatus.InProgress, Now);
        task.MoveTo(TaskStatus.Done, Now);
        Assert.Throws<DomainException>(() => task.UpdateDetails("Mới", null, Priority.Low, null));
    }

    [Fact]
    public void IsOverdue_OnlyWhenNotDoneAndPastDue()
    {
        var today = new DateOnly(2026, 9, 28);
        Assert.True(NewTask(today.AddDays(-1)).IsOverdue(today));
        Assert.False(NewTask(today).IsOverdue(today));
        Assert.False(NewTask().IsOverdue(today));
    }
}
