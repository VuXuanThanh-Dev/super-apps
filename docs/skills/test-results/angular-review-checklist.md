# Test result — `angular-review-checklist`

- Kết quả: **PASS — Skill tool triggered**
- Loại test: **real** (headless CLI `claude -p`, stream-json), chạy lúc 2026-09-28T15:07:41Z
- CLI: `2.1.283` · thư mục test mới, có đủ 10 skill của repo
  (`angular-review-checklist, code-sample-runner, csharp-review-checklist, handbook-chapter-writer, ocp-question-writer, react-native-feature-checklist, skill-creator, vietnamese-pdf-builder, vocabulary-extractor, webapp-testing`) + 33 skill có sẵn của môi trường (built-in/plugin, ví dụ `anthropic-skills:pdf`)
- Fixture: `test-fixtures/angular-review-checklist`
- Kết thúc: `success`, 14 turns, 70 s

## Prompt
```text
Please review src/app/cart.component.ts in this Angular 22 project and list the problems with file:line and fixes. Do not edit files.
```

## Bằng chứng kích hoạt (tool_use "Skill" trong stream)
```json
[
 {
  "id": "toolu_0181TmPdbs6zcqXmGRwj1H9K",
  "input": {
   "skill": "angular-review-checklist"
  }
 }
]
```

Thứ tự tool đã gọi: `Skill → Read → Read → Read → Glob → Glob → Glob → Grep → Glob → Glob → Glob → Bash`

## File thay đổi trong thư mục test
```text
(none)
```

## Câu trả lời cuối của Claude (nguyên văn)
No `tsconfig.json`, `node_modules`, or lint config exist, so `ng lint`/`tsc` can't run here — noting that instead of attempting.

Project uses Angular 22.2.0 / PrimeNG 22.1.1, so all "v22+" rules in the checklist apply fully (OnPush and standalone are now defaults, signal-based inputs/forms are current, etc). No CLAUDE.md or ESLint config was found to override the checklist.

## Findings — src/app/cart.component.ts

| # | Mức độ | File:dòng | Luật | Vấn đề | Đề xuất sửa |
|---|--------|-----------|------|--------|-------------|
| 1 | blocker | cart.component.ts:26-28 | NG-R3 | `ngOnInit` gọi `subscribe()` thủ công và không bao giờ huỷ — mỗi lần component bị destroy vẫn còn một subscription sống, rò rỉ bộ nhớ và có thể set `items` trên component đã chết. | Dùng `items = toSignal(this.cart.items$(this.userId), { initialValue: [] })` thay vì subscribe thủ công; hoặc nếu bắt buộc subscribe thì thêm `takeUntilDestroyed()`. |
| 2 | major | cart.component.ts:38-41 | NG-X1 | `remove()` lồng `subscribe` bên trong `subscribe` (gọi lại `items$` sau khi `remove` xong) — anti-pattern, khó test, không huỷ được đúng cách, dễ race condition nếu người dùng bấm remove nhiều lần liên tiếp. | Dùng `switchMap`/`exhaustMap`: `this.cart.remove(item.id).pipe(exhaustMap(() => this.cart.items$(this.userId)))` rồi subscribe một lần (hoặc chuyển qua `toSignal`/service state cập nhật signal nội bộ). |
| 3 | major | cart.component.ts:38-41 | NG-X2 | Lỗi từ `cart.remove(item.id)` (vd. lỗi mạng/HTTP) bị nuốt im lặng — không `catchError`, người dùng không biết thao tác xoá thất bại. | Thêm `catchError` để hiển thị lỗi cho người dùng hoặc log lại, không để observable âm thầm không emit. |
| 4 | major | cart.component.ts:11-12 | NG-T1 | Dùng `*ngIf` / `*ngFor` thay vì control flow gốc `@if` / `@for` (code mới ở Angular 22). | Thay bằng `@if (items().length > 0) { ... } @else { ... }` và `@for (item of items(); track item.id) { ... }`. |
| 5 | major | cart.component.ts:12 | NG-T2 | `*ngFor` không có `trackBy`/`track` — khi danh sách thay đổi (xoá item ở giữa), Angular re-render lại toàn bộ DOM thay vì chỉ phần tử liên quan. | Khi chuyển sang `@for`, bắt buộc `track item.id`. |
| 6 | major | cart.component.ts:21 | NG-K2 | Dùng decorator `@Input() userId: any` thay vì API `input()` mới; cũng không có kiểu hay giá trị mặc định. | `userId = input<string>()` (hoặc `input.required<string>()` nếu bắt buộc), gõ kiểu đúng thay vì `any`. |
| 7 | major | cart.component.ts:21 | NG-C2 | `userId: any` — bỏ qua toàn bộ kiểm tra kiểu; `items$(this.userId)` có thể nhận `undefined`/kiểu sai mà compiler không báo. | Đặt kiểu cụ thể (`string`/`number`) cho `userId`, tránh `any`. |
| 8 | major | cart.component.ts:21, 27 | NG-C1 | Không có input bắt buộc/giá trị mặc định cho `userId`; nếu component render trước khi `userId` được set, `ngOnInit` gọi `items$(undefined)` mà không kiểm tra. | Dùng `input.required<string>('userId')` để Angular đảm bảo giá trị tồn tại trước khi dùng, hoặc kiểm tra `if (!this.userId) return;`. |
| 9 | major | cart.component.ts:22, 27, 40 | NG-R1 | `items` là property thường được gán thủ công trong callback `subscribe`, không phải `signal()`/`toSignal()` — phá vỡ mô hình reactive, dễ quên `markForCheck` (may không tệ vì OnPush + async re-render nhưng không đúng pattern signal-based state). | Chuyển `items` thành `signal<CartItem[]>([])` hoặc lấy trực tiếp từ `toSignal(this.cart.items$(...))`. |
| 10 | major | cart.component.ts:12 | NG-A2 | Phần tử bấm được (xoá item) là `<div (click)>` thay vì `<button>` — không focus/keyboard-accessible, không có `aria-label`. | Đổi thành `<button type="button" (click)="remove(item)">...</button>` hoặc thêm `role="button"` + `tabindex="0"` + xử lý `keydown.enter`. |
| 11 | minor | cart.component.ts:12 | NG-T4 | Dùng `[ngClass]="{ 'sale': item.onSale }"` thay vì binding trực tiếp. | `[class.sale]="item.onSale"`. |
| 12 | minor | cart.component.ts:13, 15 | NG-T3 | Gọi hàm trong template: `formatPrice(item.price * item.qty)` và `total()` được tính lại mỗi lần change detection chạy (kể cả khi giá trị không đổi). | Chuyển `total` thành `computed(() => ...)`; với `formatPrice` dùng pure pipe (`{{ (item.price*item.qty) | currency }}`) hoặc `computed` theo item nếu danh sách nhỏ. |
| 13 | minor | cart.component.ts:2, 8 | NG-K5 | Import cả `CommonModule` thay vì import đúng directive/pipe cần dùng (đặc biệt sau khi bỏ `*ngIf`/`*ngFor` thì không cần `CommonModule` nữa). | Bỏ `CommonModule`; nếu cần pipe (vd `CurrencyPipe`) thì import riêng lẻ. |
| 14 | minor | cart.component.ts:24 | NG-K4 | Inject qua constructor (`constructor(private cart: CartService)`) thay vì hàm `inject()` theo khuyến nghị mới. | `private cart = inject(CartService);`. |
| 15 | nit | cart.component.ts:7 | NG-K1 | `standalone: true` được khai báo tường minh dù ở Angular 22 đây là mặc định. | Xoá field `standalone: true`. |
| 16 | nit | cart.component.ts:9 | NG-R6 | `changeDetection: ChangeDetectionStrategy.OnPush` khai báo tường minh dù ở v22+ đây là mặc định. | Xoá field này (hoặc giữ nếu team muốn tường minh — kiểm tra quy ước dự án, ở đây không có ESLint/CLAUDE.md nên coi là nit). |
| 17 | minor | cart.component.ts:38-41 | NG-K8 | Logic nghiệp vụ (gọi lại toàn bộ `items$` sau khi xoá) nằm trong component thay vì để service tự cập nhật state (vd. service giữ signal nội bộ và cập nhật sau khi xoá thành công). | Chuyển state cart vào service dưới dạng `signal`, component chỉ gọi `cart.remove(id)` và đọc `cart.items` (signal) qua `toSignal`/trực tiếp. |

Cheap checks not run: no `tsconfig.json`, `node_modules`, or `cart.service.ts` exist in this project snapshot, so `npx tsc --noEmit` and `npx ng lint` can't execute — skipped rather than fabricated.

Highest priority: #1 (unhandled subscription leak) and #2/#3 (nested subscribe + swallowed error) are the real bugs; #4-#10 are Angular-22-idiom violations worth fixing before merge.
