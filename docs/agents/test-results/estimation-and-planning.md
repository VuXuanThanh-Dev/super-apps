# Test result — estimation-and-planning

- Date: 2026-09-28
- Mode: real (headless `claude -p`)
- Delegated to: estimation-and-planning
- Correct agent triggered: yes
- Tools the subagent used: Glob, Read

## Prompt

Chia task và ước lượng effort cho leave-request-srs.md. Team: 2 Angular dev, 1 Java Spring dev, 1 QA.

## Result (verbatim)

# Ước lượng effort — Module Leave Request (Đơn xin nghỉ phép)

**Nguồn:** `leave-request-srs.md` (SRS v0.3, bản draft từ BA)
**Team:** 2 Angular dev (FE), 1 Java Spring dev (BE), 1 QA

Repo hiện tại chỉ có file SRS và config agent, **không có codebase hiện hữu** để đối chiếu (không tìm thấy module tương tự, không rõ đây là app mới hay thêm vào hệ thống HRM/ERP sẵn có). Estimate dưới đây giả định module được thêm vào một hệ thống nội bộ **đã có sẵn** auth, dữ liệu tổ chức (employee–manager mapping) và hạ tầng email — nếu không đúng, cộng thêm đáng kể effort (xem phần Rủi ro).

SRS này còn khá nhiều điểm mơ hồ (FR-2 "etc.", FR-6 "appropriate time", BR-4 "must be fast"...). Về nguyên tắc nên chạy **ba-requirements-challenger** trước khi chốt số, các task bị ảnh hưởng được đánh dấu ⚠️ bên dưới.

---

## 1. Task dùng chung / Cross-cutting

| ID | Task | Layer | O | M | P | Expected (ngày) | Phụ thuộc | Ghi chú |
|----|------|-------|---|---|---|-----------------|-----------|---------|
| SH-1 | Làm rõ requirement với BA (FR-2, FR-6, FR-7, BR-1, BR-4...) | Shared | 0.5 | 1 | 2 | 1.08 | — | ⚠️ Blocking, nên làm trước sprint 1 |
| SH-2 | Thiết kế API contract (OpenAPI), review chung BE+FE | Shared | 0.5 | 1 | 1.5 | 1.00 | SH-1 | Cho FE dev sớm để không bị block |
| SH-3 | Thiết kế DB schema (leave_request, leave_type, leave_balance, attachment, audit_log) | Shared | 0.5 | 1 | 2 | 1.08 | SH-1 | |
| SH-4 | Setup môi trường/module scaffold (CI, migration tool, feature branch) | Shared | 0.5 | 1 | 2 | 1.08 | — | Giả định hạ tầng CI/CD đã có sẵn ở tổ chức |
| SH-5 | Cấu hình lịch ngày lễ (public holiday) | Shared | 0.5 | 1 | 1.5 | 1.00 | SH-1 | ⚠️ SRS chỉ nói loại trừ cuối tuần, không nói ngày lễ |
| SH-6 | Deploy staging/prod, release notes | Shared | 0.5 | 1 | 1.5 | 1.00 | Toàn bộ BE/FE done | |
| SH-7 | Hỗ trợ UAT | Shared | 1 | 2 | 3 | 2.00 | SH-6 | |
| SH-8 | Tài liệu (API doc final, user guide) | Shared | 0.5 | 1 | 1.5 | 1.00 | SH-2 | |

**Tổng nhóm Shared ≈ 9.25 ngày công**

---

## 2. Backend (Java Spring — 1 dev)

| ID | Task | Layer | O | M | P | Expected (ngày) | Phụ thuộc | Ghi chú |
|----|------|-------|---|---|---|-----------------|-----------|---------|
| BE-1 | Entity + migration script (Flyway/Liquibase) | BE | 0.5 | 1 | 1.5 | 1.00 | SH-3 | FR-1..4 |
| BE-2 | Module leave balance (init 12 ngày/năm, API lấy số dư) | BE | 1 | 1.5 | 2.5 | 1.58 | BE-1 | FR-4 ⚠️ chưa rõ prorate cho nhân viên mới, carry-over năm sau |
| BE-3 | API tạo đơn nghỉ + validate (loại nghỉ, ngày, lý do) | BE | 1 | 2 | 3 | 2.00 | BE-1, BE-2, SH-2 | FR-1, FR-2 ⚠️ |
| BE-4 | Service tính số ngày nghỉ (loại trừ cuối tuần/lễ) | BE | 1 | 1.5 | 2.5 | 1.58 | BE-3, SH-5 | FR-3, BR-1 |
| BE-5 | Upload giấy khám bệnh khi sick leave > 2 ngày | BE | 1 | 1.5 | 2.5 | 1.58 | BE-3 | BR-3 ⚠️ chưa rõ định dạng/size file, bắt buộc lúc nào |
| BE-6 | API list/get đơn (theo employee/manager/HR) có filter, phân trang | BE | 1 | 1.5 | 2.5 | 1.58 | BE-1, BE-10 | FR-5, FR-8 |
| BE-7 | Workflow duyệt/từ chối (manager + HR override), trừ balance khi approve, state machine | BE | 1.5 | 2.5 | 4 | 2.58 | BE-2, BE-3, BE-6, BE-10 | FR-6, FR-7, FR-8 — **critical path**, phức tạp nhất |
| BE-8 | API hủy đơn (chỉ khi chưa approve) | BE | 0.5 | 1 | 1.5 | 1.00 | BE-3 | FR-9, FR-10 |
| BE-9 | Notification service: email cho manager khi có đơn mới | BE | 1 | 1.5 | 2.5 | 1.58 | BE-3 | FR-11 ⚠️ chỉ có email lúc tạo, không có khi approve/reject — cần xác nhận có thiếu sót không |
| BE-10 | Auth/role (Employee/Manager/HR) + lấy dữ liệu manager của nhân viên | BE | 1 | 2 | 3 | 2.00 | SH-1 | ⚠️ phụ thuộc hệ thống tổ chức đã có sẵn hay chưa |
| BE-11 | Xử lý concurrency/khóa khi trừ balance (optimistic lock, audit log) | BE | 1 | 1.5 | 2.5 | 1.58 | BE-7 | Rủi ro race-condition khi nhiều request cùng lúc |
| BE-12 | Unit test backend | BE | 1 | 2 | 3 | 2.00 | BE-1..BE-11 | |
| BE-13 | API docs + buffer sửa lỗi | BE | 0.5 | 1 | 2 | 1.08 | BE-12 | |

**Tổng nhóm Backend ≈ 21.16 ngày công (1 dev → ~4.2 tuần làm việc thực tế)**

Backend là **nút thắt cổ chai** vì chỉ có 1 dev trong khi có 2 FE dev — đây sẽ là yếu tố quyết định lịch tổng thể.

---

## 3. Frontend (Angular/PrimeNG — 2 dev, có thể chạy song song)

| ID | Task | Layer | O | M | P | Expected (ngày) | Phụ thuộc | Ghi chú |
|----|------|-------|---|---|---|-----------------|-----------|---------|
| FE-1 | Scaffold module, routing, cấu hình PrimeNG | FE | 0.5 | 1 | 1.5 | 1.00 | SH-4 | |
| FE-2 | Form tạo đơn nghỉ (loại, ngày, lý do conditional-required, tính số ngày, upload chứng từ) | FE | 1.5 | 2.5 | 4 | 2.58 | SH-2 (mock trước, integrate sau BE-3/BE-4/BE-5) | FR-1..3, BR-3 |
| FE-3 | Trang "Đơn của tôi" (list + filter + hủy) | FE | 1 | 1.5 | 2.5 | 1.58 | SH-2, BE-6, BE-8 | FR-9 |
| FE-4 | Widget hiển thị số ngày phép còn lại | FE | 0.5 | 1 | 1.5 | 1.00 | BE-2 | FR-4 |
| FE-5 | Dashboard duyệt đơn cho Manager | FE | 1.5 | 2.5 | 4 | 2.58 | SH-2, BE-6, BE-7 | FR-5, FR-6 |
| FE-6 | Trang duyệt cho HR (xem/duyệt tất cả) | FE | 1 | 1.5 | 2.5 | 1.58 | BE-6, BE-7 | FR-8 |
| FE-7 | Shared services (API layer, guard theo role, toast/error handling) | FE | 1 | 1.5 | 2.5 | 1.58 | SH-2 | |
| FE-8 | UX: dialog xác nhận hủy, badge trạng thái, empty/error state | FE | 1 | 1.5 | 2 | 1.50 | FE-2, FE-3, FE-5 | |
| FE-9 | Responsive/accessibility/cross-browser | FE | 0.5 | 1 | 2 | 1.08 | FE-2..FE-8 | |
| FE-10 | Unit test FE (Jasmine/Karma) | FE | 1 | 2 | 3 | 2.00 | FE-2..FE-8 | |
| FE-11 | Tích hợp API thật (thay mock) + sửa lỗi tích hợp | FE | 1 | 2 | 3 | 2.00 | BE-3, BE-6, BE-7, BE-8 | Phải chờ BE endpoint sẵn sàng |

**Tổng nhóm Frontend ≈ 18.5 ngày công**, chia cho 2 dev → **~9.25 ngày/người** nếu chia đôi công bằng (ví dụ FE-A làm FE-1,2,3,4,8,9; FE-B làm FE-5,6,7,10,11). Có thể chạy phần lớn song song với BE nếu dùng mock theo API contract (SH-2).

---

## 4. QA/Testing

| ID | Task | Layer | O | M | P | Expected (ngày) | Phụ thuộc | Ghi chú |
|----|------|-------|---|---|---|-----------------|-----------|---------|
| QA-1 | Viết test plan/test case từ SRS (kể cả edge case) | QA | 1 | 1.5 | 2.5 | 1.58 | SH-1 | Có thể bắt đầu song song sprint 1 |
| QA-2 | Chuẩn bị test data/môi trường test | QA | 0.5 | 1 | 1.5 | 1.00 | SH-4 | |
| QA-3 | Test chức năng: tạo đơn | QA | 0.5 | 1 | 1.5 | 1.00 | FE-2, BE-3/4 build ổn định | |
| QA-4 | Test chức năng: duyệt/từ chối (manager + HR) | QA | 1 | 1.5 | 2 | 1.50 | FE-5/6, BE-7 | |
| QA-5 | Test chức năng: hủy đơn | QA | 0.5 | 0.5 | 1 | 0.58 | FE-3, BE-8 | |
| QA-6 | Test business rule/boundary (đúng 12 ngày, sick 2 vs 3 ngày, unpaid optional reason) | QA | 1 | 1.5 | 2.5 | 1.58 | Toàn bộ BR-1..4 | ⚠️ phụ thuộc làm rõ BR-1 (ngày lễ), BR-4 (NFR) |
| QA-7 | Test notification (nội dung/trigger email) | QA | 0.5 | 1 | 1.5 | 1.00 | BE-9 | |
| QA-8 | Regression pass | QA | 1 | 1.5 | 2 | 1.50 | Sau bugfix | |
| QA-9 | Hỗ trợ UAT | QA | 0.5 | 1 | 2 | 1.08 | SH-7 | |
| QA-10 | Verify/retest bug qua nhiều vòng | QA | 1 | 2 | 3 | 2.00 | Toàn bộ trên | |

**Tổng nhóm QA ≈ 12.83 ngày công**

---

## Tổng hợp

| Nhóm | Expected (ngày công) | O (tổng) | P (tổng) |
|---|---|---|---|
| Shared | 9.25 | 4.5 | 15.0 |
| Backend | 21.16 | 12.0 | 33.0 |
| Frontend | 18.50 | 10.5 | 28.5 |
| QA | 12.83 | 7.5 | 19.5 |
| **Tổng** | **≈ 61.7 ngày công** | **34.5** | **96.0** |

**Expected ≈ 62 ngày công (khoảng 35–96 ngày công theo PERT range)**, phân bổ cho 4 người.

Lịch thực tế không đơn giản là 62/4 vì **backend là nút thắt** (1 dev, ~21 ngày công riêng phần BE) và nhiều task FE/QA phụ thuộc BE hoàn thành. Ước tính **lịch thực tế (calendar time) khoảng 5–7 tuần làm việc** (bao gồm review code, họp, chờ phản hồi, không tính nghỉ phép/gián đoạn của chính team), nếu chạy song song tối đa theo kế hoạch bên dưới.

---

## Giả định
1. Module được thêm vào hệ thống nội bộ **đã có sẵn** authentication, dữ liệu tổ chức (employee-manager mapping), hạ tầng email và CI/CD — nếu là hệ thống mới hoàn toàn, cộng thêm ~10–15 ngày công (auth, org data model, hạ tầng gửi mail, deployment pipeline).
2. Team ở mức mid-level (không có thông tin về kỹ năng cụ thể) — nếu có junior, nhân hệ số ~1.3–1.5x cho các task phức tạp (BE-7, BE-11, FE-2, FE-5).
3. 1 loại "leave type" tài liệu file đính kèm (chứng từ y tế) lưu trên local/S3 sẵn có, không cần build hệ thống lưu trữ mới.
4. Không có yêu cầu mobile app riêng, chỉ web responsive.
5. Không có yêu cầu tích hợp với hệ thống chấm công/bảng lương ở phase này.
6. SLA/NFR cho "fast" (BR-4) sẽ được benchmark theo chuẩn nội bộ hiện có, không cần thiết kế lại hạ tầng performance riêng.

## Rủi ro (tác động lên ước lượng)
- **FR-2 "etc."**: quy tắc required/optional reason cho từng loại nghỉ chưa đầy đủ → có thể phát sinh thêm validate case, rework FE/BE (+0.5–1 ngày mỗi bên).
- **FR-6 "appropriate time"**: không có SLA rõ ràng cho việc duyệt đơn → chưa biết có cần auto-reminder/escalation hay auto-approve timeout không. Nếu có, cộng thêm ~2–3 ngày BE (scheduler job) + FE hiển thị.
- **FR-7 thời điểm trừ balance**: chưa rõ trừ khi tạo đơn (giữ chỗ) hay chỉ khi approve — ảnh hưởng lớn đến việc xử lý overlap/race condition (BE-7, BE-11), có thể +1–2 ngày nếu cần cơ chế "reserved balance".
- **FR-8 HR duyệt bất kỳ đơn nào**: chưa rõ cơ chế khi manager đã reject mà HR override, hoặc ai duyệt đơn của chính manager — cần làm rõ để không thiếu case trong BE-7/FE-6.
- **FR-9/FR-10**: chỉ nói "hủy trước khi approve", không nói có cho **sửa** đơn đang pending không — nếu có, thêm 1 API + FE form edit (~1.5–2 ngày).
- **FR-11**: chỉ có email khi tạo đơn, không có khi approve/reject/cancel — nhiều khả năng là thiếu sót của SRS, nên xác nhận; nếu bổ sung, +1–1.5 ngày BE, +0.5 ngày QA.
- **BR-1**: chỉ loại trừ cuối tuần, không đề cập ngày lễ — nếu cần loại trừ cả ngày lễ (rất có khả năng theo thực tế nghiệp vụ VN), cần nguồn dữ liệu lịch lễ (SH-5) và có thể phát sinh maintain hàng năm.
- **BR-2**: chỉ nói balance của annual leave, không rõ sick/unpaid có giới hạn/theo dõi riêng không.
- **BR-3**: chưa rõ định dạng file, giới hạn dung lượng, bắt buộc lúc submit hay có thể bổ sung sau khi manager yêu cầu.
- **BR-4 "must be fast"**: NFR không đo lường được, không thể test pass/fail → QA-6 và performance work không estimate chính xác được cho đến khi có con số cụ thể (vd. response time < Xms).
- **Không có mô tả**: audit trail/lịch sử thay đổi, nửa ngày phép (half-day leave), giới hạn số ngày tối thiểu báo trước, overlap giữa các đơn của cùng 1 nhân viên, đa ngôn ngữ. Nếu bất kỳ mục nào là yêu cầu ẩn, sẽ phát sinh thêm effort ngoài bảng trên.
- **Rủi ro về nguồn lực**: chỉ có 1 BE dev — nếu người này nghỉ/ốm hoặc bị task khác chen ngang, toàn bộ lịch trễ theo vì không có backup.

## Thứ tự đề xuất / sprint plan
Giả định sprint 2 tuần, 1 BE dev là critical path.

**Sprint 0 (2–4 ngày, trước sprint chính thức):**
SH-1 (làm rõ requirement, tốt nhất chạy `ba-requirements-challenger`) → SH-2, SH-3, SH-4, SH-5. QA bắt đầu QA-1 song song.

**Sprint 1 (2 tuần):**
- BE: BE-1 → BE-2 → BE-3 → BE-4 → BE-10 (auth/role)
- FE: FE-1, FE-7 (services), FE-2 (form, dùng mock theo API contract), FE-4
- QA: QA-1 (hoàn thiện), QA-2

**Sprint 2 (2 tuần):**
- BE: BE-5 (upload chứng từ), BE-6 (list API), BE-7 (workflow duyệt — trọng tâm), BE-9 (email), BE-8 (hủy)
- FE: FE-3, FE-5, FE-6 (vẫn mock nếu BE-7 chưa xong đầu sprint), FE-8
- QA: bắt đầu QA-3, QA-7 khi build ổn định

**Sprint 3 (1–1.5 tuần):**
- BE: BE-11 (concurrency), BE-12, BE-13 (buffer)
- FE: FE-11 (tích hợp API thật), FE-9, FE-10
- QA: QA-4, QA-5, QA-6, QA-8 (regression)

**Sprint 4 (buffer ~0.5–1 tuần):**
SH-6 (deploy staging), QA-9 (UAT), QA-10 (retest), SH-7, SH-8, sửa bug phát sinh từ UAT.

## Câu hỏi còn mở ảnh hưởng ước lượng
1. Module này đứng độc lập hay tích hợp vào hệ thống HRM/ERP đã có (auth, org data, mail server)? Ảnh hưởng lớn nhất đến estimate.
2. FR-6: có SLA/thời hạn duyệt cụ thể không? Có cần auto-reminder hoặc escalation không?
3. FR-7: balance bị trừ ngay khi tạo đơn (giữ chỗ) hay chỉ khi được duyệt?
4. FR-8/FR-9: HR có thể override quyết định của manager không? Nhân viên có được sửa đơn đang pending, hay chỉ được hủy?
5. FR-11: có cần thông báo (email/in-app) khi đơn được duyệt/từ chối/hủy không, hay chỉ khi tạo mới?
6. BR-1: có loại trừ ngày lễ không, và nguồn dữ liệu ngày lễ lấy từ đâu?
7. BR-3: định dạng, dung lượng file chứng từ y tế; bắt buộc đính kèm ngay lúc nào?
8. BR-4: chỉ tiêu hiệu năng cụ thể ("fast" nghĩa là bao nhiêu ms)?
9. Có yêu cầu về nửa ngày phép, giới hạn số ngày báo trước, hoặc kiểm tra chồng lấn giữa các đơn không?

Khuyến nghị chạy **ba-requirements-challenger** (`.claude/agents/ba-requirements-challenger.md` đã có sẵn trong repo) trước khi chốt scope sprint 1, vì các câu hỏi 2–8 đều ảnh hưởng trực tiếp đến task trên critical path (BE-7).
