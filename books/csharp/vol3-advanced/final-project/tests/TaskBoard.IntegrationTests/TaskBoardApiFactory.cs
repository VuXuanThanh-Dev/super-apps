using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Data.Sqlite;

namespace TaskBoard.IntegrationTests;

/// <summary>
/// Starts the real API in memory (no network port) with a private in-memory SQLite database.
/// The "keep-alive" connection keeps the shared in-memory database alive during the tests.
/// </summary>
public sealed class TaskBoardApiFactory : WebApplicationFactory<Program>
{
    private readonly string _connectionString = $"Data Source=taskboard-test-{Guid.NewGuid():N};Mode=Memory;Cache=Shared";
    private readonly SqliteConnection _keepAlive;

    public TaskBoardApiFactory()
    {
        _keepAlive = new SqliteConnection(_connectionString);
        _keepAlive.Open();
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");
        builder.UseSetting("ConnectionStrings:TaskBoard", _connectionString);
    }

    protected override void Dispose(bool disposing)
    {
        base.Dispose(disposing);
        if (disposing) _keepAlive.Dispose();
    }
}
