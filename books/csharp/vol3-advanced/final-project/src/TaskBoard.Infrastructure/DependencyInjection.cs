using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TaskBoard.Application;

namespace TaskBoard.Infrastructure;

public static class DependencyInjection
{
    public const string ConnectionStringName = "TaskBoard";

    public static IServiceCollection AddInfrastructure(this IServiceCollection services)
    {
        // The connection string is read when the DbContext is created (not at startup),
        // so tests can override it through configuration.
        services.AddDbContext<TaskBoardDbContext>((sp, options) =>
            options.UseSqlite(sp.GetRequiredService<IConfiguration>().GetConnectionString(ConnectionStringName)
                              ?? "Data Source=taskboard.db"));
        services.AddScoped<ITaskRepository, EfTaskRepository>();
        return services;
    }
}
