# Task 1 — PROGRESS

Branch: `task-1-agents` (đúng tên trong task). PR: https://github.com/VuXuanThanh-Dev/super-apps/pull/6

## Done
- M1 Research → `docs/agents/RESEARCH.md` (định dạng chính thức, tool, model, description; bảng 5 repo).
- M2 Design → bảng thiết kế trong `docs/agents/PLAN.md` (18 agent: khi dùng / không dùng, tools, model, output).
- M3 Agent files → 18 file trong `.claude/agents/`.
  `python3 docs/agents/scripts/validate-agents.py` → `18 agent files checked, 0 error(s)`;
  `claude plugin validate .claude/agents/` → `√ Validation passed`.
- M4 Testing → `docs/agents/TESTING.md`: 18/18 PASS, test **thật** bằng `claude -p` (không phải simulated);
  kết quả nguyên văn trong `docs/agents/test-results/`; script `docs/agents/scripts/run_agent_tests.py`.
- M5 README → `docs/agents/README.md` (bảng đầy đủ + cách chọn agent).
- Link check: `docs/agents/scripts/check-links.sh` → `broken=0`.

## Next
- Không còn việc bắt buộc. Xem "Ideas for later" trong PR.

## Blockers
- Không có blocker chặn task.
- Proxy của sandbox trả 403 cho mọi trang `github.com` khi dùng curl. Tôi đã mở các trang này bằng tool WebFetch
  (ngày 2026-09-28) để lấy stars, license, ngày commit; script link check đánh dấu chúng là `BLOCKED`, không phải hỏng.

## Decisions
1. Phần thân (system prompt) viết bằng **tiếng Anh đơn giản**, output bằng **tiếng Việt** (thuật ngữ giữ tiếng Anh).
   Lý do: model làm theo chỉ dẫn tiếng Anh ổn định nhất; Nobin và team đọc được; câu trả lời vẫn là tiếng Việt.
2. `description`: "Use when…" + "Not for… (agent khác)" + 1–2 ví dụ (có tiếng Việt), ≤ 450 ký tự.
   Tổng 18 mô tả ≈ 6.500 ký tự, xa ngưỡng cảnh báo 15.000 token.
3. Không agent nào có tool `Agent` ⇒ không agent nào tự sinh agent con.
4. 7 agent chỉ đọc không có `Write`/`Edit`; script validate chặn lỗi này.
5. `claude plugin validate` rất "dễ tính" (file thiếu `name` vẫn pass — đã thử), nên script riêng của repo là kiểm tra chính.
6. Không thêm agent ngoài 18 vai trò (RESEARCH.md §4).
7. Test thật thay vì simulated: CLI headless chạy được trong sandbox; prompt test **không nêu tên agent** để kiểm tra description.
8. Sau test lần 1, sửa prompt 2 agent (`git-helper`: bắt buộc mục hoàn tác; `pr-and-commit-writer`: cấm trailer/tên model) và test lại.
