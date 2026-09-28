# Test result — english-coach

- Date: 2026-09-28
- Mode: real (headless `claude -p`)
- Delegated to: english-coach (run as main agent with --agent, multi-turn with -c)
- Correct agent triggered: yes
- Tools the subagent used: (none recorded)

## Prompt

Let's practise English: roleplay a daily stand-up. You are my Scrum Master Sarah; I am the frontend lead. I will say 'end scene' when done.

## Result (verbatim)

**User:** Let's practise English: roleplay a daily stand-up. You are my Scrum Master Sarah; I am the frontend lead. I will say 'end scene' when done.

**Coach:** **Scene setup:**
- 🎬 Scene: Daily stand-up meeting
- 👤 My role: Sarah (Scrum Master)
- 👤 Your role: Frontend Lead
- 🎯 Goal: Practice giving a clear stand-up update (yesterday's work, today's plan, blockers)
- 📈 Level: B1–B2, simple spoken English
- 🛑 To finish: just say **"end scene"**

Ready? Let's start.

---

**Sarah:** Good morning, team! Let's get started. Thanh, can you go first — what did you work on yesterday?

**User:** Yesterday I fix the bug of login page and today I will making the unit test. I have one blocker, the API from backend team is not ready since two days.

**Coach:** Got it, thanks. Which API exactly is missing — is it the login API, or something else for the unit tests?

**User:** Yes, I already ask them but they said maybe tomorrow. If not ready I will use mock data for continue.

**Coach:** That sounds like a good plan B. Can you talk to Minh right after this meeting to confirm the mock data approach with him too?

**User:** end scene

**Coach:** ### Nhận xét chung (2–3 câu, tiếng Việt)
Bạn truyền đạt được ý khá rõ ràng cho một buổi stand-up — người nghe hiểu được bạn làm gì, đang bị chặn ở đâu, và hướng xử lý. Vấn đề chính là chia động từ (tense) chưa chuẩn, đây là lỗi rất phổ biến và dễ sửa. Chỉ cần chỉnh vài chỗ nhỏ là câu sẽ tự nhiên như người bản xứ nói trong công việc.

| # | Bạn đã nói | Tự nhiên hơn | Vì sao (tiếng Việt, ngắn) |
|---|-----------|--------------|---------------------------|
| 1 | Yesterday I fix the bug of login page | Yesterday I fixed the login page bug | "Yesterday" → dùng quá khứ đơn "fixed"; và "login page bug" gọn hơn "bug of login page" |
| 2 | today I will making the unit test | today I'm going to write the unit tests | "will making" sai cấu trúc; dùng "going to" cho kế hoạch đã định, "write" hợp với "tests" hơn "making" |
| 3 | the API from backend team is not ready since two days | the API from the backend team hasn't been ready for two days | Dùng thì hiện tại hoàn thành "hasn't been ready" khi nói về việc kéo dài đến hiện tại; "for two days" (khoảng thời gian) chứ không phải "since two days" |
| 4 | If not ready I will use mock data for continue | If it's not ready, I'll use mock data to continue | Cần chủ ngữ "it"; "to continue" (to + V) chứ không phải "for continue" |

### 5 cụm từ hữu ích cho tình huống này (EN — nghĩa VI — ví dụ)
1. **I'm blocked on...** — tôi đang bị kẹt ở... — "I'm blocked on the payment API."
2. **waiting on [team/person]** — đang chờ (ai đó) — "I'm waiting on the backend team for the API."
3. **work around it** — tìm cách xử lý tạm — "I'll work around it using mock data."
4. **follow up with** — theo sát/liên hệ lại với — "I'll follow up with Minh after this."
5. **no blockers on my end** — không có gì cản trở phía tôi — dùng khi mọi việc suôn sẻ.

### Phát âm cần chú ý (nếu có từ khó, viết IPA)
- **blocker** /ˈblɒkər/ — nhấn âm đầu, không phải /blok/.
- **unit tests** /ˈjuːnɪt tɛsts/ — chú ý âm cuối "-ts" rõ ràng, người Việt hay bỏ mất.

### Thử lại? (gợi ý một phiên bản khó hơn của cảnh)
Lần sau thử: stand-up nhưng Sarah (tôi) sẽ hỏi ngược lại nhiều hơn — ví dụ đẩy bạn giải thích rủi ro nếu mock data không khớp với API thật, và yêu cầu bạn đưa ra estimate cụ thể (ngày/giờ) cho việc hoàn thành unit test. Bạn có muốn thử luôn không?
