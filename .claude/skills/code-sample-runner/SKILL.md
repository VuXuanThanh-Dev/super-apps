---
name: code-sample-runner
description: Run the code samples inside Markdown docs, books or READMEs (Java 21, C# file-based .NET 10, TypeScript, JavaScript, Python, Bash) and paste their REAL output under each sample, or mark them "NOT RUN" when a tool is missing. Use when asked to run, check or refresh code examples in documentation, to "paste the real output", or before publishing a chapter or README that contains code. Not for OCP practice questions (use ocp-question-writer), not for app unit tests or CI, and not for debugging application code (debugger agent).
compatibility: Uses whichever of javac/java 21, dotnet 10, node with built-in type stripping (tested v22.22.2), python3, bash are installed; Python 3.10+ for the script.
---

# Code sample runner

Luật: **mọi code mẫu phải chạy được và output dán vào là output thật**. Không tự viết output.

## Steps

1. **Dùng runner có sẵn của dự án trước.** Ví dụ: sách OCP `python3 tools/book.py examples`,
   sách C# `tools/run-examples.sh` + `tools/embed.py`. Chỉ dùng script của skill khi dự án chưa có.
2. **Đánh dấu mẫu cần chạy** trong Markdown (comment HTML không hiện khi render/PDF):
   ````markdown
   <!-- run -->
   ```java
   public class Hello { public static void main(String[] a) { System.out.println("hi"); } }
   ```
   ````
   Mẫu cố ý lỗi (minh hoạ lỗi biên dịch/exception): `<!-- run: expect-fail -->`.
   Đoạn code chỉ là trích đoạn (không chạy riêng được) thì **không** đánh dấu; nếu cần,
   tách thành file đầy đủ trong `examples/` và chạy ở đó.
3. **Chạy và dán output**:
   ```bash
   python3 ${CLAUDE_SKILL_DIR}/scripts/run_samples.py docs/chapter.md [more.md ...]
   ```
   Script thêm/thay khối `<!-- output -->` + ```` ```text ```` ngay sau mỗi mẫu.
4. **Đọc kết quả**: exit 0 = mọi mẫu OK; 1 = có mẫu lỗi (in lỗi thật) → sửa code mẫu rồi chạy lại;
   3 = có mẫu "NOT RUN" (thiếu công cụ) → ghi vào Blockers, không xoá chữ NOT RUN.
5. **Trong CI / trước khi merge**: `run_samples.py --check file.md` → exit 1 nếu output trong file
   đã cũ so với output thật.
6. Ghi phiên bản công cụ (`java -version`, `dotnet --version`, `node --version`) vào README của dự án.

## Expected output

- File Markdown đã cập nhật, mỗi mẫu có khối output thật.
- Dòng tóm tắt thật của script, ví dụ:
  `docs/chapter.md: ok=4 failed=0 not_run=0 updated=4`

## Quality checklist

- [ ] `--check` trả exit 0 sau khi chạy.
- [ ] Không có output viết tay; mẫu không chạy được đều ghi "NOT RUN: … not found" + Blocker.
- [ ] Output không phụ thuộc thời gian/locale/máy (script đặt `TZ=UTC`, `LANG=C.UTF-8`);
      nếu vẫn phụ thuộc (ngày giờ, số ngẫu nhiên), sửa mẫu cho ổn định.
- [ ] Mẫu `expect-fail` thực sự thất bại vì đúng lý do đang minh hoạ.

## Notes

- Java: `javac --release 21`, lớp đầu tiên khai báo trong khối là lớp chạy.
- C#: `dotnet run sample.cs` (file-based app, .NET 10+). TypeScript: Node có type stripping mặc định (đã thử: v22.22.2) tự bỏ kiểu
  (type stripping) — chỉ kiểm tra chạy, **không** kiểm tra kiểu; cần kiểm tra kiểu thì dùng `tsc`.
- Ví dụ mẫu: [assets/sample.md](assets/sample.md).
