# Task 1 — PROGRESS

Branch: `task-1-agents` (đúng tên trong task).

## Done
- M1 Research → `docs/agents/RESEARCH.md` (định dạng chính thức, tool, model, description; bảng 5 repo).
- M2 Design → bảng thiết kế trong `docs/agents/PLAN.md` (18 agent, khi dùng / không dùng, tools, model, output).
- M3 Agent files → 18 file trong `.claude/agents/`; script `docs/agents/scripts/validate-agents.py`
  → `18 agent files checked, 0 error(s)`; `claude plugin validate .claude/agents/` → `√ Validation passed`.

## Next
- M4 Testing → `docs/agents/TESTING.md` + mẫu trong `docs/agents/samples/`.
- M5 README → `docs/agents/README.md`.

## Blockers
- Agent mới không gọi được trong phiên này: thư mục `.claude/agents/` chưa tồn tại lúc phiên bắt đầu,
  docs chính thức nói phải khởi động lại phiên. ⇒ Test M4 sẽ là "simulated" (tôi tự làm theo đúng hướng dẫn
  của agent, chỉ dùng đúng tools của agent đó).

## Decisions
1. Phần thân (system prompt) viết bằng **tiếng Anh đơn giản**, output bằng **tiếng Việt** (thuật ngữ giữ tiếng Anh).
   Lý do: model làm theo chỉ dẫn tiếng Anh ổn định nhất; Nobin và team đọc được; câu trả lời vẫn là tiếng Việt.
2. `description`: "Use when…" + "Not for… (agent khác)" + 1–2 ví dụ (có tiếng Việt), ≤ 450 ký tự.
   Tổng 18 mô tả ≈ 6.500 ký tự, xa ngưỡng cảnh báo 15.000 token.
3. Không agent nào có tool `Agent` ⇒ không agent nào tự sinh agent con.
4. Agent chỉ đọc (7 agent) không có `Write`/`Edit`; script validate chặn lỗi này.
5. `claude plugin validate` rất "dễ tính" (file thiếu `name` vẫn pass — đã thử trong scratchpad), nên
   script riêng của repo mới là kiểm tra chính.
6. Không thêm agent ngoài 18 vai trò (xem RESEARCH.md §4).
