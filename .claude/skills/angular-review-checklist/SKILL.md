---
name: angular-review-checklist
description: Angular-specific review checklist (signals, input()/output()/model(), native control flow @if/@for with track, OnPush/zoneless change detection, inject(), subscriptions and DestroyRef, Signal Forms/Reactive Forms, PrimeNG usage, lazy routes, accessibility, tests) with version notes for Angular 20-22. Use when reviewing, self-checking or refactoring Angular components, services, templates or an Angular diff/MR, or when an agent such as code-reviewer or angular-expert needs the Angular rules. Not a reviewer role by itself (verdict and merge gate stay with the code-reviewer agent), not for React Native (react-native-feature-checklist) and not for security audits (security-reviewer agent).
---

# Angular review checklist

Skill này là **kiến thức/checklist**, không phải một "người review". Agent `code-reviewer`
(gác cổng merge) hoặc `angular-expert` (viết code) có thể nạp sẵn bằng frontmatter
`skills: [angular-review-checklist]`. Khi không có agent, main session dùng trực tiếp.

## Steps

1. **Xác định phiên bản** trước khi áp luật: `@angular/core` trong `package.json`
   (bản mới nhất trên npm: 22.2.0, kiểm tra 2026-09-28). Luật có ghi "v22+" chỉ áp khi dự án ≥ v22.
   Dự án cũ hơn: gợi ý nâng cấp là **ý kiến**, không phải lỗi.
2. **Đọc quy ước của dự án** (ESLint `@angular-eslint`, CLAUDE.md, CONTRIBUTING). Quy ước dự án
   thắng checklist này.
3. **Đi qua checklist** [references/checklist.md](references/checklist.md) theo thứ tự:
   Correctness → Reactivity & change detection → Templates → Components & DI → Forms →
   RxJS & memory → Routing & performance → PrimeNG → Accessibility → Tests.
4. **Chạy kiểm tra rẻ nếu có**: `npx ng lint`, `npx tsc -p tsconfig.app.json --noEmit`,
   test của phần thay đổi. Dán output thật, hoặc ghi "không chạy vì …".
5. **Báo cáo** theo bảng dưới; mỗi dòng trích mã luật (ví dụ `NG-T2`).

## Expected output

```
| # | Mức độ | File:dòng | Luật | Vấn đề | Đề xuất sửa |
|---|--------|-----------|------|--------|-------------|
| 1 | major  | src/app/cart/cart.ts:18 | NG-R3 | subscribe() không huỷ → rò rỉ | dùng toSignal() hoặc takeUntilDestroyed() |
```
Mức độ: blocker / major / minor / nit (cùng thang với agent code-reviewer).

## Quality checklist

- [ ] Đã ghi phiên bản Angular của dự án và chỉ áp luật hợp phiên bản.
- [ ] Mỗi phát hiện có file:dòng, mã luật, lý do, cách sửa cụ thể (có code nếu ngắn).
- [ ] Không báo lỗi phong cách mà linter của dự án đã cho phép.
- [ ] Lệnh kiểm tra: output thật hoặc ghi rõ chưa chạy.

Nguồn: Angular official LLM guidelines và style guide trong repo angular/angular
(commit `319a3c4`, MIT) — xem [references/checklist.md](references/checklist.md#nguồn-tham-khảo-sources).
