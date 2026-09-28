using Microsoft.AspNetCore.Http.HttpResults;
using TaskBoard.Application;
using TaskStatus = TaskBoard.Domain.TaskStatus;

namespace TaskBoard.Api;

public static class TaskEndpoints
{
    public static IEndpointRouteBuilder MapTaskEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/tasks").WithTags("Tasks");

        group.MapGet("/", async (TaskService service, TaskStatus? status, string? search,
                int page = 1, int pageSize = 20, CancellationToken ct = default) =>
            TypedResults.Ok(await service.ListAsync(new TaskQuery(status, search, page, pageSize), ct)))
            .WithName("ListTasks");

        group.MapGet("/{id:int}", async (int id, TaskService service, CancellationToken ct) =>
            TypedResults.Ok(await service.GetAsync(id, ct)))
            .WithName("GetTask");

        group.MapPost("/", async Task<Created<TaskDto>> (CreateTaskRequest request, TaskService service, CancellationToken ct) =>
        {
            var created = await service.CreateAsync(request, ct);
            return TypedResults.Created($"/api/tasks/{created.Id}", created);
        }).WithName("CreateTask");

        group.MapPut("/{id:int}", async (int id, UpdateTaskRequest request, TaskService service, CancellationToken ct) =>
            TypedResults.Ok(await service.UpdateAsync(id, request, ct)))
            .WithName("UpdateTask");

        group.MapPatch("/{id:int}/status", async (int id, ChangeStatusRequest request, TaskService service, CancellationToken ct) =>
            TypedResults.Ok(await service.ChangeStatusAsync(id, request, ct)))
            .WithName("ChangeTaskStatus");

        group.MapDelete("/{id:int}", async Task<NoContent> (int id, TaskService service, CancellationToken ct) =>
        {
            await service.DeleteAsync(id, ct);
            return TypedResults.NoContent();
        }).WithName("DeleteTask");

        return app;
    }
}
