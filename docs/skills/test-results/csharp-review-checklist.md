# Test result — `csharp-review-checklist`

- Kết quả: **PASS — Skill tool triggered**
- Loại test: **real** (headless CLI `claude -p`, stream-json), chạy lúc 2026-09-28T15:07:58Z
- CLI: `2.1.283` · thư mục test mới, có đủ 10 skill của repo
  (`angular-review-checklist, code-sample-runner, csharp-review-checklist, handbook-chapter-writer, ocp-question-writer, react-native-feature-checklist, skill-creator, vietnamese-pdf-builder, vocabulary-extractor, webapp-testing`) + 33 skill có sẵn của môi trường (built-in/plugin, ví dụ `anthropic-skills:pdf`)
- Fixture: `test-fixtures/csharp-review-checklist`
- Kết thúc: `success`, 11 turns, 63 s

## Prompt
```text
Check OrderService.cs for problems before I open the merge request. List issues with line numbers and how to fix them. Do not edit files.
```

## Bằng chứng kích hoạt (tool_use "Skill" trong stream)
```json
[
 {
  "id": "toolu_01LhDg4hMztjXGnJSsgpF7zT",
  "input": {
   "skill": "csharp-review-checklist"
  }
 }
]
```

Thứ tự tool đã gọi: `Skill → Glob → Read → Read → Glob → Glob → Read → Bash → Bash`

## File thay đổi trong thư mục test
```text
?? obj/ (build output)
```

## Câu trả lời cuối của Claude (nguyên văn)
I loaded the C#/.NET checklist and tried `dotnet build` (fails only on missing `Order`/`ShopDbContext` types that live elsewhere in the real repo — not part of this review). Project targets `net10.0` with `Nullable` enabled, no explicit `LangVersion` (defaults to C# 14).

## Findings — OrderService.cs

| # | Mức độ | File:dòng | Luật | Vấn đề | Đề xuất sửa |
|---|--------|-----------|------|--------|-------------|
| 1 | blocker | OrderService.cs:24 | CS-A2 | `SendInvoice` is `async void`, not an event handler — any exception thrown inside (including from the unguarded `.Result` on line 27) becomes unobservable/crashes the process instead of propagating to the caller. | Change signature to `public async Task SendInvoiceAsync(Order order, CancellationToken ct = default)` and have callers `await` it. |
| 2 | blocker | OrderService.cs:27 | CS-A1 | `.Result` blocks the thread on an async call; combined with `async void` this is a classic deadlock/unobserved-exception hazard, and it also sits **outside** the `try` block below, so any failure here isn't even caught by the adjacent catch. | `var response = await client.PostAsJsonAsync(..., order, ct);` inside the `try`. |
| 3 | blocker | OrderService.cs:19 | CS-E3 | `_db.Orders.ToList()` pulls the **entire** Orders table into memory before filtering with `.Where(...).FirstOrDefault()`. | `await _db.Orders.AsNoTracking().FirstOrDefaultAsync(o => o.Id == id, ct);` |
| 4 | major | OrderService.cs:17, 19 | CS-A5 / CS-E4 | `GetOrder` is synchronous and doesn't accept/pass a `CancellationToken`, blocking the calling thread on DB I/O. | Make it `public async Task<Order?> GetOrderAsync(int id, CancellationToken ct)` and use `FirstOrDefaultAsync(..., ct)`. |
| 5 | major | OrderService.cs:21 | CS-N1 | `return order!;` silently suppresses the nullable warning even though `FirstOrDefault` can legitimately return `null` — callers get a null they think can't exist. | Return `Order?` (and drop the `!`), or throw a domain exception (e.g. `KeyNotFoundException`) when not found instead of masking it. |
| 6 | major | OrderService.cs:26 | CS-H1 | `new HttpClient()` created per call — socket exhaustion / DNS-staleness risk; also bypasses any shared config (base address, retry policies). | Inject `IHttpClientFactory` (or a typed client) via constructor and use `_httpClientFactory.CreateClient("billing")`. |
| 7 | major | OrderService.cs:32-34 | CS-X1 / CS-X2 | The `try/catch` catches `Exception`, does nothing with it, and rethrows with `throw ex;`, which **destroys the original stack trace** — and it's a no-op catch that adds no value over not having it. | Either remove the try/catch entirely (let it propagate) or, if you need to log/wrap it, use `throw;` to preserve the stack trace. |
| 8 | minor | OrderService.cs:20 | CS-L1 | `_logger.LogInformation($"Loaded order {id} at {DateTime.Now}")` uses string interpolation instead of a structured message template, losing structured-logging fields. | `_logger.LogInformation("Loaded order {OrderId} at {LoadedAt}", id, DateTimeOffset.UtcNow);` |
| 9 | minor | OrderService.cs:20 | CS-C1 | `DateTime.Now` is local time and shouldn't drive business/log data; also somewhat redundant since the logger already timestamps entries. | Use `DateTimeOffset.UtcNow` (or inject `TimeProvider` per CS-C2 if this needs to be testable) — or drop the timestamp from the message entirely. |
| 10 | minor | OrderService.cs:24 | CS-N2 | No null-check on the `order` parameter before using it. | `ArgumentNullException.ThrowIfNull(order);` at the top of the method. |
| 11 | nit | OrderService.cs:4-6 | CS-T4 | Block-scoped namespace instead of file-scoped (project is on C# 14/.NET 10, which supports it). | `namespace Shop.Services;` and drop the outer braces. |

**Bottom line before opening the MR:** items 1–3 are the ones I'd block on — the `async void` + `.Result` combo (1, 2) can silently swallow exceptions or deadlock, and the `ToList()` before `Where` (3) will do a full table scan in production. 4–7 are worth fixing in the same pass since they touch the same lines. 8–11 are cheap cleanups.
