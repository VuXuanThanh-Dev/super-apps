# Bộ sách C# / .NET — từ cơ bản đến nâng cao

Bộ sách tiếng Việt cho lập trình viên đã biết **TypeScript** (và đang học **Java**)
muốn dùng **C#** làm backend thật: Web API, database, test, Docker.

| Tập | Nội dung | Thư mục | PDF |
|---|---|---|---|
| 1 — Cơ bản | cú pháp, kiểu, OOP, collections, exceptions, file, **C# cho Java/TS dev** | [`vol1-basics/`](vol1-basics/README.md) | `dist/csharp-tap1-co-ban.pdf` |
| 2 — Trung cấp | generics, delegates/events, LINQ, records, pattern matching, async, xUnit, DI | [`vol2-intermediate/`](vol2-intermediate/README.md) | `dist/csharp-tap2-trung-cap.pdf` |
| 3 — Nâng cao | ASP.NET Core Web API, EF Core, hiệu năng, concurrency, clean architecture, logging, Docker | [`vol3-advanced/`](vol3-advanced/README.md) | `dist/csharp-tap3-nang-cao.pdf` |

Thuật ngữ: [`GLOSSARY.md`](GLOSSARY.md) · Phiên bản công cụ: [`STACK.md`](STACK.md)

## Phiên bản (pinned)

- .NET SDK **10.0.112** (xem [`global.json`](global.json), `rollForward: latestFeature`
  → mọi SDK 10.0.x ≥ 10.0.112 đều dùng được, ví dụ 10.0.401)
- Runtime .NET **10.0.12** (LTS), C# **14**
- Chi tiết và nguồn: [`STACK.md`](STACK.md)

## Chạy toàn bộ ví dụ

```bash
cd books/csharp
./run-all.sh          # build + chạy mọi ví dụ của 3 tập + test dự án cuối
```

Hoặc từng tập:

```bash
./vol1-basics/run-examples.sh
```

Script sẽ ghi output thật vào `examples/<Project>/output.txt`, rồi
`tools/embed.py` chép code và output đó vào các chương (các marker
`<!-- include: ... -->` và `<!-- output: ... -->`).

## Build PDF

```bash
cd books/csharp/tools/pdf && npm ci && cd ../..
./tools/build-pdf.sh   # tạo dist/*.pdf và kiểm tra dấu tiếng Việt bằng pdftotext
```

## Cấu trúc một chương

Mục tiêu → Giải thích đơn giản → Ví dụ → Đi sâu → Lỗi và bẫy thường gặp →
Tóm tắt → Bài tập (có lời giải) → Nguồn tham khảo.
