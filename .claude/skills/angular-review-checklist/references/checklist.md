# Angular checklist (mã luật)

Viết lại bằng lời của mình. **[O]** = lấy từ tài liệu chính thức của Angular (xem Nguồn); luật không có
[O] là kinh nghiệm thực hành chung (vẫn nên áp dụng, nhưng mức độ thường là minor/ý kiến).
"v22+" = chỉ áp khi dự án dùng Angular 22 trở lên (theo tài liệu chính thức).

## C — Correctness
- **NG-C1** Không truy cập giá trị có thể `undefined` mà không kiểm tra (`?.`, `@if`, giá trị mặc định cho `input()`).
- **NG-C2** [O] Không dùng `any`; dùng `unknown` rồi thu hẹp kiểu. Bật `strict` trong tsconfig.
- **NG-C3** [O] Không giả định biến toàn cục (`window`, `document`, `new Date()`) trong template; SSR sẽ lỗi.

## R — Reactivity & change detection
- **NG-R1** [O] State cục bộ dùng `signal()`; giá trị suy ra dùng `computed()`, không tính lại trong template.
- **NG-R2** [O] Cập nhật signal bằng `set`/`update`, không đột biến object bên trong (`mutate` không dùng).
- **NG-R3** Mọi `subscribe()` thủ công phải có cách huỷ: ưu tiên `toSignal()` hoặc `async` pipe;
  nếu buộc subscribe thì `takeUntilDestroyed()` / `DestroyRef`.
- **NG-R4** [O] State phụ thuộc nhiều nguồn mà phải đồng bộ → `linkedSignal()` thay vì `effect()` ghi signal.
- **NG-R5** `effect()` chỉ cho side effect ra ngoài (log, localStorage, DOM bên thứ ba), không để đồng bộ state.
- **NG-R6** [O] v22+: `OnPush` là mặc định → **không** cần khai báo `changeDetection: OnPush`. Dự án cũ hơn:
  component mới nên dùng `OnPush`.

## T — Templates
- **NG-T1** [O] Dùng control flow gốc `@if` / `@for` / `@switch`, không `*ngIf` / `*ngFor` / `*ngSwitch` ở code mới.
- **NG-T2** `@for` luôn có `track` theo khoá ổn định (`track item.id`), không `track $index` khi danh sách thay đổi thứ tự.
- **NG-T3** [O] Không gọi hàm nặng trong template; đưa vào `computed()` hoặc pure pipe.
- **NG-T4** [O] Dùng binding `[class.x]` / `[style.y]` thay cho `ngClass` / `ngStyle`.
- **NG-T5** [O] Ảnh tĩnh dùng `NgOptimizedImage` (`ngSrc`), trừ ảnh base64 inline.

## K — Components & DI
- **NG-K1** [O] Standalone component; **không** ghi `standalone: true` (mặc định); không NgModule cho code mới.
- **NG-K2** [O] Dùng `input()`, `output()`, `model()` (hai chiều) thay cho `@Input`/`@Output`.
- **NG-K3** [O] Host binding/listener đặt trong `host: {}` của decorator, không `@HostBinding`/`@HostListener`.
- **NG-K4** [O] Dùng `inject()` thay cho inject qua constructor.
- **NG-K5** [O] Không import `CommonModule`; import đúng pipe/directive cần (`DatePipe`, `AsyncPipe`…).
- **NG-K6** [O] Thành viên chỉ template dùng → `protected`; không đổi → `readonly`.
- **NG-K7** [O] Service singleton: `providedIn: 'root'`; v22+: ưu tiên decorator `@Service` cho service singleton mới.
- **NG-K8** [O] Component nhỏ, một trách nhiệm; logic nghiệp vụ nằm ở service, component lo hiển thị.

## F — Forms
- **NG-F1** [O] v22+: form mới ưu tiên Signal Forms (`@angular/forms/signals`). Không dùng được → Reactive Forms,
  tránh template-driven cho form phức tạp.
- **NG-F2** Validation có thông báo lỗi hiển thị và gắn `aria-describedby` với ô nhập.

## X — RxJS & memory
- **NG-X1** Không lồng `subscribe` trong `subscribe`; dùng `switchMap`/`concatMap`/`exhaustMap` đúng ngữ nghĩa
  (tìm kiếm → `switchMap`; lưu tuần tự → `concatMap`; chặn bấm nhiều lần → `exhaustMap`).
- **NG-X2** HTTP lỗi phải được xử lý (catchError / hiển thị cho người dùng), không nuốt lỗi im lặng.

## P — Routing & performance
- **NG-P1** [O] Route tính năng lazy-load (`loadComponent` / `loadChildren`).
- **NG-P2** Danh sách dài: `@for` + `track`, cân nhắc virtual scroll; khối nặng: `@defer`.

## N — PrimeNG
- **NG-N1** Phiên bản `primeng` tương thích với phiên bản Angular của dự án (xem trang cài đặt PrimeNG của đúng bản).
- **NG-N2** Không sửa style PrimeNG bằng `::ng-deep` rải rác; dùng theme/design token hoặc `styleClass`/pass-through.
- **NG-N3** Bảng lớn (`p-table`) dùng lazy loading/phân trang phía server khi dữ liệu nhiều.

## A — Accessibility
- **NG-A1** [O] Qua kiểm tra AXE; đạt WCAG AA (focus, tương phản màu, ARIA).
- **NG-A2** Phần tử bấm được là `<button>`/`<a>`, không `<div (click)>`; icon-only button có `aria-label`.

## S — Tests
- **NG-S1** Logic mới có unit test; test kiểm tra hành vi (DOM/đầu ra), không kiểm tra chi tiết nội bộ.
- **NG-S2** [O] Tên file test = tên file + `.spec.ts`.

## Nguồn tham khảo (Sources)
- Angular LLM guidelines (nguồn của angular.dev/ai): https://github.com/angular/angular/blob/319a3c4f3268f4f96ac4acdbb118737d2261e0be/adev/src/context/guidelines.md (mở 2026-09-28)
- Angular style guide (nguồn): https://github.com/angular/angular/blob/319a3c4f3268f4f96ac4acdbb118737d2261e0be/adev/src/content/best-practices/style-guide.md (mở 2026-09-28)
- Phiên bản: `npm view @angular/core version` → 22.2.0; `npm view primeng version` → 22.1.1 (2026-09-28)
