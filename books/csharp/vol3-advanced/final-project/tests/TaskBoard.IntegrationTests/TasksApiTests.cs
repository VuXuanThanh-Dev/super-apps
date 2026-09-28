using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using TaskBoard.Application;
using TaskBoard.Domain;
using TaskStatus = TaskBoard.Domain.TaskStatus;

namespace TaskBoard.IntegrationTests;

public class TasksApiTests(TaskBoardApiFactory factory) : IClassFixture<TaskBoardApiFactory>
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web)
    {
        Converters = { new JsonStringEnumConverter() },
    };

    private readonly HttpClient _client = factory.CreateClient();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    private async Task<TaskDto> CreateAsync(string title, Priority priority = Priority.Medium)
    {
        var response = await _client.PostAsJsonAsync("/api/tasks", new CreateTaskRequest(title, null, priority), Json, Ct);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        return (await response.Content.ReadFromJsonAsync<TaskDto>(Json, Ct))!;
    }

    [Fact]
    public async Task Health_ReturnsHealthy()
    {
        var response = await _client.GetAsync("/health", Ct);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("Healthy", await response.Content.ReadAsStringAsync(Ct));
    }

    [Fact]
    public async Task Post_ThenGet_ReturnsSameTask_WithLocationHeader()
    {
        var response = await _client.PostAsJsonAsync("/api/tasks", new CreateTaskRequest("Viết README", "cho dự án", Priority.High), Json, Ct);
        var created = (await response.Content.ReadFromJsonAsync<TaskDto>(Json, Ct))!;

        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        Assert.Equal($"/api/tasks/{created.Id}", response.Headers.Location?.ToString());

        var fetched = await _client.GetFromJsonAsync<TaskDto>($"/api/tasks/{created.Id}", Json, Ct);
        Assert.Equal(created, fetched);
    }

    [Fact]
    public async Task Post_InvalidBody_Returns400ProblemDetails()
    {
        var response = await _client.PostAsJsonAsync("/api/tasks", new CreateTaskRequest("", null), Json, Ct);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        Assert.Equal("application/problem+json", response.Content.Headers.ContentType?.MediaType);
        var body = await response.Content.ReadAsStringAsync(Ct);
        Assert.Contains("\"title\"", body);
        Assert.Contains("Tiêu đề là bắt buộc.", body);
    }

    [Fact]
    public async Task Get_Unknown_Returns404()
    {
        var response = await _client.GetAsync("/api/tasks/999999", Ct);
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task Status_Workflow_AndInvalidTransition_Returns409()
    {
        var task = await CreateAsync("Deploy lên staging");

        var skip = await _client.PatchAsJsonAsync($"/api/tasks/{task.Id}/status", new ChangeStatusRequest(TaskStatus.Done), Json, Ct);
        Assert.Equal(HttpStatusCode.Conflict, skip.StatusCode);

        var start = await _client.PatchAsJsonAsync($"/api/tasks/{task.Id}/status", new ChangeStatusRequest(TaskStatus.InProgress), Json, Ct);
        start.EnsureSuccessStatusCode();
        var done = await _client.PatchAsJsonAsync($"/api/tasks/{task.Id}/status", new ChangeStatusRequest(TaskStatus.Done), Json, Ct);
        var dto = (await done.Content.ReadFromJsonAsync<TaskDto>(Json, Ct))!;

        Assert.Equal(TaskStatus.Done, dto.Status);
        Assert.NotNull(dto.CompletedAt);
    }

    [Fact]
    public async Task Put_UpdatesTask()
    {
        var task = await CreateAsync("Tên cũ");
        var response = await _client.PutAsJsonAsync($"/api/tasks/{task.Id}", new UpdateTaskRequest("Tên mới", "mô tả", Priority.Low, null), Json, Ct);
        var dto = (await response.Content.ReadFromJsonAsync<TaskDto>(Json, Ct))!;
        Assert.Equal("Tên mới", dto.Title);
        Assert.Equal(Priority.Low, dto.Priority);
    }

    [Fact]
    public async Task Delete_RemovesTask()
    {
        var task = await CreateAsync("Tạm thời");
        var delete = await _client.DeleteAsync($"/api/tasks/{task.Id}", Ct);
        Assert.Equal(HttpStatusCode.NoContent, delete.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await _client.GetAsync($"/api/tasks/{task.Id}", Ct)).StatusCode);
    }

    [Fact]
    public async Task List_FiltersByStatusAndSearch_WithPaging()
    {
        var tag = Guid.NewGuid().ToString("N")[..8];
        for (int i = 1; i <= 3; i++) await CreateAsync($"{tag} việc {i}", Priority.Low);
        await CreateAsync($"{tag} việc gấp", Priority.High);

        var page = await _client.GetFromJsonAsync<PagedResult<TaskDto>>($"/api/tasks?search={tag}&status=Todo&page=1&pageSize=2", Json, Ct);

        Assert.NotNull(page);
        Assert.Equal(4, page.TotalCount);
        Assert.Equal(2, page.Items.Count);
        Assert.Equal($"{tag} việc gấp", page.Items[0].Title);   // High priority first
    }

    [Fact]
    public async Task OpenApi_DocumentIsServed()
    {
        var json = await _client.GetStringAsync("/openapi/v1.json", Ct);
        Assert.Contains("/api/tasks", json);
    }
}
