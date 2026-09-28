# Tập 2 — C# Trung cấp

Tập này dạy các công cụ bạn dùng mỗi ngày khi viết code C# "thật":
generics, LINQ, async, test và dependency injection.

## Mục lục

| # | Chương | Ý chính | Ví dụ chạy được |
|---|---|---|---|
| 1 | [Generics](01-generics.md) | generic class/method, constraints, variance | `V2Ch01.Generics` |
| 2 | [Delegates, lambda và events](02-delegates-events.md) | `Func`/`Action`, lambda, closure, `event` | `V2Ch02.Delegates` |
| 3 | [LINQ](03-linq.md) | `Where`/`Select`/`GroupBy`/`Join`, deferred execution | `V2Ch03.Linq` |
| 4 | [Records và pattern matching](04-records-patterns.md) | `record`, `with`, switch expression, list/property patterns | `V2Ch04.Records` |
| 5 | [async / await](05-async.md) | `Task`, `await`, `WhenAll`, cancellation, `IAsyncEnumerable` | `V2Ch05.Async` |
| 6 | [Unit test với xUnit](06-xunit.md) | `[Fact]`, `[Theory]`, fixture, `dotnet test` | `V2Ch06.Calc`, `V2Ch06.Calc.Tests` |
| 7 | [Dependency injection](07-dependency-injection.md) | `IServiceCollection`, lifetime, options, Generic Host | `V2Ch07.DI` |

## Chạy ví dụ

```bash
cd books/csharp
./vol2-intermediate/run-examples.sh
```

## Quy ước trình bày

- Thuật ngữ tiếng Anh giữ nguyên, giải thích tiếng Việt ở lần đầu; xem thêm Glossary cuối sách.
- Code và output trong sách được chép tự động từ file thật trong `examples/` sau mỗi lần chạy.
- Kiểm tra hiển thị tiếng Việt: ắ ằ ẳ ẵ ặ ơ ư đ Ư Đ (nếu các chữ này hiện đúng, font đã đủ dấu).
