# Test result — ba-requirements-challenger

- Date: 2026-09-28
- Mode: real (headless `claude -p`)
- Delegated to: ba-requirements-challenger
- Correct agent triggered: yes
- Tools the subagent used: Read

## Prompt

BA vừa gửi leave-request-srs.md. Trước khi ước lượng, hãy tìm các chỗ thiếu, mâu thuẫn, mơ hồ và yêu cầu phi chức năng còn thiếu.

## Result (verbatim)

## Tóm tắt
- SRS v0.3 mô tả module Leave Request: nhân viên tạo đơn (Annual/Sick/Unpaid), manager hoặc HR duyệt, trừ số ngày phép còn lại, gửi email cho manager.
- Tài liệu rất ngắn: 11 FR và 4 BR. Chưa có vòng đời trạng thái của đơn, chưa có công thức tính ngày, chưa có quy tắc phân quyền, và gần như không có NFR. Có 3 cặp yêu cầu mâu thuẫn nhau.
- Mức độ sẵn sàng: **Not ready**. Các câu P1 bên dưới cần được trả lời thì mới ước lượng được.

| # | Ưu tiên | Loại | Mục SRS | Vấn đề | Câu hỏi gửi BA (EN) |
|---|---------|------|---------|--------|---------------------|
| 1 | P1 | Conflict | FR-1 vs FR-2 | FR-1 liệt kê "and a reason" như trường bắt buộc cho mọi loại phép. FR-2 lại nói reason chỉ bắt buộc với Sick. Ngoài ra FR-2 có chữ "etc." nên không biết còn quy tắc nào khác. | "Is the reason mandatory only for Sick leave, or for all types? What does 'etc.' in FR-2 refer to? Please list every field and whether it is mandatory per leave type." |
| 2 | P1 | Conflict | BR-2 vs FR-7 | BR-2 kiểm tra số ngày còn lại lúc tạo đơn, còn FR-7 chỉ trừ số ngày khi đơn được duyệt. Vì vậy nhân viên có thể tạo nhiều đơn đang chờ duyệt, tổng cộng vượt số ngày còn lại. | "Is the balance check in BR-2 done against the approved balance only, or also minus pending requests? Are pending days 'reserved'?" |
| 3 | P1 | Conflict | FR-5 vs FR-8 | Đơn được gửi tới manager, nhưng HR cũng "can approve any request". Chưa rõ HR duyệt song song với manager hay duyệt thay khi manager vắng. HR có được reject không? HR có được tự duyệt đơn của chính mình không? | "Is HR an alternative approver (either one is enough) or a second step after the manager? Can HR also reject? Can HR approve their own request?" |
| 4 | P1 | Missing case | 3.2, 3.3 | Không có danh sách trạng thái và các chuyển trạng thái của đơn (Draft/Pending/Approved/Rejected/Cancelled...). | "Please provide the full status list and allowed transitions of a request, including who can trigger each transition." |
| 5 | P1 | Missing case | FR-9, FR-10 | Đơn đã duyệt thì không sửa được. Vậy nhân viên có được hủy/rút đơn đã duyệt không (ví dụ khi đổi kế hoạch hoặc đơn ở tương lai)? Nếu được thì số ngày có được hoàn lại không, và có cần duyệt lại không? | "Can an approved request be cancelled or withdrawn (e.g. for future dates)? If yes, who approves the cancellation and is the balance restored?" |
| 6 | P1 | Unclear rule | FR-3, BR-1 | Chưa có công thức tính số ngày. Có tính ngày lễ không? Có cho nghỉ nửa ngày hoặc theo giờ không? Thứ Bảy có được coi là ngày làm việc không (nhiều công ty VN làm nửa ngày thứ Bảy)? Làm tròn thế nào? | "What is the exact formula for leave days? Are public holidays excluded, and who maintains the holiday calendar? Are half-days or hours allowed? Is Saturday a working day for any employee group?" |
| 7 | P1 | Missing case | FR-4 | Có đúng 12 ngày cho mọi nhân viên không? Có cộng thêm theo thâm niên không? Người mới vào giữa năm hoặc nghỉ việc giữa năm có được tính theo tỷ lệ không? Ngày chưa dùng có được chuyển sang năm sau hoặc hết hạn không? "Năm" là năm dương lịch hay năm tính theo ngày vào làm? | "Is 12 days fixed for all employees or does it vary (seniority, contract type)? How is it pro-rated for joiners/leavers? Is carry-over allowed, with what limit and expiry? Is 'year' the calendar year or the employment year?" |
| 8 | P1 | Missing case | FR-4, FR-7 | Sick và Unpaid có quota hoặc giới hạn không? FR-7 chỉ nhắc tới annual balance. | "Do Sick and Unpaid leave have their own balance or maximum? If not, is there any limit at all?" |
| 9 | P1 | Missing case | FR-5 | Nếu nhân viên chưa có manager, manager đang nghỉ, manager nghỉ việc, hoặc manager tự xin nghỉ thì đơn gửi cho ai? Có cơ chế ủy quyền (delegation) hoặc chuyển cấp (escalation) không? Dữ liệu "manager" lấy từ đâu? | "Who approves when the employee has no manager, the manager is absent or has left, or the requester is a manager? Is delegation/escalation needed? Where does the manager relationship come from (HRIS, manual)?" |
| 10 | P1 | Missing case | 3.1 | Chưa có quy tắc validate: start date sau end date, ngày trong quá khứ (nghỉ ốm thường khai sau), đơn trùng lịch với đơn khác, đơn kéo dài qua hai năm, số ngày tối đa của một đơn, đơn có 0 ngày (chỉ rơi vào cuối tuần). | "Which date validations apply: past dates (allowed for Sick?), overlapping requests, requests spanning two years, maximum length, and requests that result in 0 working days?" |
| 11 | P1 | Missing case | BR-3 | "Longer than 2 days" tính theo ngày làm việc hay ngày lịch? Giấy khám bệnh nộp lúc tạo đơn hay nộp bổ sung sau? Định dạng và dung lượng file? Nếu không nộp thì sao (bị chặn, chuyển sang Unpaid...)? Ai xác minh giấy? | "For BR-3, are '2 days' working or calendar days? Must the certificate be uploaded at creation or can it come later (deadline)? Allowed file types/size? What happens if it is missing? Who verifies it?" |
| 12 | P1 | NFR | 2, 3.x | Không có ma trận phân quyền: manager xem được những đơn nào (cấp dưới trực tiếp hay cả cấp dưới gián tiếp)? HR xem được toàn bộ không? Nhân viên có xem được lịch nghỉ của cả team không? | "Please provide a permission matrix (view/create/approve/reject/cancel/edit balance) per role, including the scope of data each role can see." |
| 13 | P1 | Missing case | 3.x | Chưa có kế hoạch migration: số ngày phép còn lại hiện tại và các đơn cũ lấy từ đâu? Hệ thống có tích hợp HRIS/payroll không (nghỉ Unpaid ảnh hưởng lương)? | "How are existing balances and historical requests migrated? Must the module integrate with HRIS/payroll (e.g. Unpaid leave)?" |
| 14 | P2 | Missing case | FR-6 | Khi reject có bắt buộc nhập lý do không? Manager có được duyệt một phần đơn (một số ngày) hoặc yêu cầu nhân viên sửa đơn không? | "Is a rejection comment mandatory? Can a manager partially approve or return the request for changes?" |
| 15 | P2 | Missing case | FR-9 | Đơn đang chờ duyệt có được sửa không, hay chỉ được hủy? HR có được hủy đơn thay nhân viên không? | "Can a pending request be edited, or only cancelled? Can HR or the manager cancel on the employee's behalf?" |
| 16 | P2 | Missing case | FR-11 | Chỉ có email cho manager khi có đơn mới. Chưa rõ nhân viên có nhận thông báo khi đơn được duyệt/bị từ chối/bị hủy không, có email nhắc manager khi chưa duyệt không, có cần kênh in-app không, và xử lý thế nào khi gửi email lỗi. | "Which events trigger notifications, to whom and by which channel (email/in-app)? Are reminders needed for unanswered requests? What happens if email sending fails?" |
| 17 | P2 | Missing case | FR-8, FR-6 | Concurrency: manager và HR cùng thao tác trên một đơn cùng lúc (người duyệt, người từ chối), hoặc nhân viên hủy đơn đúng lúc manager đang duyệt. | "If two actors act on the same request at the same time (approve vs reject, cancel vs approve), which action wins and what does the other user see?" |
| 18 | P2 | Missing case | FR-7, FR-4 | HR có được điều chỉnh số ngày phép thủ công không? Nếu có thì có cần ghi lý do không? | "Can HR manually adjust balances? If yes, is a reason required and is it logged?" |
| 19 | P2 | NFR | 3.x | Chưa có yêu cầu audit log: ai duyệt, lúc nào, thay đổi số ngày phép ra sao. | "What actions must be audit-logged (create, approve, reject, cancel, balance change), which fields, and for how long must they be kept?" |
| 20 | P2 | NFR | BR-3 | Giấy khám bệnh là dữ liệu sức khỏe, tức dữ liệu nhạy cảm. Chưa có quy định ai được xem, lưu trong bao lâu, có mã hóa không. | "Who may view medical certificates? What is the retention period and are there encryption/privacy requirements (e.g. Decree 13/2023 on personal data)?" |
| 21 | P2 | Unclear rule | FR-6, mục 1 | "Within an appropriate time" và "approve it quickly" không kiểm thử được. Không có SLA, và không rõ điều gì xảy ra khi quá hạn. | "What is the approval SLA (in working hours/days)? What happens when it is exceeded: reminder, escalation, or auto-approve/reject?" |
| 22 | P2 | Unclear rule | BR-4 | "The system must be fast" không đo được. Chưa có số lượng user và đơn. | "What are the performance targets (e.g. page load < X s at p95) and the expected volume (number of employees, requests/month, peak concurrent users)?" |
| 23 | P2 | NFR | — | Thiếu các yêu cầu: availability, localization (vi/en), browser/mobile, accessibility, timezone (có văn phòng ở nhiều múi giờ không?). | "Required availability? Languages (vi/en)? Supported browsers and mobile? Accessibility level? Do employees work in multiple time zones, and which time zone defines a leave date?" |
| 24 | P3 | Missing case | 3.x | Chưa có màn hình xem lịch sử đơn, xem số ngày còn lại, báo cáo cho HR và export. | "Are history, balance view, team calendar and HR reports/exports in scope for this release?" |
| 25 | P3 | Unclear rule | FR-1 | Danh sách loại phép có cố định không, hay HR tự cấu hình được (ví dụ nghỉ cưới, nghỉ thai sản, nghỉ tang)? | "Is the leave type list fixed to three, or configurable by HR (e.g. maternity, wedding, bereavement)?" |
| 26 | P3 | Testability | Toàn bộ | Tài liệu không có acceptance criteria hoặc ví dụ tính toán cụ thể. | "Please add acceptance criteria with worked examples, e.g. a Thu–Tue request over a public holiday, and the expected number of days." |

### Giả định tạm thời (nếu BA chưa trả lời)
Các giả định dưới đây chỉ dùng để ước lượng sơ bộ. BA cần xác nhận, không được coi là yêu cầu chính thức.
- Trạng thái đơn: Pending, Approved, Rejected, Cancelled. Chỉ hủy được khi đơn còn Pending.
- Chỉ cần một cấp duyệt: manager trực tiếp hoặc HR, ai duyệt trước thì có hiệu lực. HR không tự duyệt đơn của mình.
- Số ngày tính theo ngày làm việc từ thứ Hai đến thứ Sáu, trừ ngày lễ. Đơn vị nhỏ nhất là nửa ngày.
- Số ngày khả dụng = số ngày còn lại trừ đi các đơn đang Pending.
- Sick và Unpaid không có quota. Chỉ Annual có số ngày phép.
- Chỉ có một múi giờ (Asia/Ho_Chi_Minh). Giao diện hỗ trợ vi/en.
- Chức năng delegation/escalation, báo cáo và tích hợp payroll nằm ngoài phạm vi (out of scope).

### Thuật ngữ cần thống nhất
- **Leave day / ngày nghỉ**: ngày làm việc hay ngày lịch? BR-1 dùng theo nghĩa ngày làm việc, còn BR-3 ("longer than 2 days") chưa rõ nghĩa nào.
- **Balance / số ngày phép còn lại**: chỉ tính số ngày đã duyệt, hay trừ luôn các đơn đang chờ duyệt? BR-2 và FR-7 đang ngầm hiểu theo hai cách khác nhau.
- **Year / năm**: năm dương lịch hay năm tính theo ngày vào làm (FR-4)?
- **Manager**: manager trực tiếp hay bất kỳ cấp trên nào? Lấy từ nguồn dữ liệu nào?
- **Approve (HR vs Manager)**: HR là người duyệt thay thế hay là một bước duyệt thứ hai (FR-8)?
- **Change / Cancel**: "Cannot be changed" trong FR-10 có bao gồm cả việc hủy đơn hay không?

File đã rà soát: `<workdir>/ba-requirements-challenger/leave-request-srs.md` (đã đọc hết các mục 1–4 và toàn bộ FR-1..FR-11, BR-1..BR-4).
