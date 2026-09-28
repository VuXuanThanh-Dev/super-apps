# Test result — csharp-dotnet

- Date: 2026-09-28
- Mode: real (headless `claude -p`)
- Delegated to: csharp-dotnet
- Correct agent triggered: yes
- Tools the subagent used: Bash, Edit, Read, Write

## Prompt

ReportService.cs sometimes hangs under load in our ASP.NET Core API. Fix it the right way and explain. Create a small console or xUnit project to prove the fixed code compiles.

## Result (verbatim)

The `csharp-dotnet` subagent finished. Here is its full report, unchanged:

---

### Kế hoạch
1. Đọc `ReportService.cs` để xác định nguyên nhân gốc gây hang khi tải cao.
2. Sửa bằng cách chuyển hoàn toàn sang async, bỏ `.Result`.
3. Giải thích rõ cơ chế hang và lý do fix hoạt động.
4. Tạo project console độc lập compile trực tiếp file đã sửa (`<Compile Include="../ReportService.cs">`), build và chạy thực nghiệm so sánh trước/sau dưới tải giả lập.

### Thay đổi (file — lý do)
- `/tmp/claude-0/-home-user-super-apps/dc3b63d6-198e-59e3-b3c8-1c8b388a1027/scratchpad/agent-tests/csharp-dotnet/ReportService.cs` — nguyên nhân gốc: `GetReport` gọi `_http.GetStringAsync(...).Result`, tức là **sync-over-async** (chặn một thread pool thread để chờ một Task I/O-bound hoàn thành đồng bộ). Đã sửa thành `GetReportAsync(int id, CancellationToken)` dùng `await ... ConfigureAwait(false)`, async xuyên suốt, có `CancellationToken` để hủy khi caller hủy request.
- `/tmp/claude-0/-home-user-super-apps/dc3b63d6-198e-59e3-b3c8-1c8b388a1027/scratchpad/agent-tests/csharp-dotnet/demo/Demo.csproj` — project console mới (net10.0), `<Compile Include="../ReportService.cs">` để build trực tiếp file production thật (không phải bản copy).
- `/tmp/claude-0/-home-user-super-apps/dc3b63d6-198e-59e3-b3c8-1c8b388a1027/scratchpad/agent-tests/csharp-dotnet/demo/Program.cs` — harness thực nghiệm: giả lập API chậm bằng `HttpMessageHandler` tùy chỉnh (`Task.Delay`, không block), ép `ThreadPool.SetMinThreads(2,2)` để mô phỏng app vừa khởi động gặp burst traffic, chạy 300 request đồng thời ở 2 mode: `old` (tái hiện bug `.Result` gốc, chỉ để so sánh — không sửa lại `ReportService.cs`) và `new` (gọi thẳng `ReportService.GetReportAsync` đã fix). Có watchdog chạy trên một `Thread` OS thật (không phải thread pool) để force-exit nếu bị hang, vì nếu dùng `Task.Delay` làm watchdog thì bản thân nó cũng bị đói thread pool.

### Chẩn đoán nguyên nhân gốc
Đây **không phải** deadlock kiểu ASP.NET Framework cổ điển (SynchronizationContext bị chiếm giữ) — Kestrel/ASP.NET Core không có `SynchronizationContext` mặc định. Nguyên nhân thực sự ở đây là **thread pool starvation do sync-over-async**:

- `GetReport` gọi `.Result` trên một `Task` I/O-bound. Việc này **chặn cứng** thread pool thread đang thực thi request đó cho tới khi HTTP call trả về.
- Khi request đó hoàn thành (I/O xong), continuation cần một thread pool thread khác để chạy tiếp và set kết quả cho Task — đây cũng là tài nguyên **giống hệt** loại thread đang bị block ở `.Result`.
- Ở tải thấp: pool có sẵn đủ thread rảnh, continuation chạy ngay, `.Result` trả về nhanh, không ai nhận ra vấn đề.
- Ở tải cao: nhiều request đồng thời cùng gọi `.Result` → nhiều thread bị chặn cùng lúc. .NET ThreadPool không tạo thread mới ngay lập tức khi thiếu — nó dùng thuật toán "hill climbing", chỉ bơm thêm khoảng 1 thread mỗi ~500ms (khi phát hiện có việc bị đói). Nếu tốc độ request mới > tốc độ pool có thể bơm thêm thread, số thread bị `.Result` giữ chặt cứ tăng dần, trong khi continuation của chính các Task đó cũng phải xếp hàng chờ thread → vòng xoáy tự làm đói (self-reinforcing), request cứ dồn ứ, timeout hàng loạt hoặc treo hẳn. Đó là lý do bug chỉ lộ **"dưới tải"**, không phải luôn luôn.

### Kiểm tra đã chạy (lệnh → kết quả thật)
```
$ cd demo && dotnet build
Demo -> .../demo/bin/Debug/net10.0/Demo.dll
Build succeeded.
    0 Warning(s)
    0 Error(s)

$ dotnet exec bin/Debug/net10.0/Demo.dll old
Mode: old. ThreadPool min threads: 2/2. Simulated I/O latency: 250ms. Concurrency: 300. Watchdog: 6s.

WATCHDOG: no result after 6s -> HUNG under load (thread-pool starvation).
exit code: 2

$ dotnet exec bin/Debug/net10.0/Demo.dll new
Mode: new. ThreadPool min threads: 2/2. Simulated I/O latency: 250ms. Concurrency: 300. Watchdog: 6s.

Completed 300 concurrent calls in 327ms (ideal ~250ms if truly non-blocking).
exit code: 0

(re-run twice for consistency: 284ms, 282ms — stable, no hang)
```
Bản `old` (tái hiện code gốc dùng `.Result`) treo thật sự dưới cùng điều kiện tải giả lập (watchdog phải force-kill sau 6s). Bản `new` (chính file `ReportService.cs` đã sửa, compile trực tiếp qua `<Compile Include>`) hoàn thành 300 cuộc gọi đồng thời trong ~280-330ms, gần bằng đúng 1 round-trip I/O (250ms) — chứng minh không có thread nào bị giữ chặt trong lúc chờ.

### So sánh với TypeScript/Java (nếu hữu ích)
- TypeScript/Node.js: I/O luôn non-blocking qua event loop, không có khái niệm "thread pool bị chặn bởi await" — đây là lớp bug đặc thù của môi trường có thread pool dùng chung như .NET/JVM.
- Java tương đương: gọi `future.get()` (blocking) trên một `CompletableFuture` I/O-bound bên trong một thread từ `ForkJoinPool.commonPool()` hoặc thread pool của server (Tomcat/Netty) gây đúng hiện tượng tương tự — cạn pool khi tải cao. Cách khắc phục trong Java cũng giống hệt: dùng non-blocking API xuyên suốt (`thenCompose`, reactive `Mono`/`Flux`, hoặc `async`/`await`-style với Kotlin coroutines) thay vì `.get()`/`.join()`.
- `ConfigureAwait(false)` ở đây tương tự việc không cố tình "quay lại" một context/executor cụ thể khi resume — trong code thư viện không phụ thuộc UI/request context, luôn nên dùng nó (dù trong ASP.NET Core hiện đại không có SynchronizationContext nên tác dụng chính là tối ưu, không phải chống deadlock).

### Việc còn lại
- Controller gọi `ReportService` cần được cập nhật thành action `async Task<IActionResult>` gọi `await service.GetReportAsync(id, cancellationToken)` (không có trong phạm vi file được cung cấp, nhưng comment đầu file đã ghi rõ cách gọi mới).
- Nếu muốn chứng minh thêm bằng xUnit thay vì console app, có thể bổ sung project test riêng dùng `WebApplicationFactory` khi có toàn bộ solution ASP.NET Core thật (hiện tại chỉ có 1 file `.cs` lẻ, không có `.csproj`/`.sln` gốc nào để soi theo style sẵn có).
