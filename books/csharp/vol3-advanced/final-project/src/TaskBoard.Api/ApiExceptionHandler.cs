using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using TaskBoard.Application;
using TaskBoard.Domain;

namespace TaskBoard.Api;

/// <summary>Maps exceptions to Problem Details (RFC 7807 / 9457) responses in one place.</summary>
public sealed class ApiExceptionHandler(IProblemDetailsService problemDetails, ILogger<ApiExceptionHandler> logger)
    : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(HttpContext http, Exception exception, CancellationToken ct)
    {
        ProblemDetails problem = exception switch
        {
            ValidationException v => new ValidationProblemDetails(v.Errors)
            {
                Status = StatusCodes.Status400BadRequest,
                Title = v.Message,
            },
            NotFoundException nf => new ProblemDetails { Status = StatusCodes.Status404NotFound, Title = nf.Message },
            DomainException d => new ProblemDetails { Status = StatusCodes.Status409Conflict, Title = d.Message },
            BadHttpRequestException b => new ProblemDetails { Status = StatusCodes.Status400BadRequest, Title = b.Message },
            _ => new ProblemDetails { Status = StatusCodes.Status500InternalServerError, Title = "Lỗi hệ thống." },
        };

        if (problem.Status == StatusCodes.Status500InternalServerError)
            logger.LogError(exception, "Unhandled exception for {Method} {Path}", http.Request.Method, http.Request.Path);
        else
            logger.LogInformation("Request {Method} {Path} failed with {Status}: {Title}",
                http.Request.Method, http.Request.Path, problem.Status, problem.Title);

        http.Response.StatusCode = problem.Status!.Value;
        return await problemDetails.TryWriteAsync(new ProblemDetailsContext
        {
            HttpContext = http,
            ProblemDetails = problem,
            Exception = exception,
        });
    }
}
