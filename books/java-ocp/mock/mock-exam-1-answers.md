# Đáp án đề thi thử số 1

Đề: [mock-exam-1.md](mock-exam-1.md). Đậu khi đúng ≥ 34/50 câu (68%).

## Bảng đáp án nhanh

M1-01: D · M1-02: A · M1-03: C · M1-04: B · M1-05: D · M1-06: A · M1-07: C · M1-08: B · M1-09: D · M1-10: A · M1-11: C · M1-12: A,D · M1-13: B · M1-14: D · M1-15: A · M1-16: C · M1-17: D · M1-18: D · M1-19: A,B,D · M1-20: A · M1-21: C · M1-22: B · M1-23: D · M1-24: A · M1-25: C · M1-26: B · M1-27: D · M1-28: A · M1-29: B,D · M1-30: C · M1-31: B · M1-32: D · M1-33: A · M1-34: C · M1-35: B · M1-36: D · M1-37: A · M1-38: C · M1-39: B · M1-40: D · M1-41: A · M1-42: C · M1-43: B · M1-44: D · M1-45: A · M1-46: C · M1-47: A,C · M1-48: B · M1-49: D · M1-50: A

## Giải thích

### Câu M1-01 — Đáp án: **D** (Vừa · objective 3.5)

- **Vì sao đúng:** Overload được chọn **lúc biên dịch** theo kiểu tĩnh của tham số; override được chọn **lúc chạy** theo object. `a.m(o)`: `o` kiểu `Object` → `m(Object)`, bị `B` override → `BO`. `a.m("x")` → `m(String)` (không bị override) → `AS`. `a.m(null)` → chọn bản cụ thể nhất `m(String)` → `AS`.
- **A sai:** Chọn overload dựa trên kiểu tĩnh của tham số; `"x"` và `null` chọn `m(String)`.
- **B sai:** `m(Object)` bị `B` override, nên lời gọi với `Object` in `BO`.
- **C sai:** `null` khớp cả hai overload; compiler chọn `m(String)` vì cụ thể hơn.
- *Kiểm chứng:* `examples/questions/mock1/QM1_01/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-02 — Đáp án: **A** (Vừa · objective 1.2)

- **Vì sao đúng:** `x++` cho 10 (x = 11), `++x` cho 12 (x = 12); `12 * 2L = 24`; `y = 10 + 24 = 34`. `y / 4` là phép chia **long** (= 8) rồi mới đổi sang `double` → `8.0`.
- **B sai:** `y / 4` chia hai số nguyên (long) trước khi gán cho `double`.
- **C sai:** `x` tăng hai lần (`x++` và `++x`) → 12.
- **D sai:** `++x` cho 12, không phải 11: 10 + 12 * 2 = 34.
- *Kiểm chứng:* `examples/questions/mock1/QM1_02/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-03 — Đáp án: **C** (Vừa · objective 6.1)

- **Vì sao đúng:** Giữ các từ 5 ký tự: delta, alpha, bravo → ký tự đầu d, a, b → sắp xếp giảm dần d, b, a → nối lại `dba`.
- **A sai:** `sorted(Comparator.reverseOrder())` sắp xếp lại, không giữ thứ tự gặp.
- **B sai:** Đây là thứ tự tăng dần; comparator là `reverseOrder()`.
- **D sai:** `charlie` có 7 ký tự nên bị loại.
- *Kiểm chứng:* `examples/questions/mock1/QM1_03/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-04 — Đáp án: **B** (Vừa · objective 2.1, 3.5)

- **Vì sao đúng:** Switch trên sealed interface phủ đủ `Circle` và `Rect` (mỗi loại có một case không guard) nên không cần `default`. Guard được kiểm tra theo thứ tự: Circle(5) → `circle`, Rect(2,2) → `square`, Circle(11) → `big circle`, Rect(1,3) → `rect`.
- **A sai:** Rect(2, 2) thoả guard `w == h` nên là `square`.
- **C sai:** Sealed type + các case không guard cho mọi lớp con → switch đầy đủ.
- **D sai:** Circle(11) thoả guard `c.r() > 10`.
- *Kiểm chứng:* `examples/questions/mock1/QM1_04/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-05 — Đáp án: **D** (Khó · objective 3.2)

- **Vì sao đúng:** Lớp `Order` được khởi tạo trước khi `main` chạy: static field và static block theo thứ tự xuất hiện (`s1`, `sb`). Mỗi `new Order()`: field và instance block theo thứ tự xuất hiện (`i1`, `ib`), rồi constructor (`c`).
- **A sai:** Khởi tạo static của lớp chứa `main` xảy ra trước khi `main` chạy.
- **B sai:** Có hai lần `new Order()`, mỗi lần chạy lại phần khởi tạo instance.
- **C sai:** Field `i` khai báo trước instance block nên chạy trước.
- *Kiểm chứng:* `examples/questions/mock1/QM1_05/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-06 — Đáp án: **A** (Vừa · objective 5.1)

- **Vì sao đúng:** `computeIfAbsent` tạo list mới khi key chưa có và **trả về list hiện có** khi đã có, nên các số được cộng dồn. `TreeMap` sắp xếp key. `getOrDefault("z", List.of())` trả về list rỗng → size 0.
- **B sai:** `TreeMap` sắp xếp key theo thứ tự tự nhiên: a, b, c.
- **C sai:** `computeIfAbsent` không thay list cũ bằng list mới.
- **D sai:** `getOrDefault` trả về giá trị mặc định (list rỗng), gọi `size()` được 0.
- *Kiểm chứng:* `examples/questions/mock1/QM1_06/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-07 — Đáp án: **C** (Vừa · objective 4.1)

- **Vì sao đúng:** Biểu thức sau `return` được tính **trước** khi `finally` chạy: `toString()` tạo một `String` mới (`tur`, `tc`). `finally` sửa `sb` nhưng không đổi chuỗi đã được tạo để trả về.
- **A sai:** `String` trả về đã được tạo trước `finally`; `sb.append("f")` không ảnh hưởng tới nó.
- **B sai:** Cả hai lời gọi đều trả về `String` được tạo trước `finally`.
- **D sai:** `sb.append("r")` nằm trong biểu thức return, được tính trước khi trả về.
- *Kiểm chứng:* `examples/questions/mock1/QM1_07/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-08 — Đáp án: **B** (Khó · objective 3.6)

- **Vì sao đúng:** L1: kế thừa hai default `go()` không liên quan mà không override → lỗi. L3: kế thừa một default (`Walk`) và một abstract (`Fly`) cùng chữ ký từ hai interface không liên quan → "types Walk and Fly are incompatible", kể cả khi lớp là abstract. L2 override và chọn `Walk.super.go()`; L5 gọi `Walk.super` hợp lệ vì `E` implements trực tiếp `Walk`.
- **A sai:** L3 cũng lỗi: default và abstract cùng chữ ký từ hai interface khác nhau vẫn xung đột, dù lớp là abstract.
- **C sai:** L5 hợp lệ: `X.super.m()` dùng được với interface mà lớp implements trực tiếp.
- **D sai:** L1 lỗi (xung đột hai default) và L5 hợp lệ.
- **E sai:** L2 đã override `go()` nên hết xung đột.
- *Kiểm chứng:* `examples/questions/mock1/QM1_08/` — compile error confirmed at ['L1', 'L3'] (`python3 tools/book.py questions mock1`).

### Câu M1-09 — Đáp án: **D** (Vừa · objective 8.1)

- **Vì sao đúng:** `submit(Callable)` → `Future<String>` với kết quả `A`. `submit(Runnable)` → `get()` trả về `null`. `invokeAll` giữ thứ tự task: phần tử 1 là 2. Sau `shutdown()`, `isShutdown()` là `true` (task đã gửi vẫn lấy kết quả được).
- **A sai:** `Future` của Runnable trả về `null`, và `null` được nối vào chuỗi.
- **B sai:** `fs.get(1)` là task thứ hai (trả về 2).
- **C sai:** `isShutdown()` là `true` ngay sau khi gọi `shutdown()`.
- *Kiểm chứng:* `examples/questions/mock1/QM1_09/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-10 — Đáp án: **A** (Vừa · objective 1.3)

- **Vì sao đúng:** `s.concat` không đổi `s` (bất biến). `sb`: `Java` → `Java21` → chèn `java` vào đầu → `javaJava21` → đảo ngược → `12avaJavaj` (10 ký tự).
- **B sai:** Kết quả của `s.concat("21")` không được gán lại.
- **C sai:** `insert(0, "java")` thêm 4 ký tự; tổng là 10.
- **D sai:** `reverse()` đã đảo ngược builder.
- *Kiểm chứng:* `examples/questions/mock1/QM1_10/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-11 — Đáp án: **C** (Khó · objective 6.2)

- **Vì sao đúng:** `groupingBy` với `TreeMap::new` → key sắp xếp: DN, HCM, HN. `maxBy` theo tuổi trả về `Optional<P>` người lớn tuổi nhất mỗi nhóm; `v.map(P::name)` lấy tên.
- **A sai:** `TreeMap` sắp xếp key tăng dần.
- **B sai:** `maxBy` chọn tuổi lớn nhất: HCM là Dung (40), HN là An (30).
- **D sai:** `v.map(P::name).orElse("-")` lấy ra chuỗi tên, không in `Optional`.
- *Kiểm chứng:* `examples/questions/mock1/QM1_11/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-12 — Đáp án: **A, D** (Vừa · objective 3.4)

- **Vì sao đúng:** A: `var` dùng được cho biến cục bộ và biến của for-each. D: `final var` hợp lệ.
- **B sai:** `x` đã được suy ra kiểu `int`; không gán `String` được.
- **C sai:** Biến cục bộ `field` che field cùng tên ngay từ chỗ khai báo; dùng nó trong chính initializer → "might not have been initialized".
- **E sai:** `var` không đi với `[]`.
- *Kiểm chứng:* `examples/questions/mock1/QM1_12/` — variants: AD satisfy compiles (`python3 tools/book.py questions mock1`).

### Câu M1-13 — Đáp án: **B** (Vừa · objective 9.3)

- **Vì sao đúng:** `resolve` nối thành `/app/config/../logs/./app.log`; `normalize` bỏ `.` và `config/..` → `/app/logs/app.log` (3 phần: app, logs, app.log). Từ `/app/config` tới đó: lên một cấp rồi vào `logs/app.log`.
- **A sai:** `normalize()` đã được gọi nên không còn `..` và `.`.
- **C sai:** `relativize` phải đi lên khỏi `config` trước: `../logs/app.log`.
- **D sai:** Gốc `/` không tính, còn 3 phần; và path bắt đầu bằng `/app`.
- *Kiểm chứng:* `examples/questions/mock1/QM1_13/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-14 — Đáp án: **D** (Dễ · objective 2.1)

- **Vì sao đúng:** Bỏ qua 0, 3, 6 (chia hết cho 3); cộng 1 + 2 + 4 + 5 + 7 = 19; tới 8 thì `break`.
- **A sai:** `break` khi `i > 7` nên 8 không được cộng (9 bị `continue` trước).
- **B sai:** 7 vẫn được cộng vì điều kiện dừng là `i > 7`.
- **C sai:** 0, 3, 6 bị `continue` nên không được cộng.
- *Kiểm chứng:* `examples/questions/mock1/QM1_14/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-15 — Đáp án: **A** (Khó · objective 5.1)

- **Vì sao đúng:** `subList` là **view** của list gốc: xoá/thêm qua view cũng xoá/thêm trong list gốc (thêm ở cuối view = trước phần tử 5). `base.set` không đổi cấu trúc (không đổi kích thước) nên view vẫn hợp lệ.
- **B sai:** `sub.remove(3)` xoá luôn trong `base`.
- **C sai:** `sub.add(9)` chèn vào vị trí cuối **của view** (trước 5), không phải cuối list gốc.
- **D sai:** Chỉ sửa cấu trúc list gốc trực tiếp (add/remove) mới làm view hỏng; `set` thì không.
- *Kiểm chứng:* `examples/questions/mock1/QM1_15/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-16 — Đáp án: **C** (Vừa · objective 3.1)

- **Vì sao đúng:** Trong `sum`: `x` = tham số (100), `this.x` = field của `Inner` (2), `Outer.this.x` = field của object ngoài `o` (10) → 112. `Nested` tạo một `Outer` mới nên `x` = 1. Lớp lồng truy cập được thành viên `private` của lớp ngoài.
- **A sai:** `Outer.this.x` là field của object `o` đã đổi thành 10.
- **B sai:** `Nested.get()` dùng một `Outer` **mới** (x = 1), không phải `o`.
- **D sai:** Tổng là 100 + 2 + 10 = 112.
- *Kiểm chứng:* `examples/questions/mock1/QM1_16/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-17 — Đáp án: **D** (Vừa · objective 7.1)

- **Vì sao đúng:** `requires static` = phụ thuộc **bắt buộc lúc biên dịch, tuỳ chọn lúc chạy**. Thiếu `com.opt` lúc chạy không làm hỏng việc khởi động; code chỉ lỗi nếu thực sự dùng tới lớp của nó (ở đây đã kiểm tra trước bằng `findModule`).
- **A sai:** Lúc biên dịch có `com.opt` nên biên dịch được.
- **B sai:** `FindException` xảy ra với `requires` thường, không với `requires static`.
- **C sai:** Lớp `Extra` không được nạp vì nhánh dùng nó không chạy.
- *Kiểm chứng:* `examples/questions/mock1/QM1_17/` — script output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-18 — Đáp án: **D** (Vừa · objective 1.4)

- **Vì sao đúng:** `plusDays` trên `Period` trả về Period mới `P1M1D` (không phải static). Cộng Period: tháng trước (31/1 → 29/2/2024, năm nhuận), rồi ngày (→ 1/3). Cách thứ hai: 1/2 + 1 tháng = 1/3. `MONTHS.between(31/1, 1/3)` chỉ đếm tháng **đủ**: 1.
- **A sai:** 31/1 + 1 tháng là 29/2 (không tràn), + 1 ngày là 1/3.
- **B sai:** Từ 31/1 tới 1/3 chưa đủ 2 tháng (ngày 1 < ngày 31).
- **C sai:** `plusDays(1)` là method instance, trả về `P1M1D`, nên có cộng thêm 1 ngày.
- *Kiểm chứng:* `examples/questions/mock1/QM1_18/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-19 — Đáp án: **A, B, D** (Vừa · objective 6.1)

- **Vì sao đúng:** A: `rangeClosed(1, 3)` gồm 3, nhân đôi rồi `boxed()`. B: `iterate` có điều kiện dừng (Java 9+). D: stream object.
- **C sai:** `range(1, 3)` không gồm 3 → `[2, 4]`.
- **E sai:** `IntStream` không có `toList()`; cần `boxed()` trước → lỗi biên dịch.
- *Kiểm chứng:* `examples/questions/mock1/QM1_19/` — variants: ABD satisfy output (`python3 tools/book.py questions mock1`).

### Câu M1-20 — Đáp án: **A** (Khó · objective 3.5)

- **Vì sao đúng:** Record không được `extends` (ngầm `extends Record`) → L5. `Bike` là `final` nên không có lớp con → L6. L3 `non-sealed` mở lại hệ thống kế thừa, nên L4 hợp lệ.
- **B sai:** L6 cũng lỗi: `Bike` là `final`.
- **C sai:** `Truck` là `non-sealed`, nên kế thừa nó (L4) là hợp lệ.
- **D sai:** `non-sealed` là modifier hợp lệ cho lớp con của sealed type.
- **E sai:** L5 cũng lỗi: record không có mệnh đề `extends`.
- *Kiểm chứng:* `examples/questions/mock1/QM1_20/` — compile error confirmed at ['L5', 'L6'] (`python3 tools/book.py questions mock1`).

### Câu M1-21 — Đáp án: **C** (Khó · objective 4.1)

- **Vì sao đúng:** Tài nguyên đóng theo thứ tự ngược: B rồi A (vẫn đóng A dù close B ném exception). Exception chính là `body`; hai exception từ `close()` được thêm vào suppressed theo thứ tự xảy ra: `cB`, `cA`.
- **A sai:** Thứ tự đóng là ngược thứ tự khai báo.
- **B sai:** Exception từ thân `try` là exception chính; exception của `close()` là suppressed.
- **D sai:** Cả hai lần `close()` đều ném exception → 2 suppressed.
- *Kiểm chứng:* `examples/questions/mock1/QM1_21/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-22 — Đáp án: **B** (Vừa · objective 10.2)

- **Vì sao đúng:** Đặt số chữ số thập phân tối thiểu 1 lớn hơn mức tối đa cũ (0) thì mức tối đa cũng thành 1 → 45.67% → `45.7%`. Làm tròn HALF_EVEN: 0.125 (đúng nửa) → `$0.12`; 0.135 trong nhị phân lớn hơn 0.135 một chút → `$0.14`.
- **A sai:** Chỉ có 1 chữ số thập phân; và 0.125 làm tròn HALF_EVEN về 0.12.
- **C sai:** 0.125 là đúng nửa → về số chẵn 0.12; 0.135 (double) hơi lớn hơn nửa → 0.14.
- **D sai:** `setMinimumFractionDigits(1)` buộc có ít nhất 1 chữ số thập phân.
- *Kiểm chứng:* `examples/questions/mock1/QM1_22/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-23 — Đáp án: **D** (Vừa · objective 3.3)

- **Vì sao đúng:** Giai đoạn 1 (chỉ widening): `f(1, 2)` và `f(1L, 2)` khớp `f(long, long)`. `f(\"a\", 1)` cần boxing `1` → giai đoạn 2 chọn `f(Object, Object)`. `f(1)` chỉ khớp varargs (giai đoạn 3).
- **A sai:** Widening `int → long` (giai đoạn 1) thắng boxing sang `Object`.
- **B sai:** `f(1L, 2)`: `2` nới rộng thành `long`, khớp `f(long, long)` ngay giai đoạn 1.
- **C sai:** Varargs chỉ được xét khi hai giai đoạn đầu thất bại.
- *Kiểm chứng:* `examples/questions/mock1/QM1_23/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-24 — Đáp án: **A** (Vừa · objective 8.2)

- **Vì sao đúng:** `incrementAndGet` là nguyên tử nên không mất cập nhật. `close()` của `ExecutorService` (try-with-resources) đợi mọi task xong trước khi đi tiếp. `getAndSet(0)` trả về giá trị **cũ** (1000) rồi đặt 0.
- **B sai:** `AtomicInteger` không bị race condition như `int++`.
- **C sai:** `getAndSet` trả về giá trị trước khi đặt.
- **D sai:** `close()` chờ các task hoàn thành.
- *Kiểm chứng:* `examples/questions/mock1/QM1_24/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-25 — Đáp án: **C** (Khó · objective 2.1)

- **Vì sao đúng:** L2: switch expression trên enum thiếu `HIGH` và không có `default` → không đầy đủ. L4: nhãn `case 1` bị lặp. L1 liệt kê đủ hằng enum; L3 dùng `yield` với dạng `:`; L5 là pattern switch có `default`.
- **A sai:** L4 cũng lỗi: hai nhãn case trùng giá trị.
- **B sai:** L5 hợp lệ; L2 thì lỗi.
- **D sai:** L5 hợp lệ: pattern switch trên `Object` có `default`.
- **E sai:** L3 hợp lệ; L2 lỗi.
- *Kiểm chứng:* `examples/questions/mock1/QM1_25/` — compile error confirmed at ['L2', 'L4'] (`python3 tools/book.py questions mock1`).

### Câu M1-26 — Đáp án: **B** (Vừa · objective 5.1)

- **Vì sao đúng:** [b, c] → offerFirst a → [a, b, c] → push z (đầu) → [z, a, b, c] → offerLast d → [z, a, b, c, d]. `pollLast` → d; `pop` (đầu) → z; `peekFirst` → a (không xoá); còn 3 phần tử.
- **A sai:** `pollLast()` được gọi trước, lấy `d` ở cuối.
- **C sai:** `pollLast` và `pop` đều xoá phần tử; `peekFirst` thì không → còn 3.
- **D sai:** `pop()` lấy phần tử đầu là `z`.
- *Kiểm chứng:* `examples/questions/mock1/QM1_26/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-27 — Đáp án: **D** (Vừa · objective 6.1)

- **Vì sao đúng:** `strip()` cho chuỗi rỗng → `filter` loại → Optional rỗng → `orElseGet` trả `EMPTY`. `ofNullable(null)` rỗng. `or(...)` chỉ dùng supplier khi Optional rỗng; `Optional.of("x")` có giá trị → `x`.
- **A sai:** `ofNullable(null)` là rỗng; và `or` giữ giá trị `x` sẵn có.
- **B sai:** `or` chỉ dùng khi Optional hiện tại rỗng.
- **C sai:** Sau `strip()` chuỗi rỗng bị `filter` loại.
- *Kiểm chứng:* `examples/questions/mock1/QM1_27/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-28 — Đáp án: **A** (Vừa · objective 3.7)

- **Vì sao đúng:** `op` in tên hằng (`PLUS`), rồi nối `sym`, kết quả `apply(3, 4)` (7 và 12) và `ordinal()` bắt đầu từ 0.
- **B sai:** `ordinal()` bắt đầu từ 0.
- **C sai:** `toString()` của enum trả về tên hằng, được in đầu tiên.
- **D sai:** `ordinal()` được nối ngay sau kết quả: `70`, `121`.
- *Kiểm chứng:* `examples/questions/mock1/QM1_28/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-29 — Đáp án: **B, D** (Dễ · objective 1.1)

- **Vì sao đúng:** B: `int` nới rộng thành `long`. D: `'a' + 1` là hằng số compile-time (98) vừa `char`.
- **A sai:** `long` không boxing thành `Integer`.
- **C sai:** `5` là `int`; không có nới-rộng-rồi-boxing thành `Double`.
- **E sai:** 40000 vượt quá `short` (tối đa 32767).
- *Kiểm chứng:* `examples/questions/mock1/QM1_29/` — variants: BD satisfy compiles (`python3 tools/book.py questions mock1`).

### Câu M1-30 — Đáp án: **C** (Vừa · objective 9.1)

- **Vì sao đúng:** Nội dung file: `ab\n1-c\nd`. `readAllLines` tách theo dòng: dòng cuối không có `\n` vẫn là một dòng. Không có dòng rỗng thừa.
- **A sai:** `print` không xuống dòng: `a` và `b` nằm cùng dòng.
- **B sai:** Dòng cuối `d` vẫn được đọc dù không có ký tự xuống dòng.
- **D sai:** Không có ký tự xuống dòng sau `d`, nên không có dòng rỗng.
- *Kiểm chứng:* `examples/questions/mock1/QM1_30/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-31 — Đáp án: **B** (Vừa · objective 4.1)

- **Vì sao đúng:** L1: multi-catch không được chứa hai kiểu có quan hệ cha-con. L3: catch `IOException` sau `Exception` → đã bị bắt. L2 hợp lệ; L4 gói exception vào unchecked là hợp lệ.
- **A sai:** L3 cũng lỗi (catch lớp con sau lớp cha).
- **C sai:** L2 hợp lệ vì `IOException` và `RuntimeException` không liên quan.
- **D sai:** L1 cũng lỗi (multi-catch có quan hệ kế thừa).
- **E sai:** L4 hợp lệ.
- *Kiểm chứng:* `examples/questions/mock1/QM1_31/` — compile error confirmed at ['L1', 'L3'] (`python3 tools/book.py questions mock1`).

### Câu M1-32 — Đáp án: **D** (Vừa · objective 3.5)

- **Vì sao đúng:** Các phần tử là `Integer`, `String`, `Double`, `Character`, `Long`. `Number` gồm `Integer`, `Double`, `Long` (không gồm `Character`). Giá trị > 1: 3.0 → 3 và 4L → 4 → tổng 7.
- **A sai:** 1 không thoả `> 1`.
- **B sai:** `Character` không phải `Number`.
- **C sai:** `'c'` không được cộng (Character không phải Number).
- *Kiểm chứng:* `examples/questions/mock1/QM1_32/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-33 — Đáp án: **A** (Khó · objective 8.1)

- **Vì sao đúng:** Kết quả được đọc theo thứ tự các `Future` trong list (x, y, z), không theo thứ tự hoàn thành. `close()` đợi mọi task xong nên `isDone()` là `true`. Biến của for-each là effectively final trong mỗi vòng.
- **B sai:** List `fs` giữ thứ tự submit; thứ tự hoàn thành không ảnh hưởng.
- **C sai:** Thứ tự duyệt `fs` là cố định.
- **D sai:** Biến for-each `s` không bị gán lại trong thân vòng lặp → effectively final.
- *Kiểm chứng:* `examples/questions/mock1/QM1_33/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-34 — Đáp án: **C** (Khó · objective 1.2)

- **Vì sao đúng:** `Math.round(-7.5)` = `floor(-7.0)` = -7. Cast `(int)` cắt về 0 → -7. `/` và `%` làm tròn về 0: -3 và -1. `floorDiv`/`floorMod` làm tròn xuống: -4 và 1.
- **A sai:** `Math.round` làm tròn nửa lên (về phía dương): -7.5 → -7.
- **B sai:** Cast `(int)` cắt phần thập phân (về 0), không làm tròn xuống; `-7 / 2` là -3.
- **D sai:** `floorDiv(-7, 2)` là -4 và `floorMod(-7, 2)` là 1 (cùng dấu với số chia).
- *Kiểm chứng:* `examples/questions/mock1/QM1_34/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-35 — Đáp án: **B** (Vừa · objective 6.2)

- **Vì sao đúng:** `concat` nối hai stream, `flatMap` tách chuỗi: x, y, z, y, w → `distinct` → x, y, z, w → `sorted` → w, x, y, z → `reduce` nối lại.
- **A sai:** `sorted()` sắp xếp lại theo bảng chữ cái.
- **C sai:** `distinct()` loại `y` trùng.
- **D sai:** `distinct()` và `sorted()` đều được áp dụng.
- *Kiểm chứng:* `examples/questions/mock1/QM1_35/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-36 — Đáp án: **D** (Vừa · objective 3.2)

- **Vì sao đúng:** `Base` chỉ có `Base(int)`. L2: constructor không gọi `super(...)` nên compiler thêm `super()` → không tồn tại. L4: default constructor ngầm cũng gọi `super()` → lỗi. L5: field `final` không được gán trong constructor.
- **A sai:** L5 cũng lỗi: field `final` phải được gán trong mọi constructor.
- **B sai:** L4 cũng lỗi: default constructor gọi `super()` ngầm.
- **C sai:** L2 cũng lỗi vì `super()` ngầm.
- **E sai:** L4 và L5 cũng lỗi.
- *Kiểm chứng:* `examples/questions/mock1/QM1_36/` — compile error confirmed at ['L2', 'L4', 'L5'] (`python3 tools/book.py questions mock1`).

### Câu M1-37 — Đáp án: **A** (Vừa · objective 7.2)

- **Vì sao đúng:** Nếu MANIFEST có `Automatic-Module-Name`, tên đó được dùng cho automatic module (tên file chỉ còn cung cấp version). Đây là cách thư viện giữ tên module ổn định trước khi có `module-info`.
- **B sai:** Tên suy ra từ file chỉ dùng khi **không** có `Automatic-Module-Name`.
- **C sai:** `-` không hợp lệ trong tên module.
- **D sai:** Version không nằm trong tên module.
- *Kiểm chứng:* `examples/questions/mock1/QM1_37/` — script output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-38 — Đáp án: **C** (Vừa · objective 5.1)

- **Vì sao đúng:** Lần 1: không phân biệt hoa thường → apple, Fig, pear; `null` cuối. Lần 2: thứ tự tự nhiên (hoa trước thường: Fig < apple < pear) đảo ngược → pear, apple, Fig; `null` đầu. `nullsFirst/Last` xử lý `null` nên không có NPE.
- **A sai:** Thứ tự tự nhiên đặt `Fig` (chữ hoa) **trước** `apple`; đảo ngược thì `Fig` đứng cuối.
- **B sai:** `CASE_INSENSITIVE_ORDER` so sánh không phân biệt hoa thường: apple < fig.
- **D sai:** `Comparator.nullsLast/nullsFirst` cho phép phần tử `null`.
- *Kiểm chứng:* `examples/questions/mock1/QM1_38/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-39 — Đáp án: **B** (Vừa · objective 3.6)

- **Vì sao đúng:** `a.then(b)` chạy `a` trước rồi `b`: (5 + 1) * 2 = 12; 5 * 2 + 1 = 11; id(0) + 1 = 1. Interface vẫn là functional interface vì chỉ có một method abstract (`calc`).
- **A sai:** `then` chạy hàm hiện tại trước, hàm tham số sau.
- **C sai:** `id().then(inc)` cộng 1 sau khi trả về 0.
- **D sai:** `dbl.then(inc)`: 5 * 2 + 1 = 11.
- *Kiểm chứng:* `examples/questions/mock1/QM1_39/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-40 — Đáp án: **D** (Vừa · objective 2.1)

- **Vì sao đúng:** `continue outer` với `do-while` nhảy tới phần kiểm tra điều kiện `count < 20`. Lần 1: count 1..4 → continue. Lần 2: 5..8 → continue. Lần 3: 9, rồi 10 → `10 > 9` → `break outer`.
- **A sai:** Vòng lặp dừng ngay khi count = 10.
- **B sai:** `break outer` thoát trước khi tới 20.
- **C sai:** Điều kiện là `count > 9`; với 9 thì chưa dừng.
- *Kiểm chứng:* `examples/questions/mock1/QM1_40/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-41 — Đáp án: **A** (Vừa · objective 10.1)

- **Vì sao đúng:** Với `de_CH`: không có `App_de_CH` nhưng có `App_de` → chọn `App_de` (không cần tới locale mặc định). Key `bye` không có trong `App_de` nên tìm lên bundle **cha** của nó là `App` (gốc) → `Bye`. Bundle `fr` không nằm trong chuỗi cha.
- **B sai:** Key thiếu được tìm trong bundle cha (`App`), không phải bundle của locale mặc định.
- **C sai:** Đã tìm thấy `App_de` nên không dùng locale mặc định.
- **D sai:** `bye` có trong bundle gốc.
- *Kiểm chứng:* `examples/questions/mock1/QM1_41/` — script output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-42 — Đáp án: **C** (Vừa · objective 3.4, 5.1)

- **Vì sao đúng:** `final` chỉ khoá biến `names`, list vẫn thêm được. `unmodifiableList` là view nên thấy cả `b` và `c` (3). Record copy list lúc tạo (khi đó có 2 phần tử) nên `members` có 2. (Local record trong method là hợp lệ.)
- **A sai:** View phản ánh mọi thay đổi của list gốc, kể cả `c`.
- **B sai:** `List.copyOf` tạo bản sao tại thời điểm tạo record.
- **D sai:** `view` không phải bản sao; nó thấy các phần tử thêm sau.
- *Kiểm chứng:* `examples/questions/mock1/QM1_42/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-43 — Đáp án: **B** (Khó · objective 1.4)

- **Vì sao đúng:** Cộng 2 giờ **thật**: 01:30 (UTC+2) → 02:30 (UTC+2) → vì đồng hồ lùi, thời điểm tiếp theo hiển thị là 02:30 (UTC+1). `Duration` giữa hai `ZonedDateTime` là 120 phút thật. Nhưng giờ địa phương chỉ chênh 1 giờ (01:30 → 02:30).
- **A sai:** Ngày đó có thêm một giờ (giờ 02:xx lặp lại) nên 2 giờ thật sau 01:30 là 02:30 lần hai.
- **C sai:** `Duration.between` trên `ZonedDateTime` đo thời gian thật: 120 phút.
- **D sai:** Giờ địa phương là 02:30 (offset +01:00), không phải 03:30.
- *Kiểm chứng:* `examples/questions/mock1/QM1_43/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-44 — Đáp án: **D** (Khó · objective 6.1, 3.6)

- **Vì sao đúng:** L5: `UnaryOperator<String>` phải trả về `String`, nhưng `s.length()` là `int`. L7: `Runnable.run()` là `void`, không `return 1` được. L6 hợp lệ: `Consumer` chấp nhận một biểu thức-câu-lệnh (giá trị bị bỏ). L3: `(s, i) -> s.charAt(i)`.
- **A sai:** L7 cũng lỗi: Runnable không trả về giá trị.
- **B sai:** L3 hợp lệ: `String::charAt` khớp `BiFunction<String, Integer, Character>` (unboxing/boxing).
- **C sai:** L6 hợp lệ; L5 lỗi.
- **E sai:** L6 hợp lệ: lời gọi method có thể dùng làm thân lambda `void`.
- *Kiểm chứng:* `examples/questions/mock1/QM1_44/` — compile error confirmed at ['L5', 'L7'] (`python3 tools/book.py questions mock1`).

### Câu M1-45 — Đáp án: **A** (Vừa · objective 8.3)

- **Vì sao đúng:** `sum` là reduction kết hợp nên đúng khi song song. `toList()` trên stream có thứ tự giữ encounter order dù song song. `count` không phụ thuộc thứ tự: 91..100 là 10 số.
- **B sai:** Stream từ `List` có thứ tự; `toList()` giữ đúng thứ tự gặp.
- **C sai:** `i > 90` gồm 91..100 → 10 phần tử.
- **D sai:** Phép cộng có tính kết hợp; `sum()` luôn cho cùng kết quả.
- *Kiểm chứng:* `examples/questions/mock1/QM1_45/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-46 — Đáp án: **C** (Khó · objective 9.2)

- **Vì sao đúng:** `Sub` là Serializable (kế thừa từ `Base`), nên cả `b` và `s` được lưu/khôi phục và **không** constructor/initializer nào của chúng chạy khi đọc. `t` là `transient` → 0. `st` là static, không được lưu → giữ giá trị hiện tại 40.
- **A sai:** `transient` không được lưu; `static` không được khôi phục từ file.
- **B sai:** Khi deserialize, initializer của lớp Serializable không chạy; giá trị lấy từ dữ liệu đã lưu.
- **D sai:** Static field thuộc lớp, không nằm trong dữ liệu serialize: giá trị hiện tại là 40.
- *Kiểm chứng:* `examples/questions/mock1/QM1_46/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-47 — Đáp án: **A, C** (Khó · objective 7.1)

- **Vì sao đúng:** Consumer cần đọc module chứa interface (`requires com.api`) và khai báo `uses com.api.Tax`. Thêm `requires com.impl` (C) là thừa nhưng vẫn hợp lệ.
- **B sai:** Thiếu `uses` → `ServiceLoader.load` ném `ServiceConfigurationError` lúc chạy (không in `rate=10`).
- **D sai:** Không `requires com.api` thì không nhìn thấy `com.api.Tax` → lỗi biên dịch.
- **E sai:** `provides` phải có `with <lớp cài đặt>`; và consumer vẫn thiếu `uses`.
- *Kiểm chứng:* `examples/questions/mock1/QM1_47/` — script variants: AC in ra 'rate=10' (`python3 tools/book.py questions mock1`).

### Câu M1-48 — Đáp án: **B** (Vừa · objective 4.1)

- **Vì sao đúng:** `finally` trong `load()` chạy trước khi exception rời method (in `F `). `main` bắt `AppEx`: message là `load failed`, cause là `NumberFormatException`.
- **A sai:** `finally` của `load()` chạy trước khi `main` bắt exception.
- **C sai:** `getCause()` là exception gốc được truyền vào constructor.
- **D sai:** `getMessage()` của `AppEx` là chuỗi truyền vào: `load failed`.
- *Kiểm chứng:* `examples/questions/mock1/QM1_48/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-49 — Đáp án: **D** (Vừa · objective 10.2)

- **Vì sao đúng:** `EEE` = thứ viết tắt, `MMM` = tháng viết tắt, `d`/`h` một chữ cái không thêm số 0, `mm` = phút 2 chữ số, `'at'` là văn bản nguyên văn (không in dấu nháy), `a` = AM/PM.
- **A sai:** `d` và `h` (một chữ cái) không đệm số 0.
- **B sai:** Tên đầy đủ cần `EEEE` và `MMMM`.
- **C sai:** Dấu nháy đơn chỉ đánh dấu văn bản, không được in ra.
- *Kiểm chứng:* `examples/questions/mock1/QM1_49/` — output confirmed (`python3 tools/book.py questions mock1`).

### Câu M1-50 — Đáp án: **A** (Khó · objective 3.5, 5.1)

- **Vì sao đúng:** Record tự sinh `equals` **và** `hashCode` theo component → hai `Pt(1, 2)` là một phần tử. `Pix` override `equals` nhưng **không** override `hashCode` → hai object có hash khác nhau nên `HashSet` giữ cả hai (vi phạm hợp đồng equals/hashCode). Tổng 3; `equals` vẫn trả về `true`.
- **B sai:** `HashSet` so sánh `hashCode` trước; `Pix` dùng `hashCode` mặc định (khác nhau) nên không bị coi là trùng.
- **C sai:** Record có `equals`/`hashCode` theo giá trị → hai `Pt` trùng nhau.
- **D sai:** `Pix.equals` được override và so sánh `x` → `true`.
- *Kiểm chứng:* `examples/questions/mock1/QM1_50/` — output confirmed (`python3 tools/book.py questions mock1`).

## Phân bố theo nhóm mục tiêu

| Nhóm | Số câu |
|---|---|
| 1 | 6 |
| 2 | 4 |
| 3 | 13 |
| 4 | 4 |
| 5 | 4 |
| 6 | 6 |
| 7 | 3 |
| 8 | 4 |
| 9 | 3 |
| 10 | 3 |
