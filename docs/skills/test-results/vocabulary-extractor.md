# Test result — `vocabulary-extractor`

- Kết quả: **PASS — Skill tool triggered**
- Loại test: **real** (headless CLI `claude -p`, stream-json), chạy lúc 2026-09-28T15:08:52Z
- CLI: `2.1.283` · thư mục test mới, có đủ 10 skill của repo
  (`angular-review-checklist, code-sample-runner, csharp-review-checklist, handbook-chapter-writer, ocp-question-writer, react-native-feature-checklist, skill-creator, vietnamese-pdf-builder, vocabulary-extractor, webapp-testing`) + 33 skill có sẵn của môi trường (built-in/plugin, ví dụ `anthropic-skills:pdf`)
- Fixture: `test-fixtures/vocabulary-extractor`
- Kết thúc: `success`, 9 turns, 62 s

## Prompt
```text
Lấy từ vựng TOEIC hữu ích từ email.txt để thêm vào app học từ của tôi (định dạng word|pos|definition|example) và cho tôi bảng nghĩa tiếng Việt.
```

## Bằng chứng kích hoạt (tool_use "Skill" trong stream)
```json
[
 {
  "id": "toolu_01P35W8wy77bGUbzckBFsuaz",
  "input": {
   "skill": "vocabulary-extractor",
   "args": "email.txt"
  }
 }
]
```

Thứ tự tool đã gọi: `Skill → Bash → Read → Bash → Read → Bash → Write`

## File thay đổi trong thư mục test
```text
?? new-words.txt
```

## Câu trả lời cuối của Claude (nguyên văn)
Đã trích 23 mục từ `email.txt` (không có `apps/toeic/data/authored/definitions` trong repo này nên bỏ qua bước `--known`; đã lưu file tại `new-words.txt` ở gốc repo — bạn copy vào đúng thư mục app của bạn).

**Thống kê thật từ script:** tokens=110, distinct_lemmas=44, known_skipped=0, returned=44 (lemmatizer: simplemma)

| Từ | Loại | Nghĩa (vi) | Họ từ | Collocation | Ví dụ |
|---|---|---|---|---|---|
| renovation | n | sự cải tạo, sửa sang | renovate (v) | office renovation | The office renovation will start next month. |
| proposal | n | bản đề xuất | propose (v) | submit a proposal | Thank you for submitting your proposal for the office renovation. |
| submit | v | nộp, đệ trình | submission (n) | submit a proposal | Please submit your proposal by Friday. |
| facility | n | cơ sở, tiện ích | facilities manager | facilities manager | Our facilities manager checked the new equipment. |
| estimate | n | bản dự toán | estimate (v) | detailed estimate | We need a detailed estimate for the flooring and the lighting. |
| detailed | adj | chi tiết | detail (n) | detailed estimate | Please send a detailed estimate for the project. |
| contract | n | hợp đồng | contractor (n) | sign a contract | We will sign the contract after the site visit. |
| schedule | v | lên lịch | schedule (n), rescheduled | schedule a visit | The site visit was scheduled for next Tuesday. |
| delivery | n | sự giao hàng | deliver (v) | delivery schedule | Please confirm the delivery schedule for the materials. |
| material | n | vật liệu | — | — | The materials for the renovation arrived on time. |
| payment | n | khoản thanh toán | pay (v) | payment terms | Please review the payment terms before signing. |
| term | n | điều khoản | — | payment terms | The payment terms are listed in the contract. |
| budget | n | ngân sách | — | within budget | The renovation cost is within our budget. |
| approve | v | chấp thuận | approval (n) | — | We plan to approve the renovation by the end of the month. |
| disrupt | v | làm gián đoạn | disruption (n) | — | The work must not disrupt our customers. |
| flexibility | n | sự linh hoạt | flexible (adj) | — | We appreciate your flexibility with the schedule. |
| successful | adj | thành công | success (n), succeed (v) | successful project | We look forward to a successful project. |
| confirm | v | xác nhận | confirmation (n) | — | Please confirm the delivery schedule for the materials. |
| appreciate | v | đánh giá cao, biết ơn | appreciation (n) | — | We appreciate your flexibility and support. |
| review | v | xem xét, đánh giá | review (n) | — | Our facilities manager reviewed the proposal. |
| site visit | n | chuyến khảo sát thực địa | — | site visit | The facilities manager scheduled a site visit for Tuesday. |
| business hours | n | giờ làm việc | — | business hours | Most of the work should be scheduled after business hours. |
| look forward to | phr | mong chờ | — | look forward to | We look forward to a successful project. |

Đã bỏ tên riêng (Tran, Daniel Kim), số/thứ trong tuần, và từ quá cơ bản (office, visit, good, need...) trừ khi nằm trong collocation.
