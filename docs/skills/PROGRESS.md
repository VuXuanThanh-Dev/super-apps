# PROGRESS — Task 6 (skills)

Branch: `task-6-skills` (base `origin/main`). Cập nhật sau mỗi milestone.

## Done
- M0 — PLAN.md (ranh giới skill ↔ agent, danh sách skill, DoD).
- M1 — RESEARCH.md (định dạng chính thức, bảng so sánh 6 repo), `scripts/validate-skills.py`,
  `scripts/run-skill-test.sh`.

## Next
- M2 — dùng lại `webapp-testing`, `skill-creator` (Apache-2.0).
- M3 — 8 skill mới. M4 — test headless. M5 — README + PR.

## Blockers
- `agentskills.io` bị chặn bởi sandbox → đọc spec từ GitHub raw (cùng nội dung nguồn).
  Cần từ Nobin: không bắt buộc; nếu muốn, cho phép `agentskills.io` trong Network access.

## Decisions
- D1: agent = vai trò, skill = quy trình/checklist. Bỏ `srs-to-test-cases`,
  `requirement-challenger`, `english-roleplay-coach` (trùng agent Task 1). Đổi
  angular/csharp code review + react-native-feature thành checklist agent có thể preload.
  Đổi `bilingual-handbook-writer` → `handbook-chapter-writer` (docs-writer lo tài liệu song ngữ chung).
- D2: Không copy `vercel-labs/agent-skills/react-native-skills` dù README ghi MIT: repo không có
  file LICENSE có dòng copyright để giữ lại; chỉ để link.
- D3: Test thật bằng `claude -p` headless, copy TẤT CẢ skill vào thư mục test để model phải chọn đúng.
