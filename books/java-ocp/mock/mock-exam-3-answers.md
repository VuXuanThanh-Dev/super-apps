# Đáp án đề thi thử số 3

Đề: [mock-exam-3.md](mock-exam-3.md). Đậu khi đúng ≥ 34/50 câu (68%).

## Bảng đáp án nhanh

M3-01: C · M3-02: A · M3-03: D · M3-04: B · M3-05: C · M3-06: A · M3-07: D · M3-08: B · M3-09: C · M3-10: A · M3-11: D · M3-12: B · M3-13: C · M3-14: A · M3-15: A,C,D · M3-16: B · M3-17: A · M3-18: D · M3-19: B · M3-20: A,C,D · M3-21: C · M3-22: A · M3-23: D · M3-24: A,C · M3-25: C · M3-26: A · M3-27: D · M3-28: B · M3-29: A,B · M3-30: C · M3-31: A · M3-32: D · M3-33: B · M3-34: A · M3-35: C · M3-36: A,C · M3-37: D · M3-38: B,C,D · M3-39: B · M3-40: C · M3-41: A · M3-42: D · M3-43: C · M3-44: B · M3-45: A · M3-46: D · M3-47: C · M3-48: B · M3-49: A,B,C · M3-50: D

## Giải thích

### Câu M3-01 — Đáp án: **C** (Vừa · objective 6.1)

- **Vì sao đúng:** `iterate` tạo dãy vô hạn 1, 3, 9, 27, 81, 243…; `takeWhile(i < 100)` dừng ở 243. `map(i / 2)` → 2, 4, 1; `max()` trả về `OptionalInt`, `getAsInt()` = 4.
- **A sai:** 81 < 100 nên vẫn được lấy.
- **B sai:** 243 không thoả `i < 100`, `takeWhile` dừng tại đó.
- **D sai:** `max()` áp dụng sau `map(i -> i / 2)`.
- *Kiểm chứng:* `examples/questions/mock3/QM3_01/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-02 — Đáp án: **A** (Dễ · objective 1.1)

- **Vì sao đúng:** Gán `char` cho `int` là widening → mã 120. `getNumericValue('7')` = 7 (giá trị số, không phải mã ký tự 55). `toBinaryString(5)` = `101`. `parseInt` chấp nhận dấu và số 0 ở đầu → -12.
- **B sai:** `i` là `int` nên in số 120.
- **C sai:** `getNumericValue` trả về giá trị chữ số, không phải mã Unicode.
- **D sai:** `toBinaryString` trả về chuỗi nhị phân.
- *Kiểm chứng:* `examples/questions/mock3/QM3_02/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-03 — Đáp án: **D** (Vừa · objective 3.2)

- **Vì sao đúng:** Trong ngữ cảnh static không có `this`: không truy cập field instance (L2), không gọi method instance trực tiếp (L3), không dùng `this` (L4). Method instance thì dùng được cả thành viên static (L1).
- **A sai:** L3 và L4 cũng dùng thành viên instance/`this` trong method static.
- **B sai:** L4 dùng `this` trong method static → lỗi.
- **C sai:** L2 truy cập field instance `count` từ method static → lỗi.
- **E sai:** L2 và L3 cũng lỗi.
- *Kiểm chứng:* `examples/questions/mock3/QM3_03/` — compile error confirmed at ['L2', 'L3', 'L4'] (`python3 tools/book.py questions mock3`).

### Câu M3-04 — Đáp án: **B** (Vừa · objective 5.1)

- **Vì sao đúng:** 1 → cuối [1]; 2 → đầu [2, 1]; 3 → cuối [2, 1, 3]; 4 → đầu [4, 2, 1, 3]. `descendingIterator` duyệt từ cuối: 3124. `removeLast()` → 3; `peekFirst()` → 4.
- **A sai:** Số chẵn được thêm vào **đầu** deque.
- **C sai:** `descendingIterator` duyệt từ cuối về đầu.
- **D sai:** `removeLast()` lấy phần tử cuối (3); phần tử đầu vẫn là 4.
- *Kiểm chứng:* `examples/questions/mock3/QM3_04/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-05 — Đáp án: **C** (Vừa · objective 2.1)

- **Vì sao đúng:** Mỗi lần kiểm tra điều kiện, cả `i` và `j` đều thay đổi (kể cả lần cuối, khi điều kiện sai). Các lần vào vòng: (1,9), (2,8), (3,7), (4,6) → đếm 4; (5,5) → `continue`. Lần kiểm tra `5 < 5` sai nhưng vẫn làm i = 6, j = 4.
- **A sai:** Lần kiểm tra cuối (sai) vẫn chạy `i++` và `j--`.
- **B sai:** Khi i == j (5, 5), `continue` bỏ qua `steps++`.
- **D sai:** Như A và B.
- *Kiểm chứng:* `examples/questions/mock3/QM3_05/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-06 — Đáp án: **A** (Khó · objective 3.5)

- **Vì sao đúng:** `Cat.self()` override với kiểu trả về covariant; object vẫn là `Cat` → `name()` của Cat → `ca`, `getClass()` là `Cat`. Method static không đa hình: `a.type()` theo kiểu tham chiếu `Animal`, `((Cat) a).type()` theo kiểu `Cat`.
- **B sai:** `getClass()` trả về lớp thật của object (`Cat`).
- **C sai:** Method static chọn theo kiểu biến (`Animal`).
- **D sai:** `name()` được override: `"c" + super.name()`.
- *Kiểm chứng:* `examples/questions/mock3/QM3_06/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-07 — Đáp án: **D** (Vừa · objective 4.1)

- **Vì sao đúng:** Khối trong: 1, catch 2 rồi ném exception mới (cause là `e1`), `finally` trong 3. Khối ngoài bắt: 4 + message của cause (`e1`), rồi `finally` ngoài 5.
- **A sai:** `e1` được thêm trong catch ngoài, trước `finally` ngoài (5).
- **B sai:** `finally` trong vẫn chạy khi catch ném exception mới → có 3.
- **C sai:** `getCause()` là exception gốc `e1`, không phải `e2`.
- *Kiểm chứng:* `examples/questions/mock3/QM3_07/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-08 — Đáp án: **B** (Khó · objective 6.2)

- **Vì sao đúng:** Dạng `reduce(identity, accumulator, combiner)` cho phép kết quả khác kiểu phần tử. Với stream **tuần tự**, chỉ accumulator được dùng; combiner chỉ gộp kết quả từng phần khi chạy song song.
- **A sai:** Stream tuần tự không chia nhỏ, nên không gọi combiner.
- **C sai:** Như A — combiner không được gọi lần nào.
- **D sai:** `Stream.reduce` có dạng 3 tham số `(U identity, BiFunction, BinaryOperator)`.
- *Kiểm chứng:* `examples/questions/mock3/QM3_08/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-09 — Đáp án: **C** (Vừa · objective 8.1)

- **Vì sao đúng:** `invokeAny` trả về kết quả của **một** task hoàn thành thành công (ở đây chỉ có `"ok"`). Nó chỉ ném `ExecutionException` khi **mọi** task đều thất bại. Sau `shutdown()`, không còn task → `awaitTermination` trả về `true`.
- **A sai:** Có một task thành công nên không ném exception.
- **B sai:** `invokeAny` trả về kết quả thật của task thành công.
- **D sai:** Mọi task đã kết thúc, executor kết thúc trong thời gian chờ.
- *Kiểm chứng:* `examples/questions/mock3/QM3_09/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-10 — Đáp án: **A** (Vừa · objective 1.4)

- **Vì sao đúng:** 23:59:45 + 20 giây = 2025-01-01 00:00:05; `truncatedTo(MINUTES)` bỏ giây → `2025-01-01T00:00` (giây 0 không được in). Ngày đó là thứ Tư, ngày thứ 1 của năm. Năm 2024 là năm nhuận.
- **B sai:** `truncatedTo(MINUTES)` bỏ phần giây.
- **C sai:** Cộng giây xảy ra **trước** khi cắt bớt.
- **D sai:** 1/1/2025 là thứ Tư; và 2024 chia hết cho 4 (năm nhuận).
- *Kiểm chứng:* `examples/questions/mock3/QM3_10/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-11 — Đáp án: **D** (Vừa · objective 3.4)

- **Vì sao đúng:** `y`, `z`, `i` trước đó chỉ sống trong khối/vòng lặp của chúng, nên khai báo lại sau đó là hợp lệ (L1, L2, L4). Nhưng `x` vẫn còn trong phạm vi khi vào khối ở L5 → không được khai báo biến cục bộ trùng tên.
- **A sai:** Phạm vi của `y` và `z` đầu tiên đã kết thúc.
- **B sai:** L1 và L2 hợp lệ.
- **C sai:** `i` của vòng `for` đã hết phạm vi, nên L4 hợp lệ.
- **E sai:** L5 khai báo lại `x` khi `x` còn trong phạm vi.
- *Kiểm chứng:* `examples/questions/mock3/QM3_11/` — compile error confirmed at ['L5'] (`python3 tools/book.py questions mock3`).

### Câu M3-12 — Đáp án: **B** (Vừa · objective 9.2)

- **Vì sao đúng:** Serialization ghi mỗi object **một lần** trong cùng một stream và dùng tham chiếu cho các lần gặp sau, nên cấu trúc vòng được giữ nguyên và không bị lặp vô hạn. Object đọc ra là object **mới**, khác object gốc.
- **A sai:** Quan hệ tham chiếu giữa các object trong cùng stream được khôi phục.
- **C sai:** Deserialize tạo object mới, không trả về object gốc.
- **D sai:** Serialization xử lý được vòng tham chiếu.
- *Kiểm chứng:* `examples/questions/mock3/QM3_12/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-13 — Đáp án: **C** (Khó · objective 1.2)

- **Vì sao đúng:** Kiểu của toán tử ba ngôi phụ thuộc **cả hai nhánh**: `int` và `String` → boxing thành `Integer`. `int` và `double` → nâng kiểu thành `double` (1.0). `char` và hằng số `int` vừa khoảng `char` → kiểu `char` → 66 thành `'B'`.
- **A sai:** Nhánh còn lại là `double` nên 1 được nâng thành 1.0.
- **B sai:** Khi một nhánh là `char` và nhánh kia là hằng số `int` vừa `char`, kết quả có kiểu `char`.
- **D sai:** Object thật của `o1` là `Integer`; các nhánh số được nâng kiểu như trên.
- *Kiểm chứng:* `examples/questions/mock3/QM3_13/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-14 — Đáp án: **A** (Khó · objective 5.1)

- **Vì sao đúng:** `HashMap` lưu hash của key lúc `put`. Sửa key sau đó làm `hashCode()` đổi → `get(key)` tìm sai "ngăn" → `null`. `List.of("a")` có hash khớp hash cũ nhưng `equals` với key hiện tại (`[a, b]`) sai → `false`. Entry vẫn nằm trong map. Bài học: không dùng object mutable làm key.
- **B sai:** Hash của key đã đổi, nên không tìm thấy entry cũ.
- **C sai:** Key trong map giờ là `[a, b]`, không bằng `[a]`.
- **D sai:** Hash khớp nhưng `equals` thất bại.
- *Kiểm chứng:* `examples/questions/mock3/QM3_14/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-15 — Đáp án: **A, C, D** (Vừa · objective 6.1)

- **Vì sao đúng:** A: `flatMap` tách mỗi chuỗi thành nhiều phần tử. C: `mapMulti` (Java 16+) đẩy 0..n phần tử cho mỗi đầu vào. D: nối chuỗi, lấy các ký tự chữ.
- **B sai:** `map(s -> s.split(","))` tạo `Stream<String[]>`; mảng không có `toUpperCase` → lỗi biên dịch.
- **E sai:** Không tách chuỗi: kết quả là `[A,B, C]` (2 phần tử).
- *Kiểm chứng:* `examples/questions/mock3/QM3_15/` — variants: ACD satisfy output (`python3 tools/book.py questions mock3`).

### Câu M3-16 — Đáp án: **B** (Khó · objective 3.7)

- **Vì sao đúng:** L2: constructor enum không được `public`. L4: enum có method abstract thì **mọi** hằng số phải cài đặt nó; `OFF` không có thân. L5: danh sách hằng số phải đứng **đầu** thân enum. L1 (constructor không modifier) và L3 hợp lệ.
- **A sai:** L4 cũng lỗi: `OFF` không cài đặt method abstract `f()`.
- **C sai:** L2 cũng lỗi: constructor enum chỉ có thể private (ngầm hoặc tường minh).
- **D sai:** L1 hợp lệ: constructor không modifier trong enum ngầm là private.
- **E sai:** L4 và L5 cũng lỗi.
- *Kiểm chứng:* `examples/questions/mock3/QM3_16/` — compile error confirmed at ['L2', 'L4', 'L5'] (`python3 tools/book.py questions mock3`).

### Câu M3-17 — Đáp án: **A** (Vừa · objective 7.2)

- **Vì sao đúng:** Code trên classpath thuộc **unnamed module**. Khi chạy từ classpath, JVM tự đưa các module chuẩn (như `java.sql`, thuộc `java.se`) vào tập module gốc, và unnamed module đọc được mọi module → dùng `java.sql` bình thường.
- **B sai:** `java.sql` có sẵn và unnamed module đọc được nó.
- **C sai:** Không cần `--add-modules` cho các module chuẩn của Java SE khi chạy từ classpath.
- **D sai:** JAR non-modular vẫn chạy được trên classpath như trước Java 9.
- *Kiểm chứng:* `examples/questions/mock3/QM3_17/` — script output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-18 — Đáp án: **D** (Vừa · objective 2.1)

- **Vì sao đúng:** RED rơi xuống YELLOW: 30 + 5 rồi `break`. YELLOW: 5. GREEN không có `break` nên rơi xuống `default`: 0 - 1 = -1. (`default` vẫn chạy nhờ fall-through dù có case khớp.)
- **A sai:** `case RED` không có `break` nên cộng thêm 5.
- **B sai:** `case GREEN` rơi xuống `default` và trừ 1.
- **C sai:** YELLOW bắt đầu ở `case YELLOW`, không chạy phần của RED.
- *Kiểm chứng:* `examples/questions/mock3/QM3_18/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-19 — Đáp án: **B** (Vừa · objective 3.6)

- **Vì sao đúng:** `len.andThen(f)` = áp dụng `len` rồi `f`. "java" dài 4 > 3 → `long`; "go" → `short`; "abcde" dài 5 → nhị phân `101`.
- **A sai:** 4 > 3 nên "java" là `long`.
- **C sai:** `Integer::toBinaryString` đổi 5 thành chuỗi nhị phân.
- **D sai:** "go" chỉ dài 2.
- *Kiểm chứng:* `examples/questions/mock3/QM3_19/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-20 — Đáp án: **A, C, D** (Vừa · objective 4.1, 6.1)

- **Vì sao đúng:** Lambda chỉ được ném checked exception mà method của functional interface khai báo. `Callable.call()` khai báo `throws Exception` (A). Unchecked exception luôn được (C). Checked exception đã được catch bên trong thì không sao (D). `main` khai báo `throws Exception` không giúp gì cho thân lambda.
- **B sai:** `Runnable.run()` không khai báo `throws`; ném `IOException` là lỗi.
- **E sai:** `Supplier.get()` không khai báo `throws`.
- *Kiểm chứng:* `examples/questions/mock3/QM3_20/` — variants: ACD satisfy compiles (`python3 tools/book.py questions mock3`).

### Câu M3-21 — Đáp án: **C** (Vừa · objective 5.1)

- **Vì sao đúng:** `nCopies(2, "x")` → [x, x]; thêm → [x, x, y, x, z]; sắp xếp giảm dần → [z, y, x, x, x]. `frequency` đếm 3. `Collections.max` dùng thứ tự tự nhiên (không phụ thuộc thứ tự list) → `z`. `lastIndexOf("x")` = 4.
- **A sai:** `reverseOrder()` sắp xếp giảm dần.
- **B sai:** `max` theo thứ tự tự nhiên là `z`.
- **D sai:** Có 3 phần tử `x` (2 từ `nCopies` và 1 từ `addAll`).
- *Kiểm chứng:* `examples/questions/mock3/QM3_21/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-22 — Đáp án: **A** (Vừa · objective 1.3)

- **Vì sao đúng:** `Abcdef` → `replace(1, 3, "-")` thay `bc` → `A-def` → xoá ký tự cuối → `A-de`; `append(sb.length())` được tính **sau** khi xoá (độ dài 4) → `A-de4`. `"ab".compareTo("abc")` = hiệu độ dài = -1. `"b".compareTo("a")` = 1.
- **B sai:** `sb.length()` được tính sau `deleteCharAt`, lúc đó là 4.
- **C sai:** `deleteCharAt(length - 1)` xoá `f`.
- **D sai:** Khi một chuỗi là tiền tố của chuỗi kia, `compareTo` trả về hiệu độ dài (-1).
- *Kiểm chứng:* `examples/questions/mock3/QM3_22/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-23 — Đáp án: **D** (Vừa · objective 3.1)

- **Vì sao đúng:** Mỗi `Tool` tạo một `Part` (2), cộng `extra` → 3. Sau `t1 = t2`, cả hai biến trỏ cùng một `Tool` nên `p` giống nhau. (Tool cũ của `t1` giờ đủ điều kiện GC.)
- **A sai:** `new Part()` trực tiếp cũng tăng bộ đếm.
- **B sai:** `t1` và `t2` cùng trỏ một object sau phép gán.
- **C sai:** Mỗi `Tool` có field `Part` riêng được tạo khi khởi tạo.
- *Kiểm chứng:* `examples/questions/mock3/QM3_23/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-24 — Đáp án: **A, C** (Khó · objective 8.2)

- **Vì sao đúng:** A: khoá nội tại (intrinsic lock) là reentrant. C: `wait()`/`notify()` đòi thread phải đang giữ monitor của object.
- **B sai:** `static synchronized` khoá trên object `Class`, còn method instance khoá trên `this` — hai khoá khác nhau.
- **D sai:** `lock()` **chờ** cho tới khi lấy được khoá; `tryLock()` mới trả về ngay.
- **E sai:** `compareAndSet` chỉ đặt khi giá trị hiện tại bằng giá trị mong đợi; nếu không thì trả `false` và giữ nguyên.
- *Kiểm chứng:* `examples/questions/mock3/QM3_24/` — each option proven true/false by a program (`python3 tools/book.py questions mock3`).

### Câu M3-25 — Đáp án: **C** (Vừa · objective 6.2)

- **Vì sao đúng:** `groupingBy` không cho phép **key** `null` → `NullPointerException` ("element cannot be mapped to a null key"). Sau khi lọc `null`, `partitioningBy` chia thành `false=[b]` và `true=[a]`.
- **A sai:** Classifier trả về `null` cho phần tử `null` → groupingBy ném NPE.
- **B sai:** Map của partitioningBy in `false` trước `true`.
- **D sai:** `filter(Objects::nonNull)` đã loại `null`.
- *Kiểm chứng:* `examples/questions/mock3/QM3_25/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-26 — Đáp án: **A** (Vừa · objective 9.1)

- **Vì sao đúng:** `readLine()` đọc `alpha`. `lines()` đọc tiếp các dòng còn lại (beta, gamma) → `bg`. Sau đó reader đã tới cuối → `readLine()` trả về `null`.
- **B sai:** `alpha` đã bị đọc bởi `readLine()` trước khi gọi `lines()`.
- **C sai:** `lines()` đã đọc hết các dòng còn lại.
- **D sai:** Như B và C.
- *Kiểm chứng:* `examples/questions/mock3/QM3_26/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-27 — Đáp án: **D** (Vừa · objective 10.2)

- **Vì sao đúng:** Pattern có hai phần cách nhau bởi `;`: phần thứ hai dùng cho số âm → số âm được bọc trong ngoặc. `0.00` bắt buộc 2 chữ số thập phân và 1 chữ số phần nguyên. `parse` hiểu định dạng ngoặc là số âm → -12.5.
- **A sai:** Phần pattern sau `;` định nghĩa cách hiển thị số âm (dấu ngoặc).
- **B sai:** HALF_EVEN làm tròn 1234.567 thành .57; `0` bắt buộc chữ số 0 ở phần nguyên.
- **C sai:** `0.00` luôn in 2 chữ số thập phân.
- *Kiểm chứng:* `examples/questions/mock3/QM3_27/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-28 — Đáp án: **B** (Vừa · objective 3.5, 2.1)

- **Vì sao đúng:** Record pattern dùng được với record generic: `Box<?>(String s)` kiểm tra lúc chạy xem component có phải `String` không. Giá trị là `"hi"` (độ dài 2) nên nhánh đầu khớp.
- **A sai:** Nhánh đầu khớp nên không tới nhánh thứ hai.
- **C sai:** `o` đúng là một `Box`.
- **D sai:** Record pattern với kiểu generic (wildcard) là hợp lệ trong Java 21.
- *Kiểm chứng:* `examples/questions/mock3/QM3_28/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-29 — Đáp án: **A, B** (Khó · objective 7.1)

- **Vì sao đúng:** Provider cần đọc module chứa interface (`requires com.api`) và khai báo `provides Interface with Impl1[, Impl2...]`. Một directive `provides` có thể liệt kê nhiều lớp cài đặt (B).
- **C sai:** Thiếu `requires com.api` → không nhìn thấy `com.api.Svc` → lỗi biên dịch.
- **D sai:** Thứ tự bị đảo: phải là `provides <interface> with <cài đặt>`.
- **E sai:** `uses` khai báo **dùng** service, không cung cấp provider → consumer không thấy gì (`none`).
- *Kiểm chứng:* `examples/questions/mock3/QM3_29/` — script variants: AB in ra 'found' (`python3 tools/book.py questions mock3`).

### Câu M3-30 — Đáp án: **C** (Khó · objective 1.4)

- **Vì sao đúng:** 01:00 ngày 1/6 ở Việt Nam (UTC+7) = 18:00 UTC ngày 31/5. Tháng 6 Los Angeles dùng giờ mùa hè PDT (UTC-7) → 11:00 ngày 31/5. Cùng một thời điểm: `isEqual` so sánh instant → `true`; `equals` so sánh cả múi giờ → `false`.
- **A sai:** Đi về phía tây qua nhiều múi giờ làm lùi ngày; và `equals` so sánh cả zone.
- **B sai:** Tháng 6 là giờ mùa hè ở Los Angeles: -07:00.
- **D sai:** `isEqual` chỉ so sánh thời điểm (instant).
- *Kiểm chứng:* `examples/questions/mock3/QM3_30/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-31 — Đáp án: **A** (Vừa · objective 3.3)

- **Vì sao đúng:** Không có overload nhận primitive, nên đối số được boxing: `5` → `Integer` (khớp đúng), `5L` → `Long` → `Number`, `short` → `Short` → `Number`. `"s"` chỉ khớp `Object`. `null` khớp cả ba → chọn cụ thể nhất: `Integer`.
- **B sai:** `Integer` khớp đúng kiểu, cụ thể hơn `Number`.
- **C sai:** `Short` là lớp con của `Number`.
- **D sai:** Với `null`, overload cụ thể nhất (`Integer`) được chọn.
- *Kiểm chứng:* `examples/questions/mock3/QM3_31/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-32 — Đáp án: **D** (Vừa · objective 8.1)

- **Vì sao đúng:** `a` được start trước; `b` gọi `a.join()` nên đợi `a` xong rồi mới thêm `b`. `main` đợi `b` (`b.join()`), nên cả hai đã kết thúc trước khi thêm `m`. Thread tạo từ `main` (non-daemon) mặc định là non-daemon.
- **A sai:** `b` chỉ thêm chữ sau khi `a` đã kết thúc.
- **B sai:** `a` đã kết thúc (b đã join nó) nên `isAlive()` là `false`.
- **C sai:** Các lệnh `join` tạo thứ tự xác định.
- *Kiểm chứng:* `examples/questions/mock3/QM3_32/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-33 — Đáp án: **B** (Vừa · objective 6.1)

- **Vì sao đúng:** `Stream.of(T... values)` với một `int[]`: mảng primitive không phải `T[]`, nên nó trở thành **một** phần tử → `Stream<int[]>` có 1 phần tử. `Arrays.stream(int[])` và `IntStream.of(int...)` tạo `IntStream` 3 phần tử.
- **A sai:** `Stream.of(int[])` tạo stream gồm một phần tử là cả mảng.
- **C sai:** `sorted()` sắp xếp trước khi `boxed()`.
- **D sai:** `Arrays.stream(int[])` trả về `IntStream` với 3 phần tử.
- *Kiểm chứng:* `examples/questions/mock3/QM3_33/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-34 — Đáp án: **A** (Khó · objective 3.2, 3.4)

- **Vì sao đúng:** Compact constructor clone mảng nên sửa `src` sau đó không ảnh hưởng (`a`). `equals` tự sinh của record so sánh component mảng bằng `Objects.equals` → so sánh **tham chiếu** hai bản clone khác nhau → `false`. `Arrays.equals` so sánh nội dung → `true`.
- **B sai:** Mảng được clone trong constructor nên không thấy `z`.
- **C sai:** Record không so sánh nội dung mảng; nó so sánh tham chiếu.
- **D sai:** `Arrays.equals` so sánh từng phần tử → `true`.
- *Kiểm chứng:* `examples/questions/mock3/QM3_34/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-35 — Đáp án: **C** (Dễ · objective 2.1)

- **Vì sao đúng:** Cộng 1, bỏ 2 (`continue` nhảy tới điều kiện), cộng 3 và 4 (tổng 8), tới 5 thì `break`.
- **A sai:** `break` thoát vòng lặp khi n = 5.
- **B sai:** 2 bị bỏ qua bởi `continue`: 1 + 3 + 4 = 8.
- **D sai:** `n++` chạy trước khi kiểm tra `n == 5`, nên n = 5 khi thoát.
- *Kiểm chứng:* `examples/questions/mock3/QM3_35/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-36 — Đáp án: **A, C** (Vừa · objective 5.1)

- **Vì sao đúng:** A: `put` trả về giá trị trước đó. C: hàm merge trả về `null` nghĩa là "xoá mapping".
- **B sai:** `getOrDefault` chỉ đọc, không sửa map.
- **D sai:** `firstKey()` trên map rỗng ném `NoSuchElementException` (khác `firstEntry()` trả `null`).
- **E sai:** Chỉ có một key `null`; `put` lần hai ghi đè giá trị.
- *Kiểm chứng:* `examples/questions/mock3/QM3_36/` — each option proven true/false by a program (`python3 tools/book.py questions mock3`).

### Câu M3-37 — Đáp án: **D** (Khó · objective 4.1)

- **Vì sao đúng:** `a` được mở thành công. Khởi tạo `b` ném exception → thân `try` không chạy. Chỉ các tài nguyên **đã khởi tạo thành công** (`a`) được đóng, rồi mới tới `catch`.
- **A sai:** `a` đã mở thành công nên vẫn được đóng.
- **B sai:** Thân `try` không chạy khi khởi tạo tài nguyên thất bại.
- **C sai:** `b` chưa được tạo nên không có gì để đóng.
- *Kiểm chứng:* `examples/questions/mock3/QM3_37/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-38 — Đáp án: **B, C, D** (Vừa · objective 1.2)

- **Vì sao đúng:** B: chia nguyên 10 / 4 = 2, nhân 4 = 8. C: mã của `'a'` là 97. D: `Math.min` trả về `-0.0`, nhưng so sánh `==` giữa `-0.0` và `0.0` là `true`.
- **A sai:** Sai số dấu phẩy động: 0.1 + 0.2 = 0.30000000000000004.
- **E sai:** `Integer.MAX_VALUE + 1` tràn thành số âm lớn nhất.
- *Kiểm chứng:* `examples/questions/mock3/QM3_38/` — variants: BCD satisfy output (`python3 tools/book.py questions mock3`).

### Câu M3-39 — Đáp án: **B** (Vừa · objective 3.6)

- **Vì sao đúng:** `@FunctionalInterface` yêu cầu **đúng một** method abstract. L2 có hai. L5 chỉ có `equals(Object)` — method của `Object` không được tính → không có method abstract nào. L3 kế thừa `run()`; L4 thêm default không ảnh hưởng.
- **A sai:** L5 cũng lỗi: không có method abstract (không tính method của `Object`).
- **C sai:** L3 kế thừa đúng một method abstract từ `A`.
- **D sai:** Method default không được tính, nên L4 hợp lệ.
- **E sai:** L2 có hai method abstract.
- *Kiểm chứng:* `examples/questions/mock3/QM3_39/` — compile error confirmed at ['L2', 'L5'] (`python3 tools/book.py questions mock3`).

### Câu M3-40 — Đáp án: **C** (Khó · objective 6.2)

- **Vì sao đúng:** `flatMapping` gộp skill của mọi dev trong nhóm vào một `TreeSet` (loại trùng, sắp xếp). `filtering` lọc **bên trong** từng nhóm, nên nhóm B vẫn xuất hiện với số đếm 0 (khác với `filter` trước `groupingBy`).
- **A sai:** Collector phụ là `TreeSet`, nên không có phần tử trùng và được sắp xếp.
- **B sai:** `filtering` giữ nhóm B (đếm 0), vì việc lọc diễn ra sau khi gom nhóm.
- **D sai:** Cả hai dev của nhóm A đều có `java`.
- *Kiểm chứng:* `examples/questions/mock3/QM3_40/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-41 — Đáp án: **A** (Vừa · objective 9.3)

- **Vì sao đúng:** `createFile` lần hai trên file đã có → `FileAlreadyExistsException`. `move` với `REPLACE_EXISTING` ghi đè `a.txt` bằng nội dung của `b.txt` và `b.txt` không còn.
- **B sai:** Lần `createFile` thứ hai ném exception và in `exists `.
- **C sai:** `move` xoá file nguồn.
- **D sai:** `a.txt` giờ có nội dung `B` (1 byte).
- *Kiểm chứng:* `examples/questions/mock3/QM3_41/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-42 — Đáp án: **D** (Vừa · objective 10.1)

- **Vì sao đúng:** Tham số của `getDisplayXxx` là ngôn ngữ **dùng để hiển thị**: tên nước Pháp bằng tiếng Việt là `Pháp`; tên tiếng Việt bằng tiếng Pháp là `vietnamien`. `Locale.of("vi")` không có quốc gia nên tên hiển thị chỉ là `Vietnamese`.
- **A sai:** Tên được dịch theo locale truyền vào, không phải luôn tiếng Anh.
- **B sai:** Locale `vi` không có quốc gia, nên không có phần `(Vietnam)`.
- **C sai:** Ngôn ngữ hiển thị được dịch sang tiếng Pháp (`vietnamien`).
- *Kiểm chứng:* `examples/questions/mock3/QM3_42/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-43 — Đáp án: **C** (Vừa · objective 3.5)

- **Vì sao đúng:** Method `abstract` phải được override, nên không thể đi cùng `final` (L2), `private` (L3) hay `static` (L6). Lớp abstract có method static (L4) là bình thường; lớp `final` kế thừa lớp abstract và cài đặt đủ (L5) cũng hợp lệ.
- **A sai:** L6 cũng lỗi: `abstract static` không hợp lệ.
- **B sai:** L5 hợp lệ: `E` cài đặt `f()`.
- **D sai:** L2 cũng lỗi: `final abstract` mâu thuẫn.
- **E sai:** L2 và L3 cũng lỗi.
- *Kiểm chứng:* `examples/questions/mock3/QM3_43/` — compile error confirmed at ['L2', 'L3', 'L6'] (`python3 tools/book.py questions mock3`).

### Câu M3-44 — Đáp án: **B** (Vừa · objective 8.3)

- **Vì sao đúng:** `ConcurrentHashMap.merge` là thao tác nguyên tử, an toàn khi nhiều thread cùng gọi. 0..999: có 334 số chia hết cho 3 (0, 3, …, 999), 333 số dư 1, 333 số dư 2. `reduceValues` cộng tất cả giá trị = 1000.
- **A sai:** `merge` nguyên tử nên không mất cập nhật.
- **C sai:** 999 chia hết cho 3, nên nhóm 0 có 334 phần tử.
- **D sai:** `ConcurrentHashMap` được thiết kế cho truy cập đồng thời.
- *Kiểm chứng:* `examples/questions/mock3/QM3_44/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-45 — Đáp án: **A** (Khó · objective 1.3)

- **Vì sao đúng:** `a` là biến `final` gán bằng hằng số → **constant variable**, nên `a + "va"` là hằng số compile-time, dùng chung object trong string pool với `"Java"`. `b` không final → `d` tạo lúc chạy (object mới). `intern()` trả về bản trong pool.
- **B sai:** `final String a = "Ja"` biến `a + "va"` thành hằng số compile-time.
- **C sai:** `b` không phải final, nên `b + "va"` là object mới.
- **D sai:** `intern()` trả về đúng object trong pool (`e`).
- *Kiểm chứng:* `examples/questions/mock3/QM3_45/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-46 — Đáp án: **D** (Vừa · objective 5.1)

- **Vì sao đúng:** `toArray()` không tham số trả về `Object[]` → không gán cho `String[]` (L2). `Arrays.asList(int[])` tạo `List<int[]>` (mảng primitive là **một** phần tử), không phải `List<Integer>` (L6). L4 dùng `toArray(IntFunction)` (Java 11+) → hợp lệ.
- **A sai:** L6 cũng lỗi: `int[]` không được boxing thành `Integer...`.
- **B sai:** `toArray(String[]::new)` hợp lệ từ Java 11.
- **C sai:** L2 cũng lỗi: `Object[]` không gán được cho `String[]`.
- **E sai:** L4 hợp lệ.
- *Kiểm chứng:* `examples/questions/mock3/QM3_46/` — compile error confirmed at ['L2', 'L6'] (`python3 tools/book.py questions mock3`).

### Câu M3-47 — Đáp án: **C** (Vừa · objective 6.1)

- **Vì sao đúng:** `Optional.stream()` (Java 9+) trả về stream 0 hoặc 1 phần tử, nên `flatMap(Optional::stream)` bỏ các Optional rỗng. Có 1 Optional rỗng. `map` trên Optional rỗng vẫn rỗng → `orElse(-1)`.
- **A sai:** Optional rỗng biến mất hoàn toàn, không để lại phần tử rỗng.
- **B sai:** `map` trên Optional rỗng không gọi hàm; kết quả lấy từ `orElse(-1)`.
- **D sai:** `flatMap(Optional::stream)` lấy giá trị bên trong, không in Optional.
- *Kiểm chứng:* `examples/questions/mock3/QM3_47/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-48 — Đáp án: **B** (Khó · objective 3.4)

- **Vì sao đúng:** Getter trả về bản **clone** nên sửa kết quả của `days()` không ảnh hưởng object (`first()` vẫn 1). Nhưng constructor **không** copy mảng nhận vào, nên sửa `input` sau đó làm thay đổi trạng thái bên trong (`days[1]` = 42). Lớp chưa thật sự bất biến.
- **A sai:** `days()` trả về bản sao; sửa bản sao không đổi mảng bên trong.
- **C sai:** Constructor lưu thẳng tham chiếu `input`, nên thấy thay đổi `input[1] = 42`.
- **D sai:** Như A và C.
- *Kiểm chứng:* `examples/questions/mock3/QM3_48/` — output confirmed (`python3 tools/book.py questions mock3`).

### Câu M3-49 — Đáp án: **A, B, C** (Vừa · objective 7.2)

- **Vì sao đúng:** `jar --describe-module --file` (dạng ngắn `-d -f`) đọc `module-info.class` trong JAR. `java -p <path> --describe-module <tên>` tìm module trên module path rồi mô tả nó.
- **D sai:** `--list` liệt kê file trong JAR (dòng đầu là `META-INF/`).
- **E sai:** Không có `-p`, `java` chỉ thấy module của JDK → in `com.v not found`.
- *Kiểm chứng:* `examples/questions/mock3/QM3_49/` — script variants: ABC in ra 'com.v' (`python3 tools/book.py questions mock3`).

### Câu M3-50 — Đáp án: **D** (Khó · objective 2.1, 3.7)

- **Vì sao đúng:** Java 21 cho phép dùng **tên đầy đủ** của hằng enum (`Move.LEFT`) làm nhãn case khi selector có kiểu khác enum (ở đây là sealed interface `Cmd`). Hai hằng của `Move` và lớp `Stop` phủ hết các kiểu được permit → switch đầy đủ.
- **A sai:** Mọi khả năng của `Cmd` đều được phủ, không cần `default`.
- **B sai:** Từ Java 21, nhãn enum có thể viết đầy đủ `Move.LEFT`.
- **C sai:** Thứ tự in theo thứ tự gọi: RIGHT, Stop, LEFT.
- *Kiểm chứng:* `examples/questions/mock3/QM3_50/` — output confirmed (`python3 tools/book.py questions mock3`).

## Phân bố theo nhóm mục tiêu

| Nhóm | Số câu |
|---|---|
| 1 | 7 |
| 2 | 4 |
| 3 | 12 |
| 4 | 3 |
| 5 | 5 |
| 6 | 7 |
| 7 | 3 |
| 8 | 4 |
| 9 | 3 |
| 10 | 2 |
