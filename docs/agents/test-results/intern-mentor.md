# Test result — intern-mentor

- Date: 2026-09-28
- Mode: real (headless `claude -p`)
- Delegated to: intern-mentor
- Correct agent triggered: yes
- Tools the subagent used: Glob, Grep, Read

## Prompt

Our intern asks what search.component.ts does and why switchMap instead of mergeMap. Explain it for a junior.

## Result (verbatim)

Here's the intern-mentor agent's full explanation:

### Ý tưởng đơn giản

File `search.component.ts` làm một việc: lắng nghe người dùng gõ vào ô search, rồi tự động gọi API tìm kiếm — nhưng gọi một cách "thông minh" để khỏi spam server và khỏi bị lag do gõ nhanh.

Nói đơn giản: mỗi lần bạn gõ một ký tự → code đợi bạn gõ xong (khoảng 0.3 giây) → kiểm tra từ khoá có hợp lệ không → mới gọi API.

### Ví dụ (từ code của bạn)

File: `/tmp/claude-0/-home-user-super-apps/dc3b63d6-198e-59e3-b3c8-1c8b388a1027/scratchpad/agent-tests/intern-mentor/search.component.ts`

```ts
results$ = this.searchControl.valueChanges.pipe(
  debounceTime(300),
  map((term) => term.trim()),
  distinctUntilChanged(),
  filter((term) => term.length >= 2),
  switchMap((term) => this.api.search(term).pipe(catchError(() => of([])))),
);
```

Đi từng bước (dòng 2-7), giả sử user gõ `"an"` rồi `"ang"`:

1. `valueChanges` (dòng 2): mỗi lần input thay đổi, phát ra 1 giá trị mới (`"a"`, `"an"`, `"ang"`...).
2. `debounceTime(300)` (dòng 3): chờ 300ms không gõ thêm mới cho giá trị đi tiếp. Gõ liên tục thì các giá trị tạm bị "nuốt", chỉ giá trị cuối cùng đi qua.
3. `map(term => term.trim())` (dòng 4): xoá khoảng trắng thừa đầu/cuối.
4. `distinctUntilChanged()` (dòng 5): nếu giá trị mới giống hệt giá trị trước (ví dụ gõ rồi xoá rồi gõ lại y hệt), không gọi lại API.
5. `filter(term => term.length >= 2)` (dòng 6): từ khoá dưới 2 ký tự thì bỏ qua, không tìm kiếm (tránh query rác kiểu `"a"`).
6. `switchMap(...)` (dòng 7): với từ khoá hợp lệ, gọi `this.api.search(term)` để lấy kết quả. `catchError(() => of([]))` đảm bảo nếu API lỗi thì trả về mảng rỗng thay vì làm chết cả stream.

Kết quả cuối `results$` là danh sách kết quả tìm kiếm, thường được bind ra template bằng `async` pipe.

### Đi sâu hơn: switchMap vs mergeMap

Trước khi giải thích, mình hỏi bạn trước: nếu bạn gõ `"angular"` rất nhanh, API gọi cho `"ang"` mất 2 giây (mạng chậm), còn API gọi cho `"angular"` mất 0.5 giây (query ngắn hơn, nhanh hơn) — cái nào trả lời về trước? Và nếu cả hai response đều được hiển thị theo thứ tự chúng về (không phải thứ tự gọi), chuyện gì xảy ra với kết quả trên màn hình?

Đây chính là **race condition**: request cũ (`"ang"`) trả lời **trễ hơn** request mới (`"angular"`), rồi ghi đè lên kết quả đúng.

Khác biệt cốt lõi:

- `mergeMap`: khi có giá trị mới (`term` mới) tới, nó **giữ nguyên** các request cũ đang chạy, và bắt đầu thêm request mới song song. Tất cả các response, dù request nào tạo ra, đều được emit ra khi chúng xong — không quan tâm thứ tự.
- `switchMap`: khi có giá trị mới tới, nó **huỷ (unsubscribe) ngay lập tức** request đang chạy dở của giá trị cũ, rồi mới bắt đầu request mới. Nghĩa là tại một thời điểm, chỉ có tối đa 1 request "đang sống".

Áp vào ví dụ trên:
- Với `mergeMap`: cả 2 request (`"ang"` và `"angular"`) đều chạy. Request `"ang"` xong sau (2s), nó emit kết quả của `"ang"` **sau cùng**, ghi đè lên kết quả đúng của `"angular"` đang hiển thị. → Người dùng gõ `"angular"` nhưng lại thấy kết quả của `"ang"`. Bug!
- Với `switchMap`: ngay khi `"angular"` được gõ (và pass qua debounce/filter), request `"ang"` bị huỷ luôn (HTTP request trong Angular sẽ tự động unsubscribe = huỷ). Nó không bao giờ emit kết quả nữa. Chỉ còn request `"angular"` chạy và trả kết quả đúng.

Đó là lý do live search luôn dùng `switchMap`: **chỉ quan tâm kết quả của lần tìm kiếm mới nhất**, các lần tìm kiếm cũ trở nên vô nghĩa nên nên huỷ luôn để tiết kiệm tài nguyên và tránh ghi đè sai.

Mẹo nhớ nhanh: 
- `switchMap` = "switch" sang cái mới, bỏ cái cũ → dùng cho search, autocomplete, hoặc bất cứ khi nào chỉ cần request mới nhất.
- `mergeMap` = giữ tất cả chạy song song → dùng khi cần tất cả kết quả đều quan trọng, ví dụ upload nhiều file cùng lúc.

### Góp ý (review)

**Khen**: Pipeline này đã theo đúng best-practice chuẩn cho search-as-you-type: có `debounceTime`, `distinctUntilChanged`, `filter` độ dài tối thiểu, và `catchError` để không làm sập stream khi API lỗi. Đây là một pattern rất sạch, nhiều dev senior viết y hệt vậy.

**Gợi ý 1 (nên thử)**: Có thể thêm loading state để UX tốt hơn — ví dụ set `isLoading = true` trước khi gọi `api.search()` và `false` khi xong, để người dùng biết đang tìm kiếm chứ không phải app bị đứng.

**Gợi ý 2 (nên thử)**: Nếu `term` rỗng hoàn toàn (user xoá hết), hiện tại `filter(length >= 2)` sẽ chặn nó lại, nghĩa là `results$` giữ nguyên kết quả cũ trên màn hình. Cân nhắc xem đó có phải hành vi mong muốn không, hay nên clear danh sách khi input rỗng.

**Câu hỏi**: Nếu `this.api.search(term)` không phải HTTP request mà là một WebSocket stream chạy mãi mãi (không tự kết thúc), `switchMap` có còn "huỷ" được nó không? Thử suy nghĩ xem `switchMap` unsubscribe hoạt động dựa trên cái gì.

### Bài tập nhỏ

Viết một đoạn RxJS giả lập (dùng `interval` và `delay` để test) chứng minh sự khác biệt giữa `switchMap` và `mergeMap`:

```ts
import { of, timer } from 'rxjs';
import { switchMap, mergeMap } from 'rxjs/operators';

const fakeApi = (term: string, delayMs: number) =>
  timer(delayMs).pipe(map(() => `Kết quả cho: ${term}`));

// Giả lập user gõ "ang" (chậm, 2000ms) rồi 100ms sau gõ "angular" (nhanh, 500ms)
```

Kỳ vọng: 
- Với `switchMap`: chỉ log ra `"Kết quả cho: angular"`.
- Với `mergeMap`: log ra cả `"Kết quả cho: angular"` VÀ sau đó `"Kết quả cho: ang"` (ghi đè sai).

### Lời giải

```ts
import { of, timer, from } from 'rxjs';
import { switchMap, mergeMap, delay } from 'rxjs/operators';

const terms$ = from([
  { term: 'ang', at: 0, apiDelay: 2000 },
  { term: 'angular', at: 100, apiDelay: 500 },
]);

// Dùng switchMap
of('ang', 'angular')
  .pipe(
    switchMap((term) =>
      timer(term === 'ang' ? 2000 : 500).pipe(map(() => `switchMap -> ${term}`))
    )
  )
  .subscribe(console.log);
// Output: chỉ "switchMap -> angular" (vì "ang" bị huỷ khi "angular" tới)

of('ang', 'angular')
  .pipe(
    mergeMap((term) =>
      timer(term === 'ang' ? 2000 : 500).pipe(map(() => `mergeMap -> ${term}`))
    )
  )
  .subscribe(console.log);
// Output: "mergeMap -> angular" (500ms) rồi "mergeMap -> ang" (2000ms) — ghi đè sai!
```

Chạy thử và quan sát thứ tự log — bạn sẽ thấy rõ ràng vì sao `switchMap` là lựa chọn đúng cho search.
