# Đáp án đề thi thử số 2

Đề: [mock-exam-2.md](mock-exam-2.md). Đậu khi đúng ≥ 34/50 câu (68%).

## Bảng đáp án nhanh

M2-01: B · M2-02: D · M2-03: A · M2-04: C · M2-05: B · M2-06: D · M2-07: A · M2-08: C · M2-09: B · M2-10: D · M2-11: A · M2-12: C · M2-13: B · M2-14: D · M2-15: A · M2-16: C · M2-17: B · M2-18: D · M2-19: A · M2-20: C · M2-21: B · M2-22: D · M2-23: A · M2-24: A,C · M2-25: B · M2-26: D · M2-27: A · M2-28: A,B,E · M2-29: C · M2-30: B · M2-31: A · M2-32: D · M2-33: C · M2-34: B · M2-35: A,B · M2-36: A,C · M2-37: A · M2-38: D · M2-39: C · M2-40: B · M2-41: A · M2-42: B,C · M2-43: B · M2-44: D · M2-45: A · M2-46: D · M2-47: B,D · M2-48: C · M2-49: C · M2-50: B

## Giải thích

### Câu M2-01 — Đáp án: **B** (Vừa · objective 1.1)

- **Vì sao đúng:** 127 nằm trong cache → `a == b` là `true`. `Integer.equals(Long)` là `false` (khác kiểu). `a.intValue() == c`: `c` được unboxing và so sánh số → `true`. `c.equals(127L)`: `127L` boxing thành `Long` → `true`.
- **A sai:** `equals` của wrapper kiểm tra cả kiểu: `Integer` không bằng `Long`.
- **C sai:** So sánh `int == Long` unboxing `Long` rồi so sánh giá trị → `true`.
- **D sai:** 127 thuộc khoảng cache -128..127.
- *Kiểm chứng:* `examples/questions/mock2/QM2_01/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-02 — Đáp án: **D** (Vừa · objective 2.1)

- **Vì sao đúng:** Switch **expression** dạng `:` vẫn có fall-through: `'C'` in `C! ` rồi rơi xuống `case 'D'` và `yield 1`. Tổng 3 + 1 + 0 = 4. `C! ` được in trong lúc tính biểu thức, trước khi `println` in 4.
- **A sai:** `score('C')` có in `C! ` trước khi `yield`.
- **B sai:** `'C'` rơi xuống `case 'D'` và trả về 1, không phải 0.
- **C sai:** `'X'` vào `default` → 0; tổng là 4.
- *Kiểm chứng:* `examples/questions/mock2/QM2_02/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-03 — Đáp án: **A** (Khó · objective 3.2)

- **Vì sao đúng:** Compact constructor chuẩn hoá tham số trước khi gán field (-300 → -273.15). Accessor viết tay làm tròn khi **gọi** `celsius()` → 21.5, nhưng `equals`, `hashCode`, `toString` tự sinh dùng **giá trị field** (21.456 ≠ 21.4).
- **B sai:** `equals` của record so sánh field (21.456 và 21.4), không gọi accessor viết tay.
- **C sai:** Accessor làm tròn; và compact constructor đã đổi -300 thành -273.15.
- **D sai:** `toString()` tự sinh dùng field, không dùng accessor đã làm tròn.
- *Kiểm chứng:* `examples/questions/mock2/QM2_03/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-04 — Đáp án: **C** (Vừa · objective 5.1)

- **Vì sao đúng:** `floorKey(25)` = key lớn nhất ≤ 25 → 20; `ceilingEntry(25)` = entry có key nhỏ nhất ≥ 25 → `30=thirty`. `headMap(30)` không gồm 30. `tailMap(30, false)` loại 30. `descendingMap()` đảo thứ tự → key đầu là 40.
- **A sai:** `headMap(toKey)` mặc định loại trừ `toKey`.
- **B sai:** `floor` ≤, `ceiling` ≥; và `descendingMap` bắt đầu từ key lớn nhất.
- **D sai:** Tham số `false` của `tailMap` loại trừ key 30.
- *Kiểm chứng:* `examples/questions/mock2/QM2_04/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-05 — Đáp án: **B** (Vừa · objective 6.2)

- **Vì sao đúng:** Key trùng được gộp bằng `Integer::sum`: k → 4 + 4, a → 5 + 7. `LinkedHashMap` giữ thứ tự key được thêm lần đầu: k, a, b.
- **A sai:** `LinkedHashMap` giữ thứ tự chèn, không sắp xếp.
- **C sai:** Hàm merge cộng độ dài của các từ cùng chữ cái đầu.
- **D sai:** Có hàm merge nên key trùng không gây exception.
- *Kiểm chứng:* `examples/questions/mock2/QM2_05/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-06 — Đáp án: **D** (Khó · objective 3.3)

- **Vì sao đúng:** `f(null)`: `String` và `StringBuilder` không có quan hệ kế thừa, không cái nào cụ thể hơn → ambiguous. `g(null)` chọn `String` (cụ thể hơn `Object`). `h()` và `h(1)`: `int...` cụ thể hơn `long...` (vì `int` nới rộng được thành `long`). L5 có cast nên rõ ràng.
- **A sai:** `h()` không mơ hồ: `h(int...)` cụ thể hơn `h(long...)`.
- **B sai:** L3 và L4 đều chọn `h(int...)`.
- **C sai:** `String` là lớp con của `Object` nên `g(String)` được chọn.
- **E sai:** L1 mơ hồ giữa `String` và `StringBuilder`.
- *Kiểm chứng:* `examples/questions/mock2/QM2_06/` — compile error confirmed at ['L1'] (`python3 tools/book.py questions mock2`).

### Câu M2-07 — Đáp án: **A** (Khó · objective 1.3)

- **Vì sao đúng:** Sau khi bỏ thụt lề chung: dòng 1 `ab<TAB>c` (4 ký tự), dòng 2 `  d` nối với `e` (do `\` cuối dòng) → `  de` (4 ký tự), cộng 2 ký tự xuống dòng → 10 ký tự, 2 dòng. `indent(2)` thêm 2 dấu cách mỗi dòng → dòng đầu dài 6. `strip()` còn `x`.
- **B sai:** `\` ở cuối dòng nối `d` với `e`, nên chỉ có 2 dòng.
- **C sai:** `\t` là **một** ký tự tab; và chỉ có 2 ký tự xuống dòng.
- **D sai:** `indent(2)` thêm 2 dấu cách vào đầu dòng: 4 + 2 = 6.
- *Kiểm chứng:* `examples/questions/mock2/QM2_07/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-08 — Đáp án: **C** (Vừa · objective 4.1)

- **Vì sao đúng:** `return x` trong `catch` chốt giá trị 3. `finally` chạy trước khi method trả về: đổi biến thành 4 và in ra, nhưng giá trị trả về vẫn là 3.
- **A sai:** Giá trị primitive đã chốt khi `return` không bị `finally` thay đổi.
- **B sai:** `finally` chạy xong trước khi `f()` trả kết quả cho `println`.
- **D sai:** `finally` in giá trị sau khi gán `x = 4`.
- *Kiểm chứng:* `examples/questions/mock2/QM2_08/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-09 — Đáp án: **B** (Vừa · objective 8.1)

- **Vì sao đúng:** Lambda có `return` giá trị và ném checked exception → là `Callable`. Exception được gói trong `ExecutionException` (cause là `IOException`). Task đã kết thúc (dù thất bại) nên `isDone()` là `true`; `Future.state()` (Java 19+) là `FAILED`.
- **A sai:** `isDone()` là `true` cho cả trường hợp hoàn thành bình thường, lỗi hay bị huỷ.
- **C sai:** `getCause()` là exception gốc `IOException`.
- **D sai:** Task ném exception nên trạng thái là `FAILED`.
- *Kiểm chứng:* `examples/questions/mock2/QM2_09/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-10 — Đáp án: **D** (Dễ · objective 2.1)

- **Vì sao đúng:** `break` (không nhãn) chỉ thoát vòng **trong**. Hàng 1: 1 + 2; hàng 2: 3 rồi dừng ở 4; hàng 3: 5 + 6. Tổng 17.
- **A sai:** `break` không thoát vòng ngoài; hàng 3 vẫn được cộng.
- **B sai:** 4 không được cộng (break trước khi cộng).
- **C sai:** Hàng 3 (5 + 6) vẫn được cộng: 3 + 3 + 11 = 17.
- *Kiểm chứng:* `examples/questions/mock2/QM2_10/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-11 — Đáp án: **A** (Vừa · objective 3.5)

- **Vì sao đúng:** `p.who()` gọi bản override của `C`. Trong `C`, `name` là field của `C`, `super.name` là field của `P`. `super.who()` chạy code của `P`, nơi `name` là field của `P` (field không đa hình). `p.name` theo kiểu tham chiếu `P` → `P`.
- **B sai:** Trong method của `P`, `name` luôn là field của `P`; field không bị override.
- **C sai:** Truy cập field theo kiểu tham chiếu (`P`), không theo kiểu object.
- **D sai:** `who()` được override nên gọi bản của `C`.
- *Kiểm chứng:* `examples/questions/mock2/QM2_11/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-12 — Đáp án: **C** (Vừa · objective 3.6)

- **Vì sao đúng:** Method `static` của **interface** không được kế thừa sang lớp implements và không gọi được qua object; chỉ gọi bằng tên interface (`Tool.id()`). Default method `name()` gọi `id()` bên trong interface là hợp lệ.
- **A sai:** `h.id()` cũng lỗi: static method của interface không gọi qua object.
- **B sai:** `Hammer.id()` cũng lỗi: static method của interface không được kế thừa.
- **D sai:** `h.name()` gọi default method → hợp lệ.
- **E sai:** L3 và L4 lỗi.
- *Kiểm chứng:* `examples/questions/mock2/QM2_12/` — compile error confirmed at ['L3', 'L4'] (`python3 tools/book.py questions mock2`).

### Câu M2-13 — Đáp án: **B** (Vừa · objective 1.4)

- **Vì sao đúng:** 2024 là năm nhuận: 28/2 22:00 + 30 giờ = 29/2 22:00 + 6 giờ = 1/3 04:00 (UTC). `Duration.toString()` dùng giờ: `PT30H`. `toDaysPart()` = 1, `toHoursPart()` = phần giờ còn lại = 6.
- **A sai:** Không có ngày 30/2; `Instant` luôn là ngày hợp lệ.
- **C sai:** `Duration.toString()` không in phần ngày.
- **D sai:** `toDaysPart()` là số ngày (1), không phải tổng số giờ.
- *Kiểm chứng:* `examples/questions/mock2/QM2_13/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-14 — Đáp án: **D** (Vừa · objective 5.1)

- **Vì sao đúng:** `LinkedHashSet` giữ thứ tự chèn: [d, a, c, b]. `removeIf` xoá phần tử nhỏ hơn `b` → [d, c, b]. `retainAll` chỉ giữ phần tử có trong `other` → [d, c]. Thêm `a` vào cuối → [d, c, a].
- **A sai:** `LinkedHashSet` không sắp xếp; `a` mới thêm nằm cuối.
- **B sai:** `retainAll` loại `b` vì `other` không chứa `b`.
- **C sai:** Thứ tự chèn ban đầu giữ `d` trước `c`.
- *Kiểm chứng:* `examples/questions/mock2/QM2_14/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-15 — Đáp án: **A** (Vừa · objective 6.1)

- **Vì sao đúng:** `sorted()` là thao tác **có trạng thái (stateful)**: phải nhận hết phần tử (a3, a1, a2) rồi mới đẩy ra theo thứ tự đã sắp xếp. `limit(2)` dừng sau 1 và 2 nên không có `b3`.
- **B sai:** `sorted()` chặn lại cho tới khi nhận đủ phần tử; không có xử lý xen kẽ trước nó.
- **C sai:** `limit(2)` ngắt sau 2 phần tử.
- **D sai:** Peek đầu tiên thấy phần tử theo thứ tự nguồn (3, 1, 2).
- *Kiểm chứng:* `examples/questions/mock2/QM2_15/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-16 — Đáp án: **C** (Vừa · objective 3.1)

- **Vì sao đúng:** Trong lớp ẩn danh, field `name` của chính nó che biến cục bộ `name` của method bao ngoài. Vì vậy `name` và `this.name` đều là `anon`; `Anon.this.name` là field của object bên ngoài.
- **A sai:** Field của lớp ẩn danh che biến cục bộ cùng tên.
- **B sai:** `this` trong lớp ẩn danh là chính object ẩn danh.
- **D sai:** Biến cục bộ `local` bị che hoàn toàn.
- *Kiểm chứng:* `examples/questions/mock2/QM2_16/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-17 — Đáp án: **B** (Khó · objective 7.1)

- **Vì sao đúng:** **Qualified opens** `opens <package> to <module>` chỉ cho module được liệt kê dùng deep reflection. `exports` cho phép mọi module dùng kiểu public lúc biên dịch, nhưng không mở thành viên `private` cho reflection.
- **A sai:** `com.other` không có trong danh sách `to`, nên không được reflection vào `private`.
- **C sai:** `com.fw` được mở nên đọc được field.
- **D sai:** Một package có thể vừa được export vừa được open (có giới hạn hay không).
- *Kiểm chứng:* `examples/questions/mock2/QM2_17/` — script output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-18 — Đáp án: **D** (Vừa · objective 1.2)

- **Vì sao đúng:** Toán tử gán kết hợp tự ép kiểu về kiểu biến: `s = (short)(10 * 2.5)` = 25; `c = (char)(65 + 1.9)` = 66 (`B`, cắt phần lẻ); `b = 5 >> 1` = 2. `'a' + 'b'` là cộng số: 97 + 98 = 195. `(char)(66 + 1)` = `C`.
- **A sai:** Ép `double` → `char` cắt phần thập phân: 66.9 → 66 (`B`).
- **B sai:** Cộng hai `char` cho ra `int`, không nối chuỗi.
- **C sai:** `b` là `byte` nên kết quả vẫn là số nguyên.
- *Kiểm chứng:* `examples/questions/mock2/QM2_18/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-19 — Đáp án: **A** (Khó · objective 6.2)

- **Vì sao đúng:** `partitioningBy` + `summingDouble`: đã trả (100 + 25) và chưa trả (50 + 75) đều 125.0; map in `false` trước. `teeing` chạy hai collector (đếm = 4, trung bình = 62.5) rồi gộp kết quả.
- **B sai:** Map của `partitioningBy` in khoá `false` trước.
- **C sai:** `averagingDouble` tính trung bình, không phải tổng.
- **D sai:** Collector phụ là `summingDouble`, không phải `counting`.
- *Kiểm chứng:* `examples/questions/mock2/QM2_19/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-20 — Đáp án: **C** (Vừa · objective 3.7)

- **Vì sao đúng:** FRI có ordinal 4 → `values()[6]` = SUN. `compareTo` = hiệu ordinal: 4 - 0 = 4. Switch trên `this` trong enum dùng được tên hằng trực tiếp.
- **A sai:** `values()[4 + 2]` là phần tử thứ 7 (chỉ số 6): SUN.
- **B sai:** `FRI.compareTo(MON)` = 4 - 0, dương.
- **D sai:** FRI không thuộc `case SAT, SUN`.
- *Kiểm chứng:* `examples/questions/mock2/QM2_20/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-21 — Đáp án: **B** (Khó · objective 4.1)

- **Vì sao đúng:** Dạng `try (biến)` (Java 9+) cần biến final hoặc effectively final: `b` bị gán lại → L2 lỗi. Biến khai báo trong try-with-resources ngầm `final` → gán lại `c` là lỗi (L3). L1 và L4 hợp lệ (có thể trộn biến có sẵn và khai báo mới).
- **A sai:** L3 cũng lỗi: biến tài nguyên ngầm final.
- **C sai:** `a` effectively final nên L1 hợp lệ.
- **D sai:** L4 hợp lệ: `d` là final, `e` khai báo mới.
- **E sai:** L2 cũng lỗi vì `b` bị gán lại.
- *Kiểm chứng:* `examples/questions/mock2/QM2_21/` — compile error confirmed at ['L2', 'L3'] (`python3 tools/book.py questions mock2`).

### Câu M2-22 — Đáp án: **D** (Vừa · objective 9.3)

- **Vì sao đúng:** Các phần: usr(0), local(1), lib(2), java(3), tools.jar(4). `subpath(1, 3)` lấy chỉ số 1, 2 → `local/lib` (không có `/` đầu). `getName(3)` = `java`. `a/../b` chuẩn hoá thành `b`. Cha của cha là `/usr/local/lib` → tên `lib`.
- **A sai:** `subpath` bắt đầu từ chỉ số 1 (`local`).
- **B sai:** `subpath(1, 3)` không gồm chỉ số 3.
- **C sai:** `getNameCount() - 2` = 3 → `java`.
- *Kiểm chứng:* `examples/questions/mock2/QM2_22/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-23 — Đáp án: **A** (Khó · objective 3.5)

- **Vì sao đúng:** Cast `null` sang bất kỳ kiểu tham chiếu nào đều thành công. Cast một lớp **không final** sang interface biên dịch được (một lớp con của `Dog` có thể implements `Swimmer`), nhưng object thật là `Dog` → `ClassCastException` lúc chạy.
- **B sai:** Compiler chỉ cấm khi lớp nguồn là `final` và không implements interface.
- **C sai:** Object `Dog` không implements `Swimmer` → cast thất bại lúc chạy.
- **D sai:** Cast giá trị `null` luôn thành công, không có NPE.
- *Kiểm chứng:* `examples/questions/mock2/QM2_23/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-24 — Đáp án: **A, C** (Vừa · objective 2.1, 3.5)

- **Vì sao đúng:** Biến pattern chỉ dùng được nơi chắc chắn đã gán: vế phải của `&&` (A), và phía sau một `if` phủ định luôn `return` (C).
- **B sai:** Với `||`, vế phải chạy khi `instanceof` sai → `s` chưa được gán.
- **D sai:** `s` chỉ có phạm vi trong khối `if`.
- **E sai:** `i` chỉ có phạm vi trong biểu thức `&&`, không dùng được ở câu lệnh sau.
- *Kiểm chứng:* `examples/questions/mock2/QM2_24/` — variants: AC satisfy compiles (`python3 tools/book.py questions mock2`).

### Câu M2-25 — Đáp án: **B** (Khó · objective 5.1)

- **Vì sao đúng:** Sắp xếp giảm dần: [9, 5, 3, 1]. `Arrays.asList` là view ghi xuống mảng: `set(0, 7)` → [7, 5, 3, 1]; `reverse` trên view đảo luôn mảng → [1, 3, 5, 7]. Mảng giờ tăng dần nên `binarySearch(5)` = 2; `indexOf(7)` = 3.
- **A sai:** `view` và `arr` dùng chung dữ liệu: mọi thay đổi qua view đều sửa mảng.
- **C sai:** Sau khi đảo, 7 nằm ở cuối (chỉ số 3).
- **D sai:** `Collections.reverse(view)` cũng đảo mảng gốc.
- *Kiểm chứng:* `examples/questions/mock2/QM2_25/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-26 — Đáp án: **D** (Vừa · objective 8.2)

- **Vì sao đúng:** Khi `main` gọi `tryLock()` lần đầu, thread `t` đang giữ khoá → trả về `false` ngay (không chờ). Sau khi `t` nhả khoá và kết thúc, `tryLock()` thành công; `main` giữ khoá một lần.
- **A sai:** Lần đầu khoá đang bị `t` giữ nên `tryLock()` thất bại.
- **B sai:** Lần thứ hai khoá đã rảnh nên `tryLock()` thành công.
- **C sai:** Sau `tryLock()` thành công, khoá thuộc về `main`.
- *Kiểm chứng:* `examples/questions/mock2/QM2_26/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-27 — Đáp án: **A** (Dễ · objective 1.3)

- **Vì sao đúng:** `o` đầu tiên ở chỉ số 4, cuối cùng ở 8. `substring(7)` = `World`. `replace` thay mọi `l` → `HeLLo, WorLd`, ký tự thứ 3 là `L`. `contains` phân biệt hoa thường → `false`.
- **B sai:** `replace('l', 'L')` trả về chuỗi mới có `L` ở chỉ số 3.
- **C sai:** `lastIndexOf("o")` là 8 (trong `World`); `contains` phân biệt hoa thường.
- **D sai:** Chỉ số bắt đầu từ 0.
- *Kiểm chứng:* `examples/questions/mock2/QM2_27/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-28 — Đáp án: **A, B, E** (Vừa · objective 6.1)

- **Vì sao đúng:** Kết quả là thứ tự **độ dài tăng dần** (các độ dài đều khác nhau). A và B sắp xếp theo độ dài tăng. E: comparator "độ dài giảm dần" rồi `reversed()` → độ dài tăng dần.
- **C sai:** Thứ tự tự nhiên của chuỗi: `[apple, banana, fig, kiwi]`.
- **D sai:** `b.length() - a.length()` sắp xếp độ dài giảm dần.
- *Kiểm chứng:* `examples/questions/mock2/QM2_28/` — variants: ABE satisfy output (`python3 tools/book.py questions mock2`).

### Câu M2-29 — Đáp án: **C** (Vừa · objective 3.4)

- **Vì sao đúng:** Field `final` chỉ được gán một lần (trong constructor). L1 (`cents += c`) và L3 (`this.cur = c`) gán lại → lỗi. Cách đúng cho lớp bất biến là trả về object mới (L2).
- **A sai:** L3 cũng gán lại field `final`.
- **B sai:** L1 cũng gán lại field `final` (`+=` là phép gán).
- **D sai:** L2 chỉ đọc field và tạo object mới → hợp lệ.
- **E sai:** L1 và L3 gán lại field `final`.
- *Kiểm chứng:* `examples/questions/mock2/QM2_29/` — compile error confirmed at ['L1', 'L3'] (`python3 tools/book.py questions mock2`).

### Câu M2-30 — Đáp án: **B** (Vừa · objective 10.2)

- **Vì sao đúng:** `{2,number,percent}` định dạng 0.75 thành `75%`. Pattern `#.#` giữ một chữ số thập phân với HALF_EVEN: 2.55 kiểu `double` thật ra là 2.5499… → `2.5`. `integer` làm tròn 2.55 → 3.
- **A sai:** Kiểu con `percent` nhân 100 và thêm `%`; 2.55 (double) làm tròn một chữ số là 2.5.
- **C sai:** `integer` làm tròn 2.55 thành 3 (không cắt).
- **D sai:** Các tham số được thay thế vì không có dấu nháy đơn.
- *Kiểm chứng:* `examples/questions/mock2/QM2_30/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-31 — Đáp án: **A** (Vừa · objective 4.1, 3.6)

- **Vì sao đúng:** L3 ném checked exception rộng hơn (`Exception`) → lỗi. L4: method của interface ngầm `public`, cài đặt package-private là giảm quyền → lỗi. L5 hợp lệ vì gọi qua kiểu `A`, mà `A.load()` không khai báo `throws`.
- **B sai:** L4 cũng lỗi (giảm quyền truy cập).
- **C sai:** Kiểu tĩnh là `A`, không phải `Loader`, nên không phải xử lý `IOException` ở L5.
- **D sai:** L5 hợp lệ; L3 lỗi.
- **E sai:** L2 hợp lệ: ném exception hẹp hơn là được.
- *Kiểm chứng:* `examples/questions/mock2/QM2_31/` — compile error confirmed at ['L3', 'L4'] (`python3 tools/book.py questions mock2`).

### Câu M2-32 — Đáp án: **D** (Vừa · objective 6.2)

- **Vì sao đúng:** Làm phẳng: 1, 2, 3, 3, 4, 4, 5, 1 (8 phần tử) → `distinct` còn 1..5 (5 phần tử), tích = 120. Số phần tử trùng = 8 - 5 = 3.
- **A sai:** `distinct()` loại phần tử trùng trước khi nhân.
- **B sai:** `dup` là hiệu giữa tổng số và số phần tử khác nhau: 3.
- **C sai:** 5 là số phần tử khác nhau, không phải số phần tử trùng.
- *Kiểm chứng:* `examples/questions/mock2/QM2_32/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-33 — Đáp án: **C** (Khó · objective 9.3)

- **Vì sao đúng:** `maxDepth` 2 tính từ root (độ sâu 0): độ sâu 1 là `a.txt`, `b`; độ sâu 2 là `c.txt`, `d`. File thường trong phạm vi: `a.txt`, `c.txt`. `walk(root, 2)` gồm cả root: t, a.txt, b, c.txt, d → 5.
- **A sai:** `e.txt` và `f.log` ở độ sâu 3, vượt `maxDepth`.
- **B sai:** Độ sâu 2 gồm cả nội dung trực tiếp của `b`.
- **D sai:** `walk` gồm cả thư mục bắt đầu.
- *Kiểm chứng:* `examples/questions/mock2/QM2_33/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-34 — Đáp án: **B** (Vừa · objective 3.2)

- **Vì sao đúng:** Chỉ có 2 object được tạo (`c = b` chỉ copy tham chiếu) → `total` = 2. `c` và `b` là cùng object nên `b.mine` = 6. `a.total` truy cập field static qua biến (hợp lệ) → 2.
- **A sai:** `Counter c = b;` không tạo object mới.
- **C sai:** `c` và `b` trỏ cùng object, nên sửa qua `c` thấy ở `b`.
- **D sai:** `a` là object riêng, `mine` của nó vẫn là 1.
- *Kiểm chứng:* `examples/questions/mock2/QM2_34/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-35 — Đáp án: **A, B** (Khó · objective 7.2)

- **Vì sao đúng:** Để `-m <module>` chạy không cần tên lớp, JAR modular phải ghi lớp chính (`--main-class`, dạng ngắn `-e`). `-C dir .` đưa nội dung thư mục vào **gốc** JAR, nên `module-info.class` nằm đúng chỗ.
- **C sai:** Thiếu `--main-class`: `java -m com.run` báo không có lớp chính.
- **D sai:** Như C, không có lớp chính.
- **E sai:** Không có `-C`, file được thêm kèm tiền tố `out/com.run/`, nên `module-info.class` không ở gốc JAR.
- *Kiểm chứng:* `examples/questions/mock2/QM2_35/` — script variants: AB in ra 'run!' (`python3 tools/book.py questions mock2`).

### Câu M2-36 — Đáp án: **A, C** (Khó · objective 8.3)

- **Vì sao đúng:** A: `forEachOrdered` tôn trọng thứ tự gặp của nguồn có thứ tự. C: lời gọi `parallel()`/`sequential()` cuối cùng quyết định chế độ của cả pipeline.
- **B sai:** Với nguồn có thứ tự, `collect(toList())` giữ thứ tự gặp, kể cả song song.
- **D sai:** Phép trừ không kết hợp; kết quả song song phụ thuộc cách chia (trên máy kiểm tra: khác tuần tự).
- **E sai:** Tạo stream chỉ đọc dữ liệu, không sửa list, nên list bất biến vẫn dùng được.
- *Kiểm chứng:* `examples/questions/mock2/QM2_36/` — each option proven true/false by a program (`python3 tools/book.py questions mock2`).

### Câu M2-37 — Đáp án: **A** (Vừa · objective 1.4)

- **Vì sao đúng:** `Period.between` đếm tháng **đủ**: 30/11/2023 + 14 tháng = 30/1/2025, còn 29 ngày tới 28/2/2025 → `P1Y2M29D` (14 tháng). 30/11 đã là ngày cuối tháng. `withMonth(2)` giữ ngày 30 nếu được, nếu không lấy ngày cuối tháng 2 → 28.
- **B sai:** `Period.between` không tạo phần ngày âm; tháng chưa đủ thì bị trừ đi.
- **C sai:** Từ 30/1 tới 28/2/2025 là 29 ngày.
- **D sai:** `withMonth` điều chỉnh về ngày hợp lệ cuối cùng của tháng, không tràn sang tháng 3.
- *Kiểm chứng:* `examples/questions/mock2/QM2_37/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-38 — Đáp án: **D** (Khó · objective 3.6)

- **Vì sao đúng:** Quy tắc "**lớp thắng**" (class wins): method kế thừa từ lớp cha (`Base.greet`) được ưu tiên hơn default method của interface, nên không có xung đột. `Robot` override và gọi bản default qua `Named.super.greet()`.
- **A sai:** Method của lớp cha luôn thắng default method của interface.
- **B sai:** Không có xung đột vì method của lớp được ưu tiên.
- **C sai:** `Person` dùng `Base.greet()`; và `Robot` thêm `!`.
- *Kiểm chứng:* `examples/questions/mock2/QM2_38/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-39 — Đáp án: **C** (Vừa · objective 4.1)

- **Vì sao đúng:** `IllegalArgumentException` không khớp `catch (IllegalStateException)`. Trên đường thoát ra, `finally` của `b()` rồi của `a()` chạy. `main` bắt nó (là `RuntimeException`).
- **A sai:** Catch `IllegalStateException` không bắt `IllegalArgumentException`.
- **B sai:** `finally` của `b()` chạy trước (exception thoát từ trong ra ngoài).
- **D sai:** `main` có catch `RuntimeException` nên in thêm `main:x`.
- *Kiểm chứng:* `examples/questions/mock2/QM2_39/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-40 — Đáp án: **B** (Vừa · objective 5.1)

- **Vì sao đúng:** `List<? super Integer>` nhận list của `Integer` hoặc lớp cha (`Number`, `Object`); `Double` không phải lớp cha của `Integer` → L4. Không thêm được phần tử (trừ `null`) vào `List<? extends Number>` → L5. L2: `List.of(1.5, 2)` là list của một kiểu con chung của `Number` → hợp lệ.
- **A sai:** L5 cũng lỗi: không `add` được vào `? extends`.
- **C sai:** L2 hợp lệ: kiểu phần tử suy ra được là con của `Number`.
- **D sai:** L2 hợp lệ (xem C).
- **E sai:** L4 cũng lỗi: `ArrayList<Double>` không khớp `? super Integer`.
- *Kiểm chứng:* `examples/questions/mock2/QM2_40/` — compile error confirmed at ['L4', 'L5'] (`python3 tools/book.py questions mock2`).

### Câu M2-41 — Đáp án: **A** (Vừa · objective 10.1)

- **Vì sao đúng:** Locale yêu cầu là `en_GB`: không có `Msg_en_GB`, nhưng có `Msg_en` (cùng ngôn ngữ) → chọn nó; `getLocale()` của bundle là `en`. `Msg_en_US` là locale "anh em", không nằm trên đường tìm kiếm.
- **B sai:** `en_US` không phải cha của `en_GB`; chỉ `en` và gốc là cha.
- **C sai:** Đã tìm thấy `Msg_en` trước khi cần tới bundle gốc.
- **D sai:** Có bundle phù hợp (`Msg_en`).
- *Kiểm chứng:* `examples/questions/mock2/QM2_41/` — script output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-42 — Đáp án: **B, C** (Khó · objective 2.1)

- **Vì sao đúng:** B: guard trước case không guard cùng kiểu, và `case null, default` đứng cuối. C: `case null` riêng, `default` phủ phần còn lại.
- **A sai:** `default` (kể cả `case null, default`) không được đứng trước một case có pattern → case sau bị che (dominated).
- **D sai:** `case Integer i` không guard che mất case có guard phía sau.
- **E sai:** Selector `Object` mà không có `default` → switch không đầy đủ.
- *Kiểm chứng:* `examples/questions/mock2/QM2_42/` — variants: BC satisfy compiles (`python3 tools/book.py questions mock2`).

### Câu M2-43 — Đáp án: **B** (Vừa · objective 3.5)

- **Vì sao đúng:** Constructor của `Report` gọi `header()` → đa hình → bản của `Sales`; `title` đã được gán ngay trước đó nên in `<sales>`. Sau khi khởi tạo xong, `total` = 5, `render()` in `<sales>:5`.
- **A sai:** `header()` bị override nên gọi bản của `Sales`, kể cả trong constructor lớp cha.
- **C sai:** `render()` được gọi sau khi object tạo xong; lúc đó `total` = 5.
- **D sai:** `title` được gán trước khi gọi `header()`.
- *Kiểm chứng:* `examples/questions/mock2/QM2_43/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-44 — Đáp án: **D** (Khó · objective 6.1)

- **Vì sao đúng:** `average()` trả về `OptionalDouble` (không phải `double`) → L2. `max(Comparator)` trên `Stream<Integer>` trả về `Optional<Integer>` (không phải `int`) → L4. `sum()` của `IntStream` là `int`; `count()` là `long`; `findFirst()` là `Optional`.
- **A sai:** L4 cũng lỗi: `max` trả về `Optional<Integer>`.
- **B sai:** L2 cũng lỗi: `average()` trả về `OptionalDouble`.
- **C sai:** L5 hợp lệ.
- **E sai:** `count()` trả về `long` → L3 hợp lệ.
- *Kiểm chứng:* `examples/questions/mock2/QM2_44/` — compile error confirmed at ['L2', 'L4'] (`python3 tools/book.py questions mock2`).

### Câu M2-45 — Đáp án: **A** (Vừa · objective 8.1)

- **Vì sao đúng:** `interrupt()` chỉ đặt cờ interrupt; thread đang chạy tự kiểm tra cờ bằng `isInterrupted()` rồi thoát vòng lặp, in `stopped `. `join()` đợi nó kết thúc → trạng thái `TERMINATED`.
- **B sai:** Thread thoát vòng lặp và in `stopped ` trước khi kết thúc.
- **C sai:** Cờ interrupt được đặt nên điều kiện vòng lặp sẽ sai.
- **D sai:** `join()` đợi tới khi thread kết thúc.
- *Kiểm chứng:* `examples/questions/mock2/QM2_45/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-46 — Đáp án: **D** (Vừa · objective 9.1)

- **Vì sao đúng:** Byte stream đọc từng **byte**: `h` (1) + `é` (2 byte trong UTF-8) = 3. Character stream đọc từng **ký tự**: 2.
- **A sai:** `é` chiếm 2 byte trong UTF-8.
- **B sai:** `Reader` giải mã UTF-8 thành 2 ký tự.
- **C sai:** Ngược lại: số byte nhiều hơn số ký tự.
- *Kiểm chứng:* `examples/questions/mock2/QM2_46/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-47 — Đáp án: **B, D** (Vừa · objective 3.3)

- **Vì sao đúng:** Varargs phải là tham số **cuối cùng** và chỉ có một (B). `int[]...` là varargs của mảng `int` (D).
- **A sai:** Varargs phải đứng cuối danh sách tham số.
- **C sai:** Chỉ được có một tham số varargs.
- **E sai:** Dấu `...` đặt sau kiểu, không phải sau tên.
- *Kiểm chứng:* `examples/questions/mock2/QM2_47/` — variants: BD satisfy compiles (`python3 tools/book.py questions mock2`).

### Câu M2-48 — Đáp án: **C** (Vừa · objective 1.1, 5.1)

- **Vì sao đúng:** Xoá giá trị 20 → [10, 30]; chèn 99 ở chỉ số 1 → [10, 99, 30], tổng 139. `equals` so sánh giá trị. `big1 == 1000`: một vế là primitive nên `big1` được unboxing → so sánh số → `true`.
- **A sai:** So sánh `Integer == int` unboxing và so sánh giá trị, không so sánh tham chiếu.
- **B sai:** `add(1, 99)` chèn ở chỉ số 1, sau 10.
- **D sai:** `remove(Integer.valueOf(20))` đã xoá 20.
- *Kiểm chứng:* `examples/questions/mock2/QM2_48/` — output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-49 — Đáp án: **C** (Vừa · objective 7.1)

- **Vì sao đúng:** Với module, javac kiểm tra ngay directive `provides ... with`: lớp cài đặt phải có constructor `public` không tham số, **hoặc** một method `public static provider()`. Không có → lỗi biên dịch "the service implementation does not have a default constructor".
- **A sai:** `ServiceLoader` không tự đoán tham số constructor.
- **B sai:** Lỗi được phát hiện ngay lúc biên dịch module.
- **D sai:** Không tới được bước chạy vì biên dịch thất bại.
- *Kiểm chứng:* `examples/questions/mock2/QM2_49/` — script output confirmed (`python3 tools/book.py questions mock2`).

### Câu M2-50 — Đáp án: **B** (Vừa · objective 6.2)

- **Vì sao đúng:** `TreeMap` sắp xếp key (`m` < `s`). `mapping` đổi sang chữ hoa rồi `joining("/")` theo thứ tự gặp. Độ dài 3: sun, sea, sky; độ dài 4: moon, mars, star.
- **A sai:** `TreeMap` sắp xếp key: `m` trước `s`.
- **C sai:** `star` có 4 ký tự: mỗi nhóm độ dài có 3 từ.
- **D sai:** Collector phụ là `joining`, tạo chuỗi, không phải list.
- *Kiểm chứng:* `examples/questions/mock2/QM2_50/` — output confirmed (`python3 tools/book.py questions mock2`).

## Phân bố theo nhóm mục tiêu

| Nhóm | Số câu |
|---|---|
| 1 | 7 |
| 2 | 4 |
| 3 | 12 |
| 4 | 4 |
| 5 | 4 |
| 6 | 7 |
| 7 | 3 |
| 8 | 4 |
| 9 | 3 |
| 10 | 2 |
