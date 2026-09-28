# GLOSSARY — Thuật ngữ (Tiếng Anh → Tiếng Việt)

Sắp xếp theo thứ tự chữ cái. Cột "Tập" cho biết thuật ngữ xuất hiện lần đầu ở đâu.

| Thuật ngữ | Giải thích tiếng Việt | Tập |
|---|---|---|
| `field` keyword | từ khóa C# 14 truy cập backing field trong property | 1 |
| abstract class | class trừu tượng, không tạo object trực tiếp, dùng làm lớp cha | 1 |
| access modifier | từ khóa phạm vi truy cập: `public`, `private`, `protected`, `internal` | 1 |
| ArrayPool | kho mảng dùng lại, giảm cấp phát bộ nhớ | 3 |
| assembly | file `.dll`/`.exe` kết quả build một project | 1 |
| async / await | cú pháp viết code bất đồng bộ như code tuần tự | 1, 2 |
| back-pressure | cơ chế làm bên gửi chậm lại khi bên nhận xử lý không kịp | 3 |
| backing field | field ẩn chứa giá trị thật của property | 1 |
| BenchmarkDotNet | thư viện đo hiệu năng chuẩn của .NET | 3 |
| boxing | đóng gói value type vào object trên heap (tốn bộ nhớ) | 2 |
| Channel\<T\> | hàng đợi bất đồng bộ cho mẫu producer/consumer | 3 |
| checked / unchecked | bật/tắt kiểm tra tràn số | 1 |
| clean architecture | kiến trúc chia tầng, phụ thuộc chỉ hướng vào trong | 3 |
| closure | lambda "nhớ" biến ở phạm vi bên ngoài | 2 |
| collection expression | cú pháp `[1, 2, 3]` tạo collection; `..` là spread | 1 |
| collection | tập hợp nhiều phần tử: `List<T>`, `Dictionary`, ... | 1 |
| constraint (generic) | ràng buộc `where T : ...` cho tham số kiểu | 2 |
| constructor | hàm khởi tạo object | 1 |
| container / image (Docker) | image: gói ứng dụng + môi trường; container: image đang chạy | 3 |
| DbContext | phiên làm việc với database trong EF Core | 3 |
| deadlock | hai luồng chờ nhau mãi mãi | 3 |
| decimal | kiểu số thập phân 128 bit, dùng cho tiền | 1 |
| deconstruction | tách một giá trị thành nhiều biến: `var (a, b) = tuple;` | 1 |
| deferred execution | thực thi trì hoãn: query LINQ chỉ chạy khi duyệt | 2 |
| delegate | kiểu đại diện cho một hàm (con trỏ hàm an toàn kiểu) | 2 |
| dependency injection (DI) | tiêm phụ thuộc: object nhận dependency từ bên ngoài thay vì tự tạo | 2 |
| Dispose / IDisposable | giải phóng tài nguyên (file, kết nối) | 1 |
| DTO (Data Transfer Object) | object chỉ chở dữ liệu request/response | 2, 3 |
| EF Core | Entity Framework Core — ORM của .NET | 3 |
| endpoint filter | bộ lọc chạy quanh một endpoint Minimal API | 3 |
| event | cơ chế thông báo dựa trên delegate | 2 |
| exception filter | `catch (X) when (...)`: chỉ bắt khi điều kiện đúng | 1 |
| exception | ngoại lệ, object mô tả lỗi lúc chạy | 1 |
| extension member | thêm method/property cho kiểu có sẵn mà không sửa kiểu đó (C# 14 mở rộng) | 1, 2 |
| file-based app | ứng dụng chỉ một file `.cs`, chạy bằng `dotnet run app.cs` (.NET 10) | 1 |
| fixture (test) | dữ liệu/tài nguyên dùng chung giữa các test | 2 |
| GC (Garbage Collector) | bộ gom rác, tự giải phóng object không còn dùng | 3 |
| Generic Host | "khung" ứng dụng gồm DI, configuration, logging | 2 |
| generic | kiểu/hàm có tham số kiểu `<T>` | 1, 2 |
| health check | endpoint báo ứng dụng còn sống / sẵn sàng | 3 |
| heap / stack | vùng nhớ cho object (heap) và cho biến cục bộ, lời gọi hàm (stack) | 1 |
| IL (Intermediate Language) | ngôn ngữ trung gian mà C# biên dịch ra | 1 |
| immutable | bất biến, không sửa được sau khi tạo | 1 |
| init accessor | `init`: chỉ gán lúc khởi tạo object | 1 |
| integration test | test nhiều thành phần cùng chạy thật (HTTP, DB) | 3 |
| interface | "hợp đồng" gồm các thành viên mà class phải cài đặt | 1 |
| Interlocked | thao tác nguyên tử trên biến số, an toàn đa luồng | 3 |
| JIT (Just-In-Time) | biên dịch IL sang mã máy lúc chạy | 1 |
| lifetime (DI) | vòng đời service: Singleton, Scoped, Transient | 2 |
| LINQ | Language Integrated Query: truy vấn dữ liệu bằng `Where`, `Select`... | 1, 2 |
| LTS / STS | Long/Standard Term Support: hỗ trợ dài hạn (3 năm) / ngắn hạn | 1 |
| Microsoft.Testing.Platform (MTP) | nền tảng chạy test mới, dùng với xUnit v3 trên .NET 10 | 2 |
| middleware | thành phần xử lý request/response theo chuỗi | 3 |
| migration (EF Core) | file mô tả thay đổi schema database theo thời gian | 3 |
| Minimal API | cách viết Web API bằng lambda `MapGet/MapPost...` | 3 |
| namespace | không gian tên, nhóm các kiểu | 1 |
| NuGet | kho và trình quản lý gói của .NET | 1 |
| null-coalescing | toán tử `??` và `??=` | 1 |
| null-conditional | toán tử `?.` và `?[]` | 1 |
| nullable | có thể mang giá trị `null`: `int?`, `string?` | 1 |
| observability | khả năng quan sát hệ thống qua logs, traces, metrics | 3 |
| OpenTelemetry | chuẩn mở thu thập và xuất logs/traces/metrics | 3 |
| ORM | ánh xạ object ↔ bảng database | 3 |
| override / virtual | ghi đè method của lớp cha / cho phép ghi đè | 1 |
| pattern matching | so khớp mẫu: `is`, `switch` với pattern | 1, 2 |
| primary constructor | tham số constructor khai báo ngay sau tên class | 1 |
| Problem Details | định dạng JSON chuẩn cho lỗi HTTP (RFC 9457) | 3 |
| property | thuộc tính có `get`/`set` | 1 |
| race condition | kết quả sai do nhiều luồng cùng sửa dữ liệu | 3 |
| record | kiểu dữ liệu so sánh theo giá trị, hỗ trợ `with` | 1, 2 |
| reference type | kiểu tham chiếu: gán là copy địa chỉ | 1 |
| reified generics | generic giữ thông tin kiểu lúc chạy (khác type erasure của Java) | 2 |
| required member | thành viên bắt buộc gán khi khởi tạo | 1 |
| runtime | môi trường chạy chương trình (.NET Runtime / CLR) | 1 |
| scope (logging) | ngữ cảnh gắn thêm trường cho mọi log bên trong | 3 |
| SDK | bộ công cụ phát triển (`dotnet` CLI, compiler) | 1 |
| sealed | không cho kế thừa tiếp | 1 |
| Span\<T\> | "cửa sổ" nhìn vào vùng nhớ liên tục, không copy | 3 |
| stackalloc | cấp phát bộ nhớ tạm trên stack | 3 |
| struct | kiểu giá trị do người dùng định nghĩa | 1 |
| structured logging | log có cấu trúc: giữ tên và giá trị từng trường | 2, 3 |
| switch expression | `x switch { pattern => value, ... }` trả về giá trị | 1 |
| test double / fake / mock | đối tượng giả thay dependency thật khi test | 2 |
| Theory / Fact (xUnit) | test có dữ liệu tham số / test đơn | 2 |
| top-level statements | viết code trực tiếp trong `Program.cs`, không cần `Main` | 1 |
| trace / span | hành trình của một request / một bước trong hành trình đó | 3 |
| tuple | nhóm nhiều giá trị: `(int Min, int Max)` | 1 |
| use case | trường hợp sử dụng: một thao tác nghiệp vụ của ứng dụng | 3 |
| value type | kiểu giá trị: gán là copy dữ liệu | 1 |
| variance (in/out) | quy tắc gán generic giữa kiểu cha/con | 2 |
