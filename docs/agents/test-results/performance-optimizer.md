# Test result — performance-optimizer

- Date: 2026-09-28
- Mode: real (headless `claude -p`)
- Delegated to: performance-optimizer
- Correct agent triggered: yes
- Tools the subagent used: Bash, Edit, Read, Write

## Prompt

findDuplicates in find-duplicates.js takes about 8 seconds for 20,000 emails (node bench.js). Make it fast, keep the same result, show before/after numbers.

## Result (verbatim)

The performance-optimizer agent finished. Here's its full report:

| Chỉ số | Trước | Sau | Cách đo |
|---|---|---|---|
| Thời gian findDuplicates (N=20000) | 8354.3 ms | 13–21 ms (3 lần chạy) | `node bench.js` (đo bằng `process.hrtime.bigint()` trong file) |
| Số duplicate tìm được | 500 | 500 | so khớp kết quả, không đổi |

### Điểm nghẽn tìm được (bằng chứng)
`find-duplicates.js` dùng thuật toán O(n²): vòng lặp lồng nhau (`for i` × `for j`) so sánh từng cặp phần tử, cộng thêm `result.includes(a)` (chính nó cũng là O(n)) bên trong vòng lặp trong cùng. Với N=20000, số phép so sánh ~200 triệu, khớp với thời gian đo được 8.35s. Đây là nguyên nhân duy nhất/chính gây chậm — không có bottleneck nào khác trong file.

### Thay đổi đã làm (file — lý do)
- `find-duplicates.js`: thay vòng lặp lồng nhau bằng một lượt duyệt duy nhất dùng `Map` để đếm số lần xuất hiện của từng email (đã lowercase), sau đó duyệt `Map` (giữ đúng thứ tự insertion = thứ tự lần xuất hiện đầu tiên, giống hệt hành vi cũ) và chọn ra các key có `count > 1`. Độ phức tạp giảm từ O(n²) xuống O(n), giữ nguyên định dạng output (mảng string đã lowercase) và thứ tự phần tử (theo index xuất hiện lần đầu tăng dần) như bản gốc.

### Test đã chạy
- Viết script so sánh đối chiếu output của bản cũ và bản mới trên 6 case: không trùng lặp, chữ hoa/thường lẫn lộn, nhiều nhóm trùng lặp (kiểm tra thứ tự), mảng rỗng, dữ liệu ngẫu nhiên N=400 (so trực tiếp với bản O(n²) làm reference), và phân bố giống `bench.js` với N=2000. Tất cả đều `PASS`, output giống hệt nhau (kể cả thứ tự phần tử trong mảng kết quả).
- Chạy `node bench.js` 3 lần sau khi sửa, kết quả `duplicates=500` khớp với bản gốc.

### Đánh đổi / rủi ro
- Dùng thêm bộ nhớ O(n) cho `Map` đếm số lần xuất hiện, thay vì gần như O(1) phụ trợ của bản cũ — không đáng kể với N=20000 so với lợi ích tốc độ ~500-600 lần.
- Hành vi giữ nguyên 100%: case-insensitive, output là email đã lowercase, thứ tự phần tử theo lần xuất hiện đầu tiên tăng dần — không có thay đổi API hay side effect nào khác.

### Bước tiếp theo nếu cần nhanh hơn nữa
- 13–21ms cho N=20000 đã đủ nhanh; nếu cần tối ưu thêm cho hàng triệu phần tử, có thể tránh gọi `toLowerCase()` lặp lại nếu dữ liệu đã chuẩn hoá trước, hoặc dùng `for...of` thay vì index loop (khác biệt không đáng kể ở scale hiện tại).
