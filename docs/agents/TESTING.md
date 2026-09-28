# TESTING — 18 subagent (M4)

## Cách test (tất cả là test THẬT, không có "simulated")

- Công cụ: CLI Claude Code chạy headless (`claude -p`), phiên bản `2.1.283 (Claude Code)`, ngày 2026-09-28.
- Script: `docs/agents/scripts/run_agent_tests.py`. Với mỗi agent, script:
  1. tạo thư mục làm việc mới **ngoài repo**, copy `.claude/agents/` và file mẫu từ `docs/agents/samples/`, `git init`;
  2. gửi prompt **không nêu tên agent**, chỉ dặn: "Delegate this task to the single most suitable project subagent";
  3. đọc transcript `stream-json` để biết agent nào được gọi (tool `Agent`, trường `subagent_type`) và subagent đã dùng những tool nào;
  4. ghi kết quả nguyên văn vào `docs/agents/test-results/<agent>.md` (đường dẫn tạm đã được thay bằng `<workdir>`).
- Ngoại lệ: `english-coach` cần nhiều lượt hội thoại, nên chạy thành agent chính (`--agent english-coach`, các lượt sau dùng `-c`).
  Test này kiểm tra hành vi "chỉ sửa lỗi khi hết cảnh", không kiểm tra việc tự chọn agent.
- Tiêu chí PASS:
  (a) đúng agent được kích hoạt từ `description`;
  (b) subagent chỉ dùng tool trong `tools:` của nó;
  (c) output theo đúng khuôn mẫu và đạt "Done means" của agent;
  (d) nội dung đúng về chuyên môn (tôi đọc và kiểm tra lại từng kết quả).

Kiểm tra (b) bằng script (đối chiếu "Tools the subagent used" với frontmatter), kết quả thật:

```text
angular-expert OK []            ba-requirements-challenger OK []   code-reviewer OK []
csharp-dotnet OK []             database-designer OK []            debugger OK []
devops-ci OK []                 docs-writer OK []                  english-coach OK []
estimation-and-planning OK []   git-helper OK []                   intern-mentor OK []
java-spring-backend OK []       performance-optimizer OK []        pr-and-commit-writer OK []
react-native-mobile OK []       security-reviewer OK []            test-case-writer OK []
```

## Kết quả

| # | Agent | Mẫu test (sample) | Kích hoạt đúng? | Tool đã dùng | Nhận xét (đã kiểm tra) | Kết quả |
|---|---|---|---|---|---|---|
| 1 | code-reviewer | `samples/review/add-user-search.diff` (diff Angular có cài bẫy) | ✅ | Bash, Read | Verdict REQUEST CHANGES; bắt đủ các lỗi đã cài: `@if (users.length = 0)` (gán thay vì so sánh), nested subscribe/race, leak, URL không encode, `[innerHTML]`, `getAge` sai, `any`, thiếu test; mỗi finding có file:dòng + cách sửa; ghi rõ lint/test "không chạy" và vì sao | PASS |
| 2 | angular-expert | `samples/angular/legacy-counter.component.ts` | ✅ | Bash, Edit, Glob, Read, Write | Ra component standalone, `input()`/`output()`, `signal`/`computed`, `@if/@for` có `track`, `takeUntilDestroyed`. **Tôi kiểm tra thêm:** type-check file kết quả với `@angular/core@22.2.0` thật + TypeScript strict → `TSC OK (Angular 22.2.0)` | PASS |
| 3 | java-spring-backend | `samples/java/OrderService.java` | ✅ | Bash, Edit, Read, WebFetch | Chỉ đúng nguyên nhân: `@Transactional` trên method `private` + self-invocation không đi qua proxy; sửa bằng cách đặt `@Transactional` lên method public; không bịa kết quả build vì không có `pom.xml` | PASS |
| 4 | csharp-dotnet | `samples/csharp/ReportService.cs` | ✅ | Bash, Edit, Read, Write | Chẩn đoán thread-pool starvation do sync-over-async (`.Result`) chứ không phải deadlock SynchronizationContext kiểu cũ; sửa thành `GetReportAsync` + `CancellationToken`; tự tạo project demo, `dotnet build` 0 warning; demo thật: bản cũ treo, bản mới xong 300 lời gọi trong ~280–330 ms | PASS |
| 5 | react-native-mobile | `samples/react-native/ContactList.tsx` | ✅ | Bash, Read, Write | `FlatList` + `keyExtractor`; phát hiện thêm lỗi `useEffect` không có dependency array (gọi `load()` liên tục). Lưu ý: agent type-check với `react-native@0.74` cũ trong thư mục tạm, không phải bản mới nhất | PASS (ghi chú) |
| 6 | database-designer | Mô tả nghiệp vụ phòng họp (tiếng Việt) | ✅ | (không cần tool) | Quy tắc nghiệp vụ → ràng buộc; chống trùng lịch bằng `EXCLUDE USING gist (room_id WITH =, period WITH &&)`, range `[start,end)`; nêu rõ quy tắc cần trigger (số người ≤ sức chứa); có ERD, DDL, index + lý do | PASS |
| 7 | ba-requirements-challenger | `samples/srs/leave-request-srs.md` (SRS có cài lỗ hổng) | ✅ | Read | Bắt được các mâu thuẫn đã cài (FR-1↔FR-2 về reason, BR-2↔FR-7 về đơn đang chờ duyệt, FR-5↔FR-8 về HR), từ mơ hồ ("etc.", "appropriate time", "fast"), thiếu trạng thái, ngày lễ, nửa ngày, NFR; có câu hỏi tiếng Anh gửi BA | PASS |
| 8 | test-case-writer | cùng SRS, mục 3.1 + BR-1, BR-2 | ✅ | Read | Bảng test case có trace tới FR/BR, positive/negative/boundary, ma trận truy vết | PASS |
| 9 | security-reviewer | `samples/security/UserController.java` | ✅ | Bash, Glob, Read | Bắt đủ: SQL injection (CWE-89), secret hardcode (CWE-798), XSS khi tự ghép HTML (CWE-79), IDOR ở `/salary` (CWE-639), CORS `*` + credentials; mỗi lỗi có kịch bản tấn công; `JWT_SECRET` không dùng → đưa vào "Cần xác minh"; không sửa file | PASS |
| 10 | debugger | `samples/debug/PriceCalculator*.java` | ✅ | Bash, Edit, Read | Tái hiện lỗi thật (`expected 170.0 but was 200.0`), nguyên nhân gốc: chia số nguyên `percent / 100`, sửa `100.0`, chạy lại → `PASS` | PASS |
| 11 | performance-optimizer | `samples/perf/find-duplicates.js` + `bench.js` | ✅ | Bash, Edit, Read, Write | Đo thật trước/sau: 8354.3 ms → 13–21 ms (N=20000), cùng 500 kết quả; O(n²) → O(n) bằng `Map`; so sánh output với bản cũ trên 6 case | PASS |
| 12 | git-helper | Repo tạm có merge conflict thật ở `price.js` | ✅ | Bash, Edit, Read | Lần 1: gộp đúng (VAT 0.08 + DISCOUNT) nhưng thiếu mục "Cách hoàn tác". Đã sửa prompt (bắt buộc undo + backup branch) và chạy lại: có đủ 4 mục + lệnh undo. Còn thiếu: chưa tạo backup branch (quy tắc chỉ bắt buộc với rebase/reset/force-push nên không tính là lỗi) | PASS (lần 2) |
| 13 | devops-ci | `samples/node-app/` | ✅ | Bash, Edit, Read, WebFetch, Write | Tạo `.gitlab-ci.yml` + Dockerfile multi-stage non-root; parse YAML OK; `docker build` và `docker run` thật (container `healthy`, `/health` → 200); ghi rõ phần không verify được (docs.gitlab.com bị chặn) | PASS |
| 14 | docs-writer | `samples/node-app/` | ✅ | Glob, Read, Write | README song ngữ dựa trên file thật; phiên bản Node không có trong repo → ghi **UNVERIFIED** thay vì bịa | PASS |
| 15 | pr-and-commit-writer | Repo tạm có thay đổi đã `git add` (endpoint `/version`) | ✅ | Bash, Read | Lần 1: nội dung đúng, nhưng tự thêm trailer ghi tên model AI. Đã sửa prompt (cấm trailer nếu repo không dùng) và chạy lại: commit `feat(api): add /version endpoint` + mô tả MR sạch | PASS (lần 2) |
| 16 | estimation-and-planning | `samples/srs/leave-request-srs.md`, team 2 FE + 1 BE + 1 QA | ✅ | Glob, Read | WBS theo layer, O/M/P, Expected = (O+4M+P)/6 (kiểm tra tay: SH-1 (0.5+4+2)/6 = 1.08 ✓; SH-7 (1+8+3)/6 = 2.00 ✓), có giả định và rủi ro | PASS |
| 17 | intern-mentor | `samples/mentor/search.component.ts` | ✅ | Glob, Grep, Read | Đúng thứ tự Ý tưởng đơn giản → Ví dụ → Đi sâu (switchMap vs mergeMap) → Góp ý → Bài tập → Lời giải | PASS |
| 18 | english-coach | Roleplay daily stand-up, 4 lượt (câu có lỗi cố ý) | ✅ (gọi bằng `--agent`) | (không cần tool) | Trong cảnh **không sửa lỗi**, chỉ đóng vai Sarah; khi "end scene" mới ra bảng sửa 4 câu thật của người dùng, 5 cụm từ hữu ích, IPA | PASS |

**Tổng kết: 18/18 PASS** (2 agent pass ở lần 2 sau khi sửa prompt; 1 agent có ghi chú).
Mọi kết quả nguyên văn: `docs/agents/test-results/`.

## Những điều test KHÔNG chứng minh

- Mỗi agent chỉ test **1 lần** trên mẫu nhỏ. Model có tính ngẫu nhiên; kết quả trên dự án thật có thể khác.
- Mẫu không phải dự án đầy đủ (không có `package.json`/`pom.xml`...), nên các agent code không chạy được build/test của dự án.
  Đó là hành vi đúng: agent nói rõ "không chạy vì…" thay vì bịa.
- Việc tự chọn agent được test với câu dặn "delegate to the most suitable subagent". Khi bạn không dặn gì, Claude có thể tự làm
  thay vì giao việc. Muốn chắc chắn, hãy gọi tên agent (xem README).

## Chạy lại

```bash
python3 docs/agents/scripts/run_agent_tests.py                 # cả 18 (tốn token, ~15–20 phút với 4 luồng)
python3 docs/agents/scripts/run_agent_tests.py debugger        # 1 agent
```
