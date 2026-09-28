# GLOSSARY — Thuật ngữ Anh–Việt

Sắp xếp theo bảng chữ cái tiếng Anh. Cột "Chương" chỉ chương giải thích kỹ nhất.

| Thuật ngữ (English) | Giải thích tiếng Việt | Chương |
|---|---|---|
| abstract class | Lớp trừu tượng: không `new` được, có thể có method abstract (không thân) | 3 |
| accessor (record) | Method đọc giá trị component của record, cùng tên component: `x()` | 3 |
| annotation `@FunctionalInterface` | Nhãn yêu cầu compiler kiểm tra interface có đúng một method abstract | 3 |
| autoboxing / unboxing | Tự động đổi primitive ↔ wrapper (`int` ↔ `Integer`) | 1 |
| automatic module | JAR không có `module-info` đặt trên module path; tên suy ra từ file hoặc MANIFEST | 7 |
| bundle (ResourceBundle) | Tập chuỗi dịch cho một locale | 10 |
| byte stream / character stream | Dòng dữ liệu theo byte (`InputStream`) / theo ký tự (`Reader`) | 9 |
| canonical constructor | Constructor của record nhận đủ các component theo đúng thứ tự | 3 |
| cast (ép kiểu) | Đổi kiểu tường minh: `(int) 3.9`, `(Dog) animal` | 1, 3 |
| checked exception | Exception bắt buộc catch hoặc khai báo `throws` | 4 |
| collector | "Công thức" gom kết quả stream: `toList`, `groupingBy`… | 6 |
| compact constructor | Constructor của record không có danh sách tham số, dùng để kiểm tra/chuẩn hoá | 3 |
| compile-time constant | Hằng số compiler biết giá trị lúc biên dịch (`final int K = 10`) | 1 |
| concurrency | Đồng thời: nhiều việc chạy xen kẽ/song song | 8 |
| covariant return type | Kiểu trả về của method override là kiểu con của kiểu gốc | 3 |
| daemon thread | Thread "nền"; JVM không đợi nó khi kết thúc | 8 |
| deadlock | Hai thread giữ khoá và chờ khoá của nhau mãi mãi | 8 |
| default method | Method có thân trong interface | 3 |
| deserialization | Đọc chuỗi byte để tạo lại object | 9 |
| diamond operator `<>` | Để compiler tự suy ra tham số kiểu sau `new` | 5 |
| dominance (pattern) | Case rộng hơn đứng trước "che" case hẹp hơn phía sau → lỗi | 2 |
| DST (daylight saving time) | Giờ mùa hè: đồng hồ nhảy lên/lùi xuống 1 giờ | 1 |
| effectively final | Biến không bị gán lại sau khi khởi tạo (dù không ghi `final`) | 6 |
| encapsulation | Đóng gói: ẩn dữ liệu (`private`), truy cập qua method | 3 |
| encounter order | Thứ tự phần tử theo nguồn của stream | 6 |
| enum | Kiểu liệt kê: tập hằng số cố định, vẫn là class | 3 |
| exhaustive (switch) | Switch phủ hết mọi giá trị có thể | 2 |
| exports / opens | Cho module khác dùng package (biên dịch + chạy) / cho reflection sâu lúc chạy | 7 |
| fall-through | Switch dạng `:` chạy tiếp xuống case sau nếu không `break` | 2 |
| flow scoping | Biến pattern chỉ có mặt ở nơi compiler chắc chắn nó đã được gán | 2 |
| functional interface | Interface có đúng một method abstract — dùng được với lambda | 3, 6 |
| garbage collection (GC) | Thu gom rác: JVM tự giải phóng object không còn dùng tới | 3 |
| generics | Kiểu tham số hoá: `List<String>` | 5 |
| guard (`when`) | Điều kiện thêm cho một case pattern | 2 |
| HALF_EVEN | Làm tròn nửa về số chẵn gần nhất (mặc định của `NumberFormat`) | 10 |
| hiding (field/static method) | Lớp con khai báo field/static method trùng tên → "che", không phải override | 3 |
| immutable | Bất biến: không đổi được trạng thái sau khi tạo | 1, 3 |
| inner class | Lớp lồng không static, gắn với một object của lớp ngoài | 3 |
| interrupt | Yêu cầu một thread dừng/thức dậy (đặt cờ hoặc gây `InterruptedException`) | 8 |
| invariant (generics) | `List<Integer>` không phải `List<Number>` | 5 |
| JPMS | Java Platform Module System — hệ thống module | 7 |
| lambda expression | Hàm không tên: `x -> x * 2` | 6 |
| lazy evaluation | Stream chỉ chạy khi có terminal operation | 6 |
| locale | Ngôn ngữ + vùng, ví dụ `vi_VN` | 10 |
| localization (l10n) | Hiển thị theo ngôn ngữ/vùng cụ thể | 10 |
| method reference | Cách viết gọn lambda: `String::length` | 6 |
| module path / classpath | Nơi JVM tìm module / tìm lớp theo kiểu cũ | 7 |
| multi-catch | Một khối catch cho nhiều kiểu: `catch (A \| B e)` | 4 |
| named / unnamed module | Module có `module-info` / code chạy từ classpath | 7 |
| NIO.2 | API `java.nio.file` (`Path`, `Files`) | 9 |
| numeric promotion | Nâng kiểu số khi tính toán (`byte + byte` → `int`) | 1 |
| Optional | Hộp chứa 0 hoặc 1 giá trị, thay cho `null` | 6 |
| overloading | Nạp chồng: nhiều method cùng tên, khác tham số | 3 |
| overriding | Ghi đè: lớp con viết lại method instance của lớp cha | 3 |
| parallel stream | Stream chạy song song trên nhiều thread | 6, 8 |
| pattern matching | So khớp kiểu và "mở" giá trị: `o instanceof String s`, `case Point(int x, int y)` | 2 |
| platform thread / virtual thread | Thread gắn với thread hệ điều hành / thread nhẹ do JVM quản lý | 8 |
| polymorphism | Đa hình: cùng lời gọi, hành vi theo object thật | 3 |
| primitive type | Kiểu nguyên thủy: `int`, `double`, `boolean`… | 1 |
| race condition | Kết quả sai do nhiều thread cùng sửa dữ liệu không đồng bộ | 8 |
| record | Lớp dữ liệu ngắn gọn, bất biến nông | 3 |
| record pattern | Pattern "mở" record: `Point(int x, int y)` | 2 |
| reduction | Rút gọn stream thành một giá trị: `reduce`, `sum`, `count` | 6 |
| reentrant lock | Khoá mà thread đang giữ có thể lấy lại nhiều lần | 8 |
| requires transitive | Phụ thuộc được "truyền" cho module dùng mình (implied readability) | 7 |
| runtime image | Bộ JRE thu gọn tạo bằng `jlink` | 7 |
| sealed class/interface | Giới hạn lớp con được phép (`permits`) | 3 |
| serialization | Biến object thành chuỗi byte | 9 |
| service / provider / consumer | Interface dịch vụ / module cung cấp cài đặt (`provides`) / module sử dụng (`uses`) | 7 |
| short-circuit | Dừng sớm khi đã biết kết quả (`&&`, `\|\|`, `findFirst`, `limit`) | 1, 6 |
| stack trace | Danh sách lời gọi method tại lúc exception xảy ra | 4 |
| static nested class | Lớp lồng có `static`, không cần object lớp ngoài | 3 |
| stream (Stream API) | Dây chuyền xử lý dữ liệu: nguồn → trung gian → kết thúc | 6 |
| string pool | Vùng lưu chuỗi literal dùng chung | 1 |
| suppressed exception | Exception phụ (thường từ `close()`) đính kèm exception chính | 4 |
| switch expression | Switch trả về giá trị | 2 |
| terminal / intermediate operation | Thao tác kết thúc / trung gian của stream | 6 |
| text block | Chuỗi nhiều dòng `"""…"""` | 1 |
| thread-safe | An toàn khi nhiều thread dùng cùng lúc | 8 |
| transient | Field không được serialize | 9 |
| try-with-resources | `try (R r = …)` tự đóng tài nguyên | 4 |
| type erasure | Thông tin kiểu generic bị xoá lúc chạy | 5 |
| type inference (`var`) | Compiler tự suy ra kiểu biến cục bộ | 3 |
| unchecked exception | `RuntimeException`, `Error` và lớp con — không bắt buộc xử lý | 4 |
| unreachable statement | Lệnh không bao giờ chạy tới → lỗi biên dịch | 2 |
| varargs | Tham số biến số lượng: `int... nums` | 3 |
| wildcard (`?`, `? extends`, `? super`) | Kiểu "bất kỳ" có giới hạn trong generics (PECS) | 5 |
| wrapper class | Lớp bao cho primitive: `Integer`, `Double`… | 1 |
