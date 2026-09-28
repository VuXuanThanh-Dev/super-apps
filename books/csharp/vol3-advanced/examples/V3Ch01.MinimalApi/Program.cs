using System.Collections.Concurrent;
using System.ComponentModel.DataAnnotations;
using System.Diagnostics;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Http.HttpResults;

var builder = WebApplication.CreateBuilder(args);
builder.Logging.SetMinimumLevel(LogLevel.Warning);   // giữ output ngắn gọn
builder.WebHost.UseUrls("http://127.0.0.1:5199");

builder.Services.AddSingleton<ProductStore>();
builder.Services.AddValidation();       // .NET 10: validate DataAnnotations trong Minimal API
builder.Services.AddProblemDetails();

var app = builder.Build();

// Middleware tự viết: đo thời gian xử lý và thêm header
app.Use(async (context, next) =>
{
    var sw = Stopwatch.StartNew();
    context.Response.OnStarting(() =>
    {
        context.Response.Headers["X-Elapsed-Ms"] = sw.ElapsedMilliseconds.ToString();
        return Task.CompletedTask;
    });
    await next(context);
});

// Endpoints
app.MapGet("/", () => "Xin chào từ ASP.NET Core!");

var products = app.MapGroup("/api/products");

products.MapGet("/", (ProductStore store, string? search, int page = 1, int pageSize = 10) =>
{
    var query = store.All();
    if (!string.IsNullOrWhiteSpace(search))
        query = query.Where(p => p.Name.Contains(search, StringComparison.OrdinalIgnoreCase));
    return TypedResults.Ok(query.Skip((page - 1) * pageSize).Take(pageSize).ToList());
});

products.MapGet("/{id:int}", Results<Ok<ProductDto>, NotFound> (int id, ProductStore store) =>
    store.Find(id) is { } p ? TypedResults.Ok(p) : TypedResults.NotFound());

products.MapPost("/", (CreateProductRequest request, ProductStore store) =>
{
    var created = store.Add(request);
    return TypedResults.Created($"/api/products/{created.Id}", created);
});

products.MapDelete("/{id:int}", Results<NoContent, NotFound> (int id, ProductStore store) =>
    store.Remove(id) ? TypedResults.NoContent() : TypedResults.NotFound());

await app.StartAsync();

// ---- Client: gọi chính API vừa chạy ----
using var http = new HttpClient { BaseAddress = new Uri("http://127.0.0.1:5199") };

async Task Show(string label, Func<Task<HttpResponseMessage>> call)
{
    var response = await call();
    var body = await response.Content.ReadAsStringAsync();
    Console.WriteLine($"{label} -> {(int)response.StatusCode} {response.StatusCode}");
    if (body.Length > 0) Console.WriteLine($"   {body}");
}

await Show("GET /", () => http.GetAsync("/"));
await Show("POST /api/products", () => http.PostAsJsonAsync("/api/products", new { name = "Bàn phím cơ", price = 1_200_000 }));
await Show("POST /api/products", () => http.PostAsJsonAsync("/api/products", new { name = "Chuột", price = 250_000 }));
await Show("POST (dữ liệu sai)", () => http.PostAsJsonAsync("/api/products", new { name = "", price = -5 }));
await Show("GET /api/products?search=bàn", () => http.GetAsync("/api/products?search=b%C3%A0n"));
await Show("GET /api/products/2", () => http.GetAsync("/api/products/2"));
await Show("GET /api/products/99", () => http.GetAsync("/api/products/99"));
await Show("GET /api/products/abc", () => http.GetAsync("/api/products/abc"));
await Show("DELETE /api/products/1", () => http.DeleteAsync("/api/products/1"));

var head = await http.GetAsync("/api/products");
Console.WriteLine($"Header X-Elapsed-Ms có mặt? {head.Headers.Contains("X-Elapsed-Ms")}");

await app.StopAsync();

// ---- Models ----
public record CreateProductRequest(
    [property: Required, StringLength(100, MinimumLength = 1)] string Name,
    [property: Range(0, 1_000_000_000)] decimal Price);

public record ProductDto(int Id, string Name, decimal Price);

public class ProductStore
{
    private readonly ConcurrentDictionary<int, ProductDto> _items = new();
    private int _nextId;

    public IEnumerable<ProductDto> All() => _items.Values.OrderBy(p => p.Id);
    public ProductDto? Find(int id) => _items.GetValueOrDefault(id);
    public bool Remove(int id) => _items.TryRemove(id, out _);

    public ProductDto Add(CreateProductRequest request)
    {
        var product = new ProductDto(Interlocked.Increment(ref _nextId), request.Name, request.Price);
        _items[product.Id] = product;
        return product;
    }
}
