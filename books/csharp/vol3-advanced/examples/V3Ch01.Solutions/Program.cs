using System.Collections.Concurrent;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Http.HttpResults;

var builder = WebApplication.CreateBuilder(args);
builder.Logging.SetMinimumLevel(LogLevel.Warning);
builder.WebHost.UseUrls("http://127.0.0.1:5198");
builder.Services.AddProblemDetails();
var app = builder.Build();

var notes = new ConcurrentDictionary<int, Note>();
notes[1] = new Note(1, "Học Minimal API");

// Bài 2: endpoint filter kiểm tra header X-Api-Key cho cả group
var api = app.MapGroup("/api/notes").AddEndpointFilter(async (ctx, next) =>
    ctx.HttpContext.Request.Headers["X-Api-Key"] == "secret"
        ? await next(ctx)
        : TypedResults.Problem(statusCode: 401, title: "Thiếu hoặc sai X-Api-Key"));

// Bài 3: 404 trả về ProblemDetails có title rõ ràng
api.MapGet("/{id:int}", Results<Ok<Note>, ProblemHttpResult> (int id) =>
    notes.TryGetValue(id, out var n) ? TypedResults.Ok(n)
        : TypedResults.Problem(statusCode: 404, title: $"Không có ghi chú {id}"));

// Bài 1: PUT cập nhật, trả 404 nếu không có
api.MapPut("/{id:int}", Results<Ok<Note>, ProblemHttpResult> (int id, UpdateNote body) =>
{
    if (!notes.ContainsKey(id)) return TypedResults.Problem(statusCode: 404, title: $"Không có ghi chú {id}");
    var updated = new Note(id, body.Text);
    notes[id] = updated;
    return TypedResults.Ok(updated);
});

await app.StartAsync();
using var http = new HttpClient { BaseAddress = new Uri("http://127.0.0.1:5198") };

async Task Show(string label, HttpRequestMessage req, bool withKey = true)
{
    if (withKey) req.Headers.Add("X-Api-Key", "secret");
    var res = await http.SendAsync(req);
    Console.WriteLine($"{label} -> {(int)res.StatusCode}: {await res.Content.ReadAsStringAsync()}");
}

await Show("Bài 2: GET không có key", new(HttpMethod.Get, "/api/notes/1"), withKey: false);
await Show("Bài 1: PUT /api/notes/1", new(HttpMethod.Put, "/api/notes/1") { Content = JsonContent.Create(new { text = "Đã học xong" }) });
await Show("Bài 1: GET /api/notes/1", new(HttpMethod.Get, "/api/notes/1"));
await Show("Bài 3: GET /api/notes/7", new(HttpMethod.Get, "/api/notes/7"));
await app.StopAsync();

public record Note(int Id, string Text);
public record UpdateNote(string Text);
