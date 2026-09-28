# C# / .NET checklist (mã luật)

Viết lại bằng lời của mình. **[O]** = có trong tài liệu chính thức của .NET (xem Nguồn); luật không có
[O] là kinh nghiệm thực hành chung (thường mức minor/ý kiến nếu dự án không có quy ước khác).

## N — Correctness & nullability
- **CS-N1** Bật `<Nullable>enable</Nullable>`; không dùng `!` (null-forgiving) để "tắt" cảnh báo mà không có lý do.
- **CS-N2** Kiểm tra tham số public: `ArgumentNullException.ThrowIfNull(x)`, `ArgumentException.ThrowIfNullOrEmpty(s)`.
- **CS-N3** So sánh chuỗi chỉ định rõ `StringComparison` (`Ordinal`/`OrdinalIgnoreCase` cho khoá, mã).

## A — Async
- **CS-A1** [O] Không chặn bằng `.Result` / `.Wait()` trong code async; "async all the way".
- **CS-A2** [O] `async void` chỉ cho event handler; còn lại trả `Task`/`Task<T>`.
- **CS-A3** [O] Method async có hậu tố `Async`.
- **CS-A4** [O] Thư viện (không phải app) cân nhắc `ConfigureAwait(false)`.
- **CS-A5** Nhận và truyền `CancellationToken` xuyên suốt (controller → service → EF Core/HttpClient).
- **CS-A6** [O] Cẩn thận lambda async trong LINQ (thực thi trễ); chờ nhiều task bằng `Task.WhenAll`.

## R — Resources
- **CS-R1** [O] Đối tượng `IDisposable`/`IAsyncDisposable` do mình tạo phải `using`/`await using`.
- **CS-R2** [O] Không tự Dispose service do DI container tạo; container lo việc đó.

## D — Dependency injection
- **CS-D1** [O] Không có captive dependency: singleton không được giữ service scoped/transient.
- **CS-D2** [O] Không resolve service scoped từ root provider; dùng `IServiceScopeFactory.CreateScope()` trong background service.
- **CS-D3** [O] Tránh factory DI async (`.Result` trong factory) → nguy cơ deadlock.
- **CS-D5** [O] Tránh service locator (`GetService` rải rác) và `BuildServiceProvider()` khi đăng ký service.
- **CS-D4** [O] Service singleton phải thread-safe (không field trạng thái thay đổi mà không khoá).

## H — HTTP
- **CS-H1** [O] Dùng `IHttpClientFactory` (named/typed client), không `new HttpClient()` trong mỗi request.
- **CS-H2** [O] Không giữ typed client trong singleton (client bị "captive", không nhận thay đổi DNS).

## L — Logging
- **CS-L1** [O] Không dùng string interpolation trong log; dùng message template `"Order {OrderId} created"`.
- **CS-L2** [O] Đường nóng (hot path): logging source generator (`[LoggerMessage]`).
- **CS-L3** Không log dữ liệu nhạy cảm (mật khẩu, token, số thẻ).

## E — EF Core
- **CS-E1** Truy vấn chỉ đọc: `AsNoTracking()` hoặc projection `Select` sang DTO.
- **CS-E2** Tránh N+1: `Include`/projection thay vì truy cập navigation trong vòng lặp.
- **CS-E3** Không gọi `ToList()` trước `Where`/`Skip`/`Take` (kéo cả bảng về bộ nhớ).
- **CS-E4** Dùng method async (`ToListAsync`, `SaveChangesAsync`) với `CancellationToken`.
- **CS-E5** Không trả entity ra API; trả DTO/record.

## X — Exceptions
- **CS-X1** Chỉ bắt exception mà mình xử lý được; không `catch (Exception) {}` rỗng.
- **CS-X2** Ném lại bằng `throw;` (giữ stack trace), không `throw ex;`.
- **CS-X3** ASP.NET Core: xử lý lỗi tập trung (ProblemDetails / exception handler), không try/catch mọi action.

## Q — LINQ & collections
- **CS-Q1** Không liệt kê `IEnumerable` nhiều lần (gọi `Count()` rồi `foreach`); materialize một lần nếu cần.
- **CS-Q2** [O] Khởi tạo collection bằng collection expression (`[1, 2, 3]`) khi dự án dùng C# 12+.

## T — Types & language
- **CS-T1** DTO/giá trị bất biến: `record` hoặc `init`; không public setter khi không cần.
- **CS-T2** [O] Dùng `var` khi kiểu hiển nhiên từ vế phải; ghi rõ kiểu khi không hiển nhiên.
- **CS-T3** [O] C# 14 (.NET 10): có `field` keyword, extension members, null-conditional assignment —
  chỉ gợi ý khi dự án dùng .NET 10+/C# 14.
- **CS-T4** [O] File-scoped namespace; `using` đặt ngoài namespace.

## C — Time & culture
- **CS-C1** Dùng `DateTimeOffset`/UTC cho thời điểm; không `DateTime.Now` trong logic nghiệp vụ.
- **CS-C2** [O] Code cần test thời gian: inject `TimeProvider` (test bằng `FakeTimeProvider`).
- **CS-C3** Parse/format số, ngày cho máy đọc dùng `CultureInfo.InvariantCulture`.

## S — Tests
- **CS-S1** Logic mới có test (xUnit/NUnit/MSTest theo dự án); tên test mô tả hành vi.
- **CS-S2** Test không phụ thuộc giờ máy, thứ tự chạy, mạng thật.

## Nguồn tham khảo (Sources)
Repo dotnet/docs, commit `e7624b3` (mở 2026-09-28; learn.microsoft.com bị chặn trong sandbox):
- C# coding conventions: https://github.com/dotnet/docs/blob/e7624b3a05febc0a5e6427a484de1aec9efc1c5e/docs/csharp/fundamentals/coding-style/coding-conventions.md
- Async scenarios & considerations: https://github.com/dotnet/docs/blob/e7624b3a05febc0a5e6427a484de1aec9efc1c5e/docs/csharp/asynchronous-programming/async-scenarios.md
- DI guidelines (captive dependency, disposal, async factory): https://github.com/dotnet/docs/blob/e7624b3a05febc0a5e6427a484de1aec9efc1c5e/docs/core/extensions/dependency-injection/guidelines.md
- IHttpClientFactory: https://github.com/dotnet/docs/blob/e7624b3a05febc0a5e6427a484de1aec9efc1c5e/docs/core/extensions/httpclient-factory.md
- Logging library guidance (no string interpolation): https://github.com/dotnet/docs/blob/e7624b3a05febc0a5e6427a484de1aec9efc1c5e/docs/core/extensions/logging/library-guidance.md
- Logging source generation: https://github.com/dotnet/docs/blob/e7624b3a05febc0a5e6427a484de1aec9efc1c5e/docs/core/extensions/logging/source-generation.md
- TimeProvider testing: https://github.com/dotnet/docs/blob/e7624b3a05febc0a5e6427a484de1aec9efc1c5e/docs/core/extensions/timeprovider-testing.md
- What's new in C# 14: https://github.com/dotnet/docs/blob/e7624b3a05febc0a5e6427a484de1aec9efc1c5e/docs/csharp/whats-new/csharp-14.md ; C# 15 (preview): https://github.com/dotnet/docs/blob/e7624b3a05febc0a5e6427a484de1aec9efc1c5e/docs/csharp/whats-new/csharp-15.md
