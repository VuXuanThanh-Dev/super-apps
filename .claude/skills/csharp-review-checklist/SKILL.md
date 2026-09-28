---
name: csharp-review-checklist
description: C#/.NET-specific review checklist (nullable reference types, async/await and CancellationToken, IDisposable/using, DI lifetimes and captive dependencies, IHttpClientFactory, structured logging, EF Core queries, exceptions, LINQ, records, time and culture, xUnit tests) with notes for C# 14 / .NET 10. Use when reviewing, self-checking or refactoring C# code, an ASP.NET Core or EF Core diff/MR, or C# samples in the C# book, or when an agent such as code-reviewer or csharp-dotnet needs the .NET rules. Not a reviewer role by itself (verdict and merge gate stay with the code-reviewer agent), not for Java or Angular code, and not for security audits (security-reviewer agent).
---

# C# review checklist

Skill này là **kiến thức/checklist**. Agent `code-reviewer` (gác cổng merge) hoặc `csharp-dotnet`
(viết code) có thể nạp sẵn bằng `skills: [csharp-review-checklist]`. Không có agent thì main
session dùng trực tiếp.

## Steps

1. **Xác định phiên bản**: `TargetFramework` trong `.csproj`, `global.json`, `LangVersion`.
   Kiểm tra 2026-09-28: C# 14 đi kèm .NET 10 (bản phát hành mới nhất); C# 15 đang preview với .NET 11.
   Chỉ gợi ý tính năng mà phiên bản của dự án hỗ trợ.
2. **Đọc quy ước dự án**: `.editorconfig`, analyzers (`<AnalysisLevel>`, `TreatWarningsAsErrors`),
   CLAUDE.md. Quy ước dự án thắng checklist này.
3. **Đi qua checklist** [references/checklist.md](references/checklist.md): Correctness → Async →
   Resources → DI → HTTP → Logging → EF Core → Exceptions → LINQ & collections → Types →
   Time & culture → Tests.
4. **Chạy kiểm tra rẻ nếu có**: `dotnet build -warnaserror` (hoặc build thường),
   `dotnet test --filter <phần thay đổi>`, `dotnet format --verify-no-changes`. Dán output thật.
5. **Báo cáo** theo bảng dưới, mỗi dòng có mã luật (ví dụ `CS-A1`).

## Expected output

```
| # | Mức độ | File:dòng | Luật | Vấn đề | Đề xuất sửa |
|---|--------|-----------|------|--------|-------------|
| 1 | blocker | Services/OrderService.cs:42 | CS-A1 | .Result chặn thread, có thể deadlock | await + trả Task<Order> |
```
Mức độ: blocker / major / minor / nit (cùng thang với agent code-reviewer).

## Quality checklist

- [ ] Đã ghi TargetFramework/LangVersion và chỉ gợi ý tính năng hợp phiên bản.
- [ ] Mỗi phát hiện có file:dòng, mã luật, lý do, cách sửa cụ thể.
- [ ] Không trùng cảnh báo mà analyzer đã báo (trừ khi dự án tắt nhầm).
- [ ] Lệnh kiểm tra: output thật hoặc ghi rõ chưa chạy.

Nguồn: tài liệu .NET chính thức trong repo dotnet/docs — xem
[references/checklist.md](references/checklist.md#nguồn-tham-khảo-sources).
