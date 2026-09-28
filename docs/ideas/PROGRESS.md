# PROGRESS — Task 7 (docs/ideas)

Branch: `task-7-ideas` (đúng tên trong task). Cập nhật: 2026-09-28.

## Done

- M1: `PLAN.md` (commit + push).
- M2: Research. Số liệu GitHub (stars, pushed_at, license) lấy qua GitHub search API; README/LICENSE đọc qua raw.githubusercontent.com; npm version qua `npm view`.
- M3: `IDEAS.md` — 4 phần, 47 mục (15 + 12 + 11 + 9), đủ field, Top 10 ở đầu.
  Kiểm tra bằng script Python: Ratio = Value ÷ Effort đúng cho mọi dòng, mỗi phần sắp xếp giảm dần, bảng khớp với phần chi tiết, không mục nào thiếu field.
- Thử thật cspell + `@cspell/dict-vi-vn` trong scratchpad (không cài vào repo). Output thật được dán trong mục 2.6.
- M4: Link check (curl) + PR.

## Link check (curl, 2026-09-28)

58 URL duy nhất trong IDEAS.md.

| Nhóm | Số lượng | Kết quả |
|------|----------|---------|
| code.claude.com | 1 | 200 OK |
| github.com (trang repo) | 44 | curl bị sandbox chặn (403). Cả 44 repo đều tồn tại — xác nhận qua GitHub search API cùng ngày. |
| github.com (blob/tree) | 8 | 1 trả 200 trực tiếp; 7 bị curl chặn (403). File tương ứng trên raw.githubusercontent.com trả về 200 cho cả 8 |
| Host bị sandbox chặn | 4 | wiley.com, ets.org, education.oracle.com, omscs.gatech.edu — **blocked by sandbox, not broken**; đã ghi UNVERIFIED |
| api.githubcopilot.com/mcp/ | 1 | Endpoint MCP, không phải trang web — không cần check |

**Link hỏng thật (404): 0.**

## Next

- Nobin review PR. Nếu đồng ý, làm các workflow ở Phần 2 trong một task riêng (task này không được tạo file trong `.github/`).

## Blockers

- Nhiều trang chính thức bị egress proxy chặn (xem cuối IDEAS.md). Đã thử curl và WebFetch, cả hai đều bị chặn.
  **Cần từ Nobin:** cho phép các host này trong Network access của environment nếu muốn kiểm chứng giá/định dạng đề thi:
  ets.org, etsglobal.org, education.oracle.com, enthuware.com, wiley.com, apps.ankiweb.net, jetbrains.com, omscs.gatech.edu, docs.github.com, docs.expo.dev.
- `curl` tới `api.github.com` bị từ chối; dùng GitHub MCP tools thay thế.

## Decisions

1. Nguồn ưu tiên là repo GitHub chính thức, vì hầu hết trang chính thức bị chặn. Với GitHub billing và Dependabot, dùng file docs gốc trong repo `github/docs`.
2. Thông tin chỉ thấy qua WebSearch (đề OCP, đề TOEIC, giá OMSCS, sách OCP, IntelliJ free) → ghi **UNVERIFIED**, không coi là đã kiểm chứng.
3. "Last commit" = `pushed_at` của GitHub API (lần push gần nhất lên repo).
4. Effort S/M/L lấy từ điểm Effort: S = 1–2, M = 3, L = 4–5.
5. Top 10 không chỉ lấy 10 Ratio cao nhất: yêu cầu Value ≥ 4 và phủ cả 4 phần. Có 5 mục cùng Ratio 2.50; chọn 2 mục nối trực tiếp với repo (test code mẫu, Anki deck từ GLOSSARY).
6. genanki không đạt tiêu chí "reputable" (commit cuối 2024-12-30) → đề xuất CSV import có sẵn của Anki làm cách chính.
7. YAML trong Phần 2 chỉ là gợi ý, chưa chạy trên GitHub; version tag trong snippet 2.5 ghi UNVERIFIED.
