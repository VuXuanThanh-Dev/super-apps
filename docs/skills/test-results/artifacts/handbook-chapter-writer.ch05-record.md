# Chương 5 — Record

> Phiên bản công cụ: .NET SDK 10.0.1xx, C# 14 (kiểm tra 2026-09-28)

## Mục tiêu

Sau chương này, bạn có thể:
- Giải thích kiểu bản ghi (`record`) là gì và khác gì với `class` thường.
- Viết một `record` để lưu dữ liệu bất biến (immutable) và so sánh theo giá trị.
- Dùng `with`-expression để tạo bản sao đã sửa một vài thuộc tính.
- Phân biệt `record class` (mặc định) và `record struct`.

## Giải thích đơn giản

`record` là một kiểu dữ liệu trong C# dùng để lưu thông tin, giống `class`, nhưng trình biên
dịch (compiler) tự sinh sẵn `Equals`, `GetHashCode` và `ToString` cho bạn. Hãy nghĩ `record` như
một tờ hoá đơn giấy: một khi in ra thì không sửa được nội dung cũ, muốn thay đổi thì phải in tờ
mới. Vì vậy `record` rất hợp để biểu diễn dữ liệu bất biến (immutable data) — dữ liệu không đổi
sau khi tạo. Với `class` thường, hai đối tượng chỉ "bằng nhau" khi cùng một vùng nhớ (reference
equality). Với `record`, hai đối tượng "bằng nhau" khi mọi thuộc tính giống nhau (value equality),
kể cả khi là hai vùng nhớ khác nhau.

## Ví dụ

Mục đích: biểu diễn một dòng hoá đơn, so sánh hai dòng hoá đơn, và tạo bản sao đã đổi số lượng.

```csharp
// examples/ch05/HoaDon.cs — chạy: dotnet run HoaDon.cs
var dong1 = new DongHoaDon("Bút bi", 2, 5000m);
var dong2 = new DongHoaDon("Bút bi", 2, 5000m);

Console.WriteLine(dong1);
Console.WriteLine($"dong1 == dong2: {dong1 == dong2}");

var dong3 = dong1 with { SoLuong = 5 };
Console.WriteLine(dong3);
Console.WriteLine($"dong1 == dong3: {dong1 == dong3}");

record DongHoaDon(string TenSanPham, int SoLuong, decimal DonGia);
```

Output thật:

```
DongHoaDon { TenSanPham = Bút bi, SoLuong = 2, DonGia = 5000 }
dong1 == dong2: True
DongHoaDon { TenSanPham = Bút bi, SoLuong = 5, DonGia = 5000 }
dong1 == dong3: False
```

- `DongHoaDon(...)` là **positional record**: khai báo tham số trong dấu ngoặc, compiler tự sinh
  thuộc tính chỉ đọc (`init`-only property) cho từng tham số.
- `dong1 == dong2` là `True` dù là hai đối tượng khác nhau, vì `record` so sánh theo giá trị.
- `dong1 with { SoLuong = 5 }` tạo bản ghi mới, giữ nguyên các thuộc tính khác, không sửa `dong1`.

## Đi sâu

`record` mặc định là `record class` (kiểu tham chiếu — reference type). C# còn có `record struct`
(kiểu giá trị — value type), khi bạn cần dữ liệu nhỏ, sao chép nhanh, không cần cấp phát trên heap.
`record class` hỗ trợ kế thừa (inheritance) như `class` thường; hai bản ghi thuộc hai kiểu khác
nhau (dù cùng dữ liệu) sẽ không bao giờ bằng nhau qua `==` hoặc `Equals`.

```csharp
// examples/ch05/DiSau.cs — chạy: dotnet run DiSau.cs
var vip = new KhachHangVip("An", 100);
var vip2 = new KhachHangVip("An", 100);
Console.WriteLine($"vip == vip2 (record class kế thừa): {vip == vip2}");

var diem1 = new Diem(1, 2);
var diem2 = diem1;              // record struct: sao chép giá trị
diem2 = diem2 with { X = 9 };
Console.WriteLine($"diem1: {diem1}, diem2: {diem2}");

record KhachHang(string Ten);
record KhachHangVip(string Ten, int DiemThuong) : KhachHang(Ten);
record struct Diem(int X, int Y);
```

Output thật:

```
vip == vip2 (record class kế thừa): True
diem1: Diem { X = 1, Y = 2 }, diem2: Diem { X = 9, Y = 2 }
```

`diem2 = diem1` sao chép toàn bộ giá trị của `diem1` sang `diem2` (không chia sẻ vùng nhớ), nên
sửa `diem2` bằng `with` không ảnh hưởng `diem1` — khác với `record class`, nơi biến chỉ giữ tham
chiếu (reference) tới cùng một đối tượng cho tới khi bạn dùng `with` để tạo bản sao mới.

Một `record` vẫn có thể thêm thuộc tính đọc/ghi (mutable) hoặc method như `class` thường, nhưng
làm vậy sẽ mất đi lợi ích bất biến — chỉ nên thêm khi thật sự cần.

## Lỗi và bẫy thường gặp

| Lỗi / bẫy | Vì sao sai | Cách đúng |
|---|---|---|
| Tưởng `record` không sửa được nên gán trực tiếp `dong1.SoLuong = 5` | Thuộc tính positional record là `init`-only, chỉ gán được lúc khởi tạo | Dùng `with` để tạo bản ghi mới: `dong1 with { SoLuong = 5 }` |
| So sánh hai `record` khác kiểu (kế thừa) bằng `==` và mong `True` | `record` chỉ bằng nhau khi cùng kiểu runtime, dù dữ liệu giống hệt | Kiểm tra đúng kiểu cần so sánh, hoặc ép cùng kiểu cha nếu cố ý so sánh phần chung |
| Dùng `record struct` cho dữ liệu lớn rồi truyền qua nhiều hàm | `record struct` là value type, mỗi lần truyền/gán đều sao chép toàn bộ dữ liệu, tốn hiệu năng | Dùng `record class` (mặc định) cho dữ liệu lớn hoặc cần chia sẻ tham chiếu |
| Quên rằng `with` chỉ copy nông (shallow copy) | Thuộc tính kiểu tham chiếu (ví dụ `List<T>`) sau `with` vẫn trỏ chung một vùng nhớ | Nếu cần bản sao sâu, tự sao chép thuộc tính tham chiếu đó trong `with` hoặc constructor |

## Tóm tắt

- `record` tự sinh `Equals`, `GetHashCode`, `ToString` theo giá trị của thuộc tính.
- Positional record: `record Ten(Kieu ThuocTinh1, ...)` — thuộc tính là `init`-only.
- Dùng `with` để tạo bản ghi mới từ bản ghi cũ, chỉ đổi vài thuộc tính.
- `record class` (mặc định) là kiểu tham chiếu và hỗ trợ kế thừa; `record struct` là kiểu giá trị.
- Chọn `record` khi dữ liệu nên bất biến và cần so sánh theo giá trị; chọn `class` khi cần danh
  tính (identity) hoặc trạng thái thay đổi liên tục.

## Bài tập (có lời giải)

1. Viết một `record` tên `SanPham` gồm `Ten` (string) và `Gia` (decimal). Tạo hai biến với cùng
   dữ liệu và in kết quả so sánh `==`.

<details><summary>Lời giải</summary>

```csharp
record SanPham(string Ten, decimal Gia);

var a = new SanPham("Sách", 50000m);
var b = new SanPham("Sách", 50000m);
Console.WriteLine(a == b); // True, vì record so sánh theo giá trị
```

</details>

2. Từ `SanPham` ở bài 1, tạo bản ghi mới `SanPham` với giá giảm 10% mà không sửa bản ghi gốc.

<details><summary>Lời giải</summary>

```csharp
var a = new SanPham("Sách", 50000m);
var aGiamGia = a with { Gia = a.Gia * 0.9m };
Console.WriteLine(aGiamGia); // SanPham { Ten = Sách, Gia = 45000.0 }
Console.WriteLine(a);        // SanPham { Ten = Sách, Gia = 50000 } — không đổi
```

`with` luôn tạo bản ghi mới, nên `a` giữ nguyên giá trị ban đầu.

</details>

3. Cho biết `record class` và `record struct` khác nhau ở điểm nào khi gán một biến bản ghi cho
   biến khác rồi sửa bằng `with` trên biến mới.

<details><summary>Lời giải</summary>

Với `record class`, gán `b = a` chỉ sao chép tham chiếu (reference) — `a` và `b` trỏ tới cùng một
đối tượng. Nhưng vì thuộc tính là `init`-only, `b with { ... }` vẫn tạo đối tượng mới nên `a` không
đổi. Với `record struct`, gán `b = a` sao chép toàn bộ giá trị ngay lập tức thành hai vùng nhớ độc
lập — xem ví dụ `Diem` trong file `examples/ch05/DiSau.cs`, nơi sửa `diem2` không ảnh hưởng
`diem1`.

</details>

## Nguồn tham khảo

- Microsoft Learn — Records (C# reference) — https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/builtin-types/record — **UNVERIFIED**: môi trường này chặn truy cập mạng ra ngoài (proxy trả 403 do chính sách tổ chức), chưa mở được link để xác nhận trong phiên làm việc 2026-09-28. Nội dung chương dựa trên kiến thức đã biết về C# 14, cần người đọc/biên tập đối chiếu lại link trước khi xuất bản.
- Microsoft Learn — with expression — https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/operators/with-expression — **UNVERIFIED** (cùng lý do trên).
