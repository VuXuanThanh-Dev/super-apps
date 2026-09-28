using Microsoft.Extensions.Diagnostics.HealthChecks;
using TaskBoard.Infrastructure;

namespace TaskBoard.Api;

public sealed class DatabaseHealthCheck(TaskBoardDbContext db) : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken ct = default)
        => await db.Database.CanConnectAsync(ct)
            ? HealthCheckResult.Healthy("SQLite reachable")
            : HealthCheckResult.Unhealthy("Cannot connect to SQLite");
}
