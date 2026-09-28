using System.Text.Json.Serialization;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Api;
using TaskBoard.Application;
using TaskBoard.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

// ---- Services (DI) ----
builder.Services.AddInfrastructure();     // EF Core + SQLite (connection string "TaskBoard")
builder.Services.AddSingleton(TimeProvider.System);
builder.Services.AddScoped<TaskService>();

builder.Services.ConfigureHttpJsonOptions(o =>
    o.SerializerOptions.Converters.Add(new JsonStringEnumConverter()));
builder.Services.AddProblemDetails();
builder.Services.AddExceptionHandler<ApiExceptionHandler>();
builder.Services.AddOpenApi();
builder.Services.AddHealthChecks().AddCheck<DatabaseHealthCheck>("database");

var app = builder.Build();

// ---- Database migration on startup (simple apps / demos) ----
if (app.Configuration.GetValue("Database:MigrateOnStartup", true))
{
    using var scope = app.Services.CreateScope();
    scope.ServiceProvider.GetRequiredService<TaskBoardDbContext>().Database.Migrate();
}

// ---- Middleware pipeline ----
app.UseExceptionHandler();
app.UseStatusCodePages();

app.MapOpenApi();                      // GET /openapi/v1.json
app.MapHealthChecks("/health");        // GET /health
app.MapGet("/", () => Results.Redirect("/openapi/v1.json")).ExcludeFromDescription();
app.MapTaskEndpoints();                // /api/tasks

app.Run();

// Makes Program visible to WebApplicationFactory<Program> in the integration tests.
public partial class Program;
