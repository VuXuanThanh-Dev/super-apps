# PROGRESS — Task 6 (skills)

Branch: `task-6-skills` (base `origin/main`). Cập nhật sau mỗi milestone.

## Done
- M0 — PLAN.md (ranh giới skill ↔ agent, danh sách skill, DoD).
- M1 — RESEARCH.md (định dạng chính thức, bảng so sánh 6 repo), `scripts/validate-skills.py`,
  `scripts/run-skill-test.sh`.

- M2 — dùng lại `webapp-testing`, `skill-creator` từ anthropics/skills@33375500 (Apache-2.0,
  giữ LICENSE.txt, dòng `> Source:` ngay sau frontmatter). Validator: 2 skills, 0 errors.
  `webapp-testing` cần Python Playwright: đã `pip install playwright==1.56.0` (khớp Chromium 1194
  có sẵn ở /opt/pw-browsers) và chạy thử OK.

- M3 — 8 skill mới: vietnamese-pdf-builder, ocp-question-writer, code-sample-runner,
  handbook-chapter-writer, angular-review-checklist, csharp-review-checklist,
  react-native-feature-checklist, vocabulary-extractor. Script trong skill đều đã chạy thử
  (xem TESTING.md phần "Script tests"). Validator: 10 skills, 0 errors.

## Next
- M4 — test headless từng skill (`docs/skills/scripts/run-skill-test.sh`), ghi TESTING.md.
- M5 — README.md + cập nhật PR.

## Blockers
- `agentskills.io` bị chặn bởi sandbox → đọc spec từ GitHub raw (cùng nội dung nguồn).
  Cần từ Nobin: không bắt buộc; nếu muốn, cho phép `agentskills.io` trong Network access.

## Decisions
- D4: `vietnamese-pdf-builder` mở sẵn mọi `<details>` khi in (Chromium ẩn nội dung details đóng →
  lời giải bài tập bị mất trong PDF; đã thử và sửa).
- D5: `vocabulary-extractor` dùng `simplemma` (MIT, offline) nếu có, không thì luật đơn giản; output theo
  đúng định dạng `word|pos|definition|example` của app TOEIC (Task 5).
- D6: Checklist skill đánh dấu [O] cho luật lấy từ tài liệu chính thức, còn lại là kinh nghiệm chung.
- D1: agent = vai trò, skill = quy trình/checklist. Bỏ `srs-to-test-cases`,
  `requirement-challenger`, `english-roleplay-coach` (trùng agent Task 1). Đổi
  angular/csharp code review + react-native-feature thành checklist agent có thể preload.
  Đổi `bilingual-handbook-writer` → `handbook-chapter-writer` (docs-writer lo tài liệu song ngữ chung).
- D2: Không copy `vercel-labs/agent-skills/react-native-skills` dù README ghi MIT: repo không có
  file LICENSE có dòng copyright để giữ lại; chỉ để link.
- D3: Test thật bằng `claude -p` headless, copy TẤT CẢ skill vào thư mục test để model phải chọn đúng.
