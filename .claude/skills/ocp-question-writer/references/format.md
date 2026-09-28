# questions.yaml — schema

Cùng định dạng với `books/java-ocp/tools/book.py` (Task 2). Script của skill hỗ trợ tập con:
`output`, `compile_error`, `variants`. Các kind `proofs`, `script` chỉ có trong `book.py`.

```yaml
meta:
  chapter: ch05            # tên bộ câu hỏi
questions:
  - id: "05-01"            # duy nhất
    level: easy|medium|hard
    topic: "5.2"           # mã mục tiêu trong COVERAGE.md
    q: Chương trình sau in ra gì?
    kind: output           # output | compile_error | variants
    code: |                # kind output / compile_error: một file Java hoàn chỉnh
      public class A { public static void main(String[] a) { System.out.println(1 + 2 + "3"); } }
    expect: "33"           # stdout mong đợi (so sánh sau khi bỏ khoảng trắng cuối dòng)
    # expect_exception: ArithmeticException   # thay cho expect nếu chương trình ném exception
    options: {A: "123", B: "33", C: "6", D: Lỗi biên dịch}
    answer: B              # hoặc [B, D] cho câu chọn nhiều
    why: >-
      Giải thích đáp án đúng.
    wrong:                 # bắt buộc cho mọi lựa chọn sai
      A: "..."
      C: "..."
      D: "..."
```

`compile_error`: đánh dấu dòng bằng comment `// L1`, `// L2` … và khai báo
`error_markers: [L2]` — script kiểm tra javac báo lỗi **đúng** các dòng đó.

`variants`: dùng `template` chứa `/*INSERT*/`; mỗi option là đoạn code chèn vào.
`criterion`: `compiles` (mặc định) | `runs` | `{output: "..."}`. Đáp án = tập option thoả criterion.

```yaml
    kind: variants
    template: |
      public class V { public static void main(String[] a) { /*INSERT*/ System.out.println(x); } }
    criterion: compiles
    options: {A: "var x = 1;", B: "var x;", C: "int x = 1L;", D: "long x = 1;"}
    answer: [A, D]
```
