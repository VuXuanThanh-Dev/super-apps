# PLAN — Bộ sách C# / .NET (Task 4)

Branch: `task-4-csharp` · Folder: `books/csharp/` · Bắt đầu: 2026-09-28

## Mục tiêu (Goal)

Viết bộ sách tiếng Việt về C# / .NET từ cơ bản đến nâng cao cho người đã biết
TypeScript (và đang học Java), để làm backend thật (Web API, database).
Mọi ví dụ phải build và chạy được; output trong sách là output thật.

## Mục lục dự kiến (Table of contents)

### Tập 1 — Cơ bản (`vol1-basics/`)
1. Bắt đầu với .NET 10 và C# 14 (SDK, `dotnet new`, `dotnet run`, file-based app)
2. Biến, kiểu dữ liệu, toán tử, chuỗi, nullable
3. Điều kiện, vòng lặp, phương thức
4. Lập trình hướng đối tượng (class, struct, interface, kế thừa, property)
5. Collections (array, `List<T>`, `Dictionary<TKey,TValue>`, `HashSet<T>`, collection expressions)
6. Exceptions và làm việc với file
7. C# cho Java và TypeScript developer (so sánh song song)

### Tập 2 — Trung cấp (`vol2-intermediate/`)
1. Generics
2. Delegates, lambda và events
3. LINQ
4. Records và pattern matching
5. async / await
6. Unit test với xUnit
7. Dependency injection

### Tập 3 — Nâng cao (`vol3-advanced/`)
1. ASP.NET Core Web API (Minimal API)
2. EF Core với SQLite
3. Hiệu năng: `Span<T>`, bộ nhớ, BenchmarkDotNet
4. Concurrency (Task, `Parallel`, `Channel<T>`, lock)
5. Clean architecture
6. Logging và observability
7. Triển khai bằng Docker + dự án Web API hoàn chỉnh (`vol3-advanced/final-project/`)

## Milestones

| # | Nội dung | Kết quả |
|---|----------|---------|
| M1 | Nghiên cứu phiên bản C# và .NET LTS | `STACK.md`, `global.json` |
| M2 | Kế hoạch 3 tập + công cụ (script chạy ví dụ, nhúng output) | README mỗi tập, `tools/` |
| M3 | Tập 1 (gồm chương Java/TS → C#) | chương + `examples/` + output thật |
| M4 | Tập 2 | chương + `examples/` + output thật |
| M5 | Tập 3 + dự án Web API (tests, Dockerfile, README) | chương + project |
| M6 | PDF cho mỗi tập, kiểm tra dấu tiếng Việt, link checker | `dist/*.pdf` |

## Definition of Done (copy từ task)

- [ ] STACK.md and global.json with cited, pinned versions
- [ ] 3 volumes; every chapter has real output and an exercise with solution
- [ ] Java/TypeScript → C# section
- [ ] Web API project: build, tests, and Docker build pass
- [ ] 3 PDFs with correct Vietnamese accents

## Cách làm (quy ước)

- Cấu trúc chương: Mục tiêu → Giải thích đơn giản → Ví dụ → Đi sâu →
  Lỗi và bẫy thường gặp → Tóm tắt → Bài tập (có lời giải) → Nguồn tham khảo.
- Code trong sách được **nhúng từ file thật** bằng `tools/embed.py`
  (marker `<!-- include: ... -->` và `<!-- output: ... -->`), nên code và
  output trong sách luôn khớp với lần chạy thật gần nhất.
- Mỗi tập có `run-examples.sh` build + chạy toàn bộ ví dụ.
- PDF: pandoc → HTML (font Noto Serif / Noto Sans) → Chromium (Playwright) `page.pdf()`.
