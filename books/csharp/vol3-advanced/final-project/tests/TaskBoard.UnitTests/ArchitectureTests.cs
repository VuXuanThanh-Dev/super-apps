using TaskBoard.Application;
using TaskBoard.Domain;

namespace TaskBoard.UnitTests;

/// <summary>Checks the dependency rule of clean architecture: inner layers do not know outer layers.</summary>
public class ArchitectureTests
{
    private static string[] ReferencedNames(Type typeInAssembly) =>
        typeInAssembly.Assembly.GetReferencedAssemblies().Select(a => a.Name!).ToArray();

    [Fact]
    public void Domain_DependsOnNoOtherLayerOrFramework()
    {
        var refs = ReferencedNames(typeof(TaskItem));
        Assert.DoesNotContain(refs, n => n.StartsWith("TaskBoard.", StringComparison.Ordinal));
        Assert.DoesNotContain(refs, n => n.StartsWith("Microsoft.EntityFrameworkCore", StringComparison.Ordinal));
        Assert.DoesNotContain(refs, n => n.StartsWith("Microsoft.AspNetCore", StringComparison.Ordinal));
    }

    [Fact]
    public void Application_DependsOnDomainOnly_NotOnInfrastructureOrEfCore()
    {
        var refs = ReferencedNames(typeof(TaskService));
        Assert.Contains("TaskBoard.Domain", refs);
        Assert.DoesNotContain("TaskBoard.Infrastructure", refs);
        Assert.DoesNotContain("TaskBoard.Api", refs);
        Assert.DoesNotContain(refs, n => n.StartsWith("Microsoft.EntityFrameworkCore", StringComparison.Ordinal));
    }
}
