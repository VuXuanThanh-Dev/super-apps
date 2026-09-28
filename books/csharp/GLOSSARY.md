# GLOSSARY — Thuật ngữ (Tiếng Anh → Tiếng Việt)

Sắp xếp theo thứ tự chữ cái. Cột "Tập" cho biết thuật ngữ xuất hiện lần đầu ở đâu.

| Thuật ngữ | Giải thích tiếng Việt | Tập |
|---|---|---|
| abstract class | class trừu tượng, không tạo object trực tiếp, dùng làm lớp cha | 1 |
| access modifier | từ khóa phạm vi truy cập: `public`, `private`, `protected`, `internal` | 1 |
| assembly | file `.dll`/`.exe` kết quả build một project | 1 |
| async / await | cú pháp viết code bất đồng bộ như code tuần tự | 1, 2 |
| backing field | field ẩn chứa giá trị thật của property | 1 |
| boxing | đóng gói value type vào object trên heap (tốn bộ nhớ) | 2 |
| checked / unchecked | bật/tắt kiểm tra tràn số | 1 |
| collection | tập hợp nhiều phần tử: `List<T>`, `Dictionary`, ... | 1 |
| collection expression | cú pháp `[1, 2, 3]` tạo collection; `..` là spread | 1 |
| constructor | hàm khởi tạo object | 1 |
| deconstruction | tách một giá trị thành nhiều biến: `var (a, b) = tuple;` | 1 |
| decimal | kiểu số thập phân 128 bit, dùng cho tiền | 1 |
| delegate | kiểu đại diện cho một hàm (con trỏ hàm an toàn kiểu) | 2 |
| dependency injection (DI) | tiêm phụ thuộc: object nhận dependency từ bên ngoài thay vì tự tạo | 2 |
| Dispose / IDisposable | giải phóng tài nguyên (file, kết nối) | 1 |
| event | cơ chế thông báo dựa trên delegate | 2 |
| exception | ngoại lệ, object mô tả lỗi lúc chạy | 1 |
| exception filter | `catch (X) when (...)`: chỉ bắt khi điều kiện đúng | 1 |
| extension member | thêm method/property cho kiểu có sẵn mà không sửa kiểu đó (C# 14 mở rộng) | 1, 2 |
| `field` keyword | từ khóa C# 14 truy cập backing field trong property | 1 |
| file-based app | ứng dụng chỉ một file `.cs`, chạy bằng `dotnet run app.cs` (.NET 10) | 1 |
| generic | kiểu/hàm có tham số kiểu `<T>` | 1, 2 |
| heap / stack | vùng nhớ cho object (heap) và cho biến cục bộ, lời gọi hàm (stack) | 1 |
| IL (Intermediate Language) | ngôn ngữ trung gian mà C# biên dịch ra | 1 |
| immutable | bất biến, không sửa được sau khi tạo | 1 |
| init accessor | `init`: chỉ gán lúc khởi tạo object | 1 |
| interface | "hợp đồng" gồm các thành viên mà class phải cài đặt | 1 |
| JIT (Just-In-Time) | biên dịch IL sang mã máy lúc chạy | 1 |
| LINQ | Language Integrated Query: truy vấn dữ liệu bằng `Where`, `Select`... | 1, 2 |
| LTS / STS | Long/Standard Term Support: hỗ trợ dài hạn (3 năm) / ngắn hạn | 1 |
| namespace | không gian tên, nhóm các kiểu | 1 |
| NuGet | kho và trình quản lý gói của .NET | 1 |
| nullable | có thể mang giá trị `null`: `int?`, `string?` | 1 |
| null-coalescing | toán tử `??` và `??=` | 1 |
| null-conditional | toán tử `?.` và `?[]` | 1 |
| override / virtual | ghi đè method của lớp cha / cho phép ghi đè | 1 |
| pattern matching | so khớp mẫu: `is`, `switch` với pattern | 1, 2 |
| primary constructor | tham số constructor khai báo ngay sau tên class | 1 |
| property | thuộc tính có `get`/`set` | 1 |
| record | kiểu dữ liệu so sánh theo giá trị, hỗ trợ `with` | 1, 2 |
| reference type | kiểu tham chiếu: gán là copy địa chỉ | 1 |
| required member | thành viên bắt buộc gán khi khởi tạo | 1 |
| runtime | môi trường chạy chương trình (.NET Runtime / CLR) | 1 |
| SDK | bộ công cụ phát triển (`dotnet` CLI, compiler) | 1 |
| sealed | không cho kế thừa tiếp | 1 |
| struct | kiểu giá trị do người dùng định nghĩa | 1 |
| switch expression | `x switch { pattern => value, ... }` trả về giá trị | 1 |
| top-level statements | viết code trực tiếp trong `Program.cs`, không cần `Main` | 1 |
| tuple | nhóm nhiều giá trị: `(int Min, int Max)` | 1 |
| value type | kiểu giá trị: gán là copy dữ liệu | 1 |
