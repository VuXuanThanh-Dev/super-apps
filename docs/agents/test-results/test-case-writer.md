# Test result — test-case-writer

- Date: 2026-09-28
- Mode: real (headless `claude -p`)
- Delegated to: test-case-writer
- Correct agent triggered: yes
- Tools the subagent used: Read

## Prompt

Write QA test cases for section 3.1 (Create request) and BR-1, BR-2 of leave-request-srs.md.

## Result (verbatim)

The test-case-writer agent finished. Here's its full output, unchanged:

---

# QA Test Cases — Leave Request SRS (Scope: Section 3.1 "Create request" + BR-1 + BR-2)

## 1. Testable rules in scope

| Rule ID | Definition (verbatim from SRS) |
|---|---|
| FR-1 (3.1) | An employee selects leave type (Annual, Sick, Unpaid), start date, end date and a reason. |
| FR-2 (3.1) | The reason is required for Sick leave and optional for others, etc. |
| FR-3 (3.1) | The system calculates the number of leave days automatically. |
| FR-4 (3.1) | An employee has 12 annual leave days per year. |
| BR-1 | Leave days do not include weekends. |
| BR-2 | An employee cannot request more annual days than the remaining balance. |

Out of scope (not tested here): FR-5–FR-11 (approval, cancel, notification), BR-3 (medical certificate), BR-4 (performance).

## 2. Test cases

| ID | Tiêu đề / Title | Yêu cầu (trace) | Tiền điều kiện | Các bước | Dữ liệu test | Kết quả mong đợi | Loại | Ưu tiên |
|---|---|---|---|---|---|---|---|---|
| TC-CR-001 | Create request with leave type = Annual | FR-1 (3.1) | Employee logged in; remaining annual balance = 12 | 1. Open Create Request form 2. Select leave type = Annual 3. Enter valid start/end date 4. Submit | Leave type = "Annual" | Leave type accepted; request proceeds to next validation without leave-type error | Positive | High |
| TC-CR-002 | Create request with leave type = Sick | FR-1 (3.1) | Employee logged in | 1. Open form 2. Select leave type = Sick 3. Enter valid dates + reason 4. Submit | Leave type = "Sick" | Leave type accepted | Positive | High |
| TC-CR-003 | Create request with leave type = Unpaid | FR-1 (3.1) | Employee logged in | 1. Open form 2. Select leave type = Unpaid 3. Enter valid dates 4. Submit | Leave type = "Unpaid" | Leave type accepted | Positive | High |
| TC-CR-004 | Reject request with invalid/unsupported leave type | FR-1 (3.1) | Employee logged in; API/manual injection possible | 1. Attempt to submit with leave type outside {Annual, Sick, Unpaid}, e.g. via direct API call | Leave type = "Maternity" | System rejects with validation error; request not created | Negative | High |
| TC-CR-005 | Reject request when leave type is not selected | FR-1 (3.1) | Employee logged in | 1. Open form 2. Leave "Leave type" unselected 3. Fill other fields 4. Submit | Leave type = (blank) | Validation error "Leave type is required"; request not created | Negative | High |
| TC-CR-006 | Reject request when start date is blank | FR-1 (3.1) | Employee logged in | 1. Open form 2. Select leave type 3. Leave start date empty 4. Fill end date 5. Submit | Start date = (blank) | Validation error "Start date is required"; request not created | Negative | High |
| TC-CR-007 | Reject request when end date is blank | FR-1 (3.1) | Employee logged in | 1. Open form 2. Select leave type 3. Fill start date 4. Leave end date empty 5. Submit | End date = (blank) | Validation error "End date is required"; request not created | Negative | High |
| TC-CR-008 | Reject request with invalid date format | FR-1 (3.1) | Employee logged in | 1. Open form 2. Enter malformed value in date field 3. Submit | Start date = "31/13/2026" or "abc" | Validation error on date field; request not created | Negative | Medium |
| TC-CR-009 | Reject Sick leave request with no reason | FR-2 (3.1) | Employee logged in | 1. Select leave type = Sick 2. Enter valid dates 3. Leave "Reason" blank 4. Submit | Leave type = Sick, Reason = (blank) | Validation error "Reason is required for Sick leave"; request not created | Negative | High |
| TC-CR-010 | Accept Sick leave request with reason provided | FR-2 (3.1) | Employee logged in | 1. Select leave type = Sick 2. Enter valid dates 3. Enter reason 4. Submit | Reason = "Flu, need rest" | Request accepted; no reason-related error | Positive | High |
| TC-CR-011 | Accept Annual leave request with reason blank (optional) | FR-2 (3.1) | Employee logged in; balance ≥ requested days | 1. Select leave type = Annual 2. Enter valid dates 3. Leave reason blank 4. Submit | Reason = (blank) | Request accepted; reason not mandatory for Annual | Positive | Medium |
| TC-CR-012 | Accept Annual leave request with reason provided | FR-2 (3.1) | Employee logged in; balance ≥ requested days | 1. Select leave type = Annual 2. Enter valid dates 3. Enter reason 4. Submit | Reason = "Family trip" | Request accepted | Positive | Low |
| TC-CR-013 | Accept Unpaid leave request with reason blank (optional) | FR-2 (3.1) | Employee logged in | 1. Select leave type = Unpaid 2. Enter valid dates 3. Leave reason blank 4. Submit | Reason = (blank) | Request accepted; reason not mandatory for Unpaid | Positive | Medium |
| TC-CR-014 | Accept Unpaid leave request with reason provided | FR-2 (3.1) | Employee logged in | 1. Select leave type = Unpaid 2. Enter valid dates 3. Enter reason 4. Submit | Reason = "Personal matters" | Request accepted | Positive | Low |
| TC-CR-015 | Auto-calc: single weekday | FR-3 (3.1), BR-1 | Employee logged in; e.g. Monday 2026-10-05 is a weekday | 1. Select leave type = Annual 2. Set start = end = a Monday 3. Submit/preview | Start = End = "2026-10-05" (Mon) | System computes and displays 1 leave day | Positive / Boundary | High |
| TC-CR-016 | Auto-calc: full working week, no weekend inside range | FR-3 (3.1), BR-1 | Employee logged in | 1. Select leave type = Annual 2. Set start = Mon, end = Fri of same week 3. Submit/preview | Start = "2026-10-05" (Mon), End = "2026-10-09" (Fri) | System computes 5 leave days | Positive | High |
| TC-CR-017 | Auto-calc: range spans exactly one weekend | FR-3 (3.1), BR-1 | Employee logged in | 1. Select leave type = Annual 2. Set start = Mon, end = following Sun (7 calendar days) 3. Submit/preview | Start = "2026-10-05" (Mon), End = "2026-10-11" (Sun) | System computes 5 leave days (Sat/Sun excluded), not 7 | Boundary | High |
| TC-CR-018 | Auto-calc: range spans two weekends | FR-3 (3.1), BR-1 | Employee logged in | 1. Select leave type = Annual 2. Set start = Mon week 1, end = Fri week 2 3. Submit/preview | Start = "2026-10-05" (Mon), End = "2026-10-16" (Fri, 12 calendar days) | System computes 10 leave days (4 weekend days excluded) | Boundary | High |
| TC-CR-019 | Auto-calc: date range falls entirely on Saturday | FR-3 (3.1), BR-1 | Employee logged in | 1. Select leave type = Annual 2. Set start = end = a Saturday 3. Submit/preview | Start = End = "2026-10-10" (Sat) | System computes 0 leave days | Boundary / Edge | Medium |
| TC-CR-020 | Auto-calc: date range covers only Saturday–Sunday | FR-3 (3.1), BR-1 | Employee logged in | 1. Select leave type = Annual 2. Set start = Sat, end = Sun of same weekend 3. Submit/preview | Start = "2026-10-10" (Sat), End = "2026-10-11" (Sun) | System computes 0 leave days | Boundary / Edge | Medium |
| TC-CR-021 | Annual request equal to full remaining balance (boundary = max) | FR-4 (3.1), BR-2 | Employee logged in; remaining annual balance = 12 | 1. Select leave type = Annual 2. Choose a date range that computes to exactly 12 working days 3. Submit | Requested days = 12, Balance = 12 | Request accepted (12 ≤ 12) | Positive / Boundary | High |
| TC-CR-022 | Annual request exceeds remaining balance by 1 (boundary = max+1) | FR-4 (3.1), BR-2 | Employee logged in; remaining annual balance = 12 | 1. Select leave type = Annual 2. Choose date range computing to 13 working days 3. Submit | Requested days = 13, Balance = 12 | Request rejected with error "Requested days exceed remaining annual balance"; request not created | Negative / Boundary | High |
| TC-CR-023 | Annual request one day below remaining balance (boundary = max-1) | FR-4 (3.1), BR-2 | Employee logged in; remaining annual balance = 12 | 1. Select leave type = Annual 2. Choose date range computing to 11 working days 3. Submit | Requested days = 11, Balance = 12 | Request accepted | Positive / Boundary | Medium |
| TC-CR-024 | Annual request when remaining balance = 0 (boundary = min) | BR-2 | Employee logged in; remaining annual balance = 0 | 1. Select leave type = Annual 2. Choose date range computing to 1 working day 3. Submit | Requested days = 1, Balance = 0 | Request rejected; error indicating insufficient balance | Negative / Boundary | High |
| TC-CR-025 | Annual request when remaining balance = 1, request exactly 1 day | BR-2 | Employee logged in; remaining annual balance = 1 | 1. Select leave type = Annual 2. Choose date range computing to 1 working day 3. Submit | Requested days = 1, Balance = 1 | Request accepted (1 ≤ 1) | Positive / Boundary | Medium |
| TC-CR-026 | Sick leave exceeding remaining annual balance is still allowed (BR-2 scope check) | BR-2 | Employee logged in; remaining annual balance = 2 | 1. Select leave type = Sick 2. Enter reason 3. Choose date range computing to 5 working days 4. Submit | Leave type = Sick, Requested days = 5, Annual balance = 2 | Request accepted — BR-2 only restricts "annual days"; Sick leave is not blocked by annual balance | Positive (negative-scope check) | High |
| TC-CR-027 | Unpaid leave exceeding remaining annual balance is still allowed (BR-2 scope check) | BR-2 | Employee logged in; remaining annual balance = 2 | 1. Select leave type = Unpaid 2. Choose date range computing to 5 working days 3. Submit | Leave type = Unpaid, Requested days = 5, Annual balance = 2 | Request accepted — BR-2 does not apply to Unpaid leave | Positive (negative-scope check) | High |
| TC-CR-028 | Reject submission with all required fields blank | FR-1 (3.1) | Employee logged in | 1. Open Create Request form 2. Leave leave type, start date, end date all blank 3. Submit | All fields = (blank) | Multiple validation errors returned (leave type, start date, end date all required); request not created | Negative / Error handling | High |
| TC-CR-029 (E2E) | Happy path: Annual leave spanning a weekend, no reason, within balance | FR-1, FR-2, FR-3, FR-4 (3.1), BR-1, BR-2 | Employee logged in; remaining annual balance = 12 | 1. Select leave type = Annual 2. Set start = Mon, end = following Fri (spans 1 weekend) 3. Leave reason blank 4. Submit | Leave type = Annual, Start = "2026-10-05", End = "2026-10-12" | System computes 6 leave days (weekend excluded), accepts optional-blank reason, confirms 6 ≤ 12 balance, and creates the request successfully | Positive (E2E) | High |
| TC-CR-030 (E2E) | Happy path: Sick leave with reason, spanning a weekend, balance not relevant | FR-1, FR-2, FR-3 (3.1), BR-1, BR-2 | Employee logged in; remaining annual balance = 0 | 1. Select leave type = Sick 2. Enter reason 3. Set start = Fri, end = following Mon (spans one weekend) 4. Submit | Leave type = Sick, Reason = "Fever", Start = "2026-10-09" (Fri), End = "2026-10-12" (Mon) | System requires and accepts the reason (FR-2), computes 2 leave days (Fri + Mon, weekend excluded per BR-1), and creates the request successfully even though annual balance = 0 (BR-2 not applicable to Sick) | Positive (E2E) | High |

## 3. Ma trận truy vết (Requirement → Test Case)

| Requirement | Test Case IDs |
|---|---|
| FR-1 (3.1) | TC-CR-001, TC-CR-002, TC-CR-003, TC-CR-004, TC-CR-005, TC-CR-006, TC-CR-007, TC-CR-008, TC-CR-028, TC-CR-029, TC-CR-030 |
| FR-2 (3.1) | TC-CR-009, TC-CR-010, TC-CR-011, TC-CR-012, TC-CR-013, TC-CR-014, TC-CR-029, TC-CR-030 |
| FR-3 (3.1) | TC-CR-015, TC-CR-016, TC-CR-017, TC-CR-018, TC-CR-019, TC-CR-020, TC-CR-029, TC-CR-030 |
| FR-4 (3.1) | TC-CR-021, TC-CR-022, TC-CR-023, TC-CR-024, TC-CR-025, TC-CR-029 |
| BR-1 | TC-CR-015, TC-CR-016, TC-CR-017, TC-CR-018, TC-CR-019, TC-CR-020, TC-CR-029, TC-CR-030 |
| BR-2 | TC-CR-021, TC-CR-022, TC-CR-023, TC-CR-024, TC-CR-025, TC-CR-026, TC-CR-027, TC-CR-029, TC-CR-030 |

No requirement row is empty; every in-scope rule has at least one positive and one negative/boundary case.

## 4. Không test được vì thiếu thông tin

1. **FR-2 wording "...optional for others, etc."** — the trailing "etc." is ambiguous. It's unclear if this implies additional leave types beyond Annual/Sick/Unpaid, or additional undocumented reason-requirement rules. Cannot design a case for something undefined.
2. **End date earlier than start date** — the SRS never states expected system behavior (reject, auto-correct, or treat as 0/negative days). Not tested to avoid guessing the expected result.
3. **Past start dates** — whether an employee can submit a request with a start date in the past is not specified.
4. **Maximum duration of a single request** — no upper bound on number of days per request is defined (only the annual-balance limit via BR-2, which is separate from a per-request max).
5. **Whether a request that computes to 0 leave days (entire range on weekend) can be submitted at all** — BR-1 defines how days are excluded but not whether a 0-day request is a valid submission or should itself be blocked.
6. **FR-4 "12 annual leave days per year"** — unclear if this is prorated for employees joining mid-year, whether it resets calendar-year vs anniversary-date, and whether unused days carry over. This affects edge-case testing of BR-2 for new/partial-year employees.
7. **Role permissions for "Create request"** — Section 2 defines Employee/Manager/HR, but 3.1 only says "an employee." It is not specified whether Manager/HR can also create leave requests for themselves, or whether anyone can create a request on behalf of another employee. No role/permission matrix can be built without this.
8. **Definition of "weekend" and public holidays** — BR-1 excludes weekends only; whether public holidays are also excluded, and which days count as "weekend" (e.g., locale-specific Fri–Sat vs Sat–Sun), is not defined.
9. **Reason field constraints** — no max/min length or allowed character set is specified for the "reason" text field.

Recommend routing items 1–9 to **ba-requirements-challenger** for clarification before further test design.

---
No files were created; per your instruction, results are delivered directly in this response. Source reviewed: `<workdir>/test-case-writer/leave-request-srs.md`
