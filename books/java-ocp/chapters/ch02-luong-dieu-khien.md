# Chương 2 — Luồng điều khiển (Controlling Program Flow)

## Mục tiêu

Objective 2.1: viết đúng và **đọc đúng** các cấu trúc điều khiển:

- `if` / `else`, toán tử ba ngôi.
- `switch` **statement** (câu lệnh) và `switch` **expression** (biểu thức), dạng `:` và dạng `->`.
- Pattern matching trong `switch` (Java 21): type pattern, record pattern, guard `when`, `case null`.
- Vòng lặp `while`, `do-while`, `for`, for-each; `break`, `continue`, nhãn (label).
- Phát hiện code không thể tới (unreachable) và switch không đầy đủ (not exhaustive).

## Giải thích đơn giản

Chương trình chạy từ trên xuống. **Luồng điều khiển (control flow)** là cách ta đổi thứ tự đó:
chọn nhánh (`if`, `switch`) hoặc lặp lại (`for`, `while`).

Hai ý quan trọng nhất cho đề thi:

1. **Switch có hai "thế giới".** Dạng cũ `case X:` có **fall-through** — chạy xong một case sẽ *rơi xuống* case
   sau nếu không có `break`. Dạng mới `case X ->` không bao giờ rơi xuống. Switch có thể là **statement**
   (chỉ làm việc) hoặc **expression** (trả về giá trị, phải đầy đủ mọi trường hợp).
2. **Pattern matching.** `o instanceof String s` vừa kiểm tra kiểu vừa tạo biến `s`. Trong Java 21, `switch`
   cũng làm được như vậy: `case String s ->`, kèm điều kiện `when`, và "mở" record: `case Point(int x, int y) ->`.

## Ví dụ

Code trong `examples/ch02/`. Chạy lại: `python3 tools/book.py examples ch02`. Output thật, JDK 21.0.10.

### 1. if / else và "dangling else"

<!-- EX:Ex01_IfElse -->
`examples/ch02/Ex01_IfElse.java`

```java
// objective: 2.1
// if / else if / else, "dangling else", và điều kiện phải là boolean.
public class Ex01_IfElse {
    static String grade(int score) {
        if (score >= 90) return "A";
        else if (score >= 80) return "B";
        else if (score >= 50) return "C";
        else return "F";
    }

    public static void main(String[] args) {
        System.out.println(grade(95) + grade(85) + grade(50) + grade(10));

        int x = 5;
        if (x > 10)
            if (x > 20) System.out.println("> 20");
        else System.out.println("else thuộc về if GẦN NHẤT (x > 20)");   // không in gì!
        System.out.println("sau khối if lồng nhau");

        boolean done = false;
        if (done = true) {                 // gán, không phải so sánh — vẫn hợp lệ vì kiểu boolean
            System.out.println("done = " + done);
        }
        // if (x = 3) {}                   // lỗi biên dịch: int không phải boolean
    }
}
```

Output thật (JDK 21.0.10):

```text
ABCF
sau khối if lồng nhau
done = true
```
<!-- /EX -->

### 2. Switch statement cổ điển và fall-through

<!-- EX:Ex02_SwitchStatement -->
`examples/ch02/Ex02_SwitchStatement.java`

```java
// objective: 2.1
// switch statement kiểu cũ: rơi xuống (fall-through), default ở giữa, case phải là hằng số.
public class Ex02_SwitchStatement {
    static void test(int day) {
        final int WEEKEND = 6;
        System.out.print(day + ": ");
        switch (day) {
            case 1:
                System.out.print("Mon ");
            case 2:
                System.out.print("Tue ");
                break;
            default:
                System.out.print("Other ");
            case WEEKEND, 7:                // nhiều nhãn trên một case (Java 14+)
                System.out.print("Weekend ");
        }
        System.out.println();
    }

    public static void main(String[] args) {
        test(1);
        test(2);
        test(4);
        test(7);

        String cmd = "stop";
        switch (cmd) {                      // switch trên String dùng equals()
            case "start" -> System.out.println("starting");
            case "stop" -> System.out.println("stopping");
            default -> System.out.println("unknown");
        }
        char c = 'b';
        switch (c) { case 'a': case 'b': System.out.println("a or b"); }
    }
}
```

Output thật (JDK 21.0.10):

```text
1: Mon Tue
2: Tue
4: Other Weekend
7: Weekend
stopping
a or b
```
<!-- /EX -->

### 3. Switch expression, `yield`

<!-- EX:Ex03_SwitchExpression -->
`examples/ch02/Ex03_SwitchExpression.java`

```java
// objective: 2.1
// switch expression: trả về giá trị, dùng -> hoặc yield, phải đầy đủ (exhaustive).
public class Ex03_SwitchExpression {
    enum Size { S, M, L, XL }

    static int price(Size s) {
        return switch (s) {            // enum: liệt kê đủ hằng số thì không cần default
            case S, M -> 10;
            case L -> 12;
            case XL -> {
                int base = 12;
                yield base + 3;       // khối { } phải dùng yield
            }
        };
    }

    public static void main(String[] args) {
        for (Size s : Size.values()) System.out.print(s + "=" + price(s) + " ");
        System.out.println();

        int n = 3;
        String word = switch (n) {
            case 1: yield "one";          // dạng ':' cũng dùng được trong switch expression
            case 2: yield "two";
            default: yield "many";
        };
        System.out.println(word);

        var kind = switch ("b") {
            case "a" -> 1;
            case "b" -> 2.5;           // kiểu chung của các nhánh: double
            default -> 0;
        };
        System.out.println(kind);
    }
}
```

Output thật (JDK 21.0.10):

```text
S=10 M=10 L=12 XL=15
many
2.5
```
<!-- /EX -->

### 4. Pattern matching cho switch

<!-- EX:Ex04_PatternSwitch -->
`examples/ch02/Ex04_PatternSwitch.java`

```java
// objective: 2.1, 3.5
// Pattern matching cho switch (Java 21): type pattern, guard "when", case null.
public class Ex04_PatternSwitch {
    static String describe(Object o) {
        return switch (o) {
            case null -> "null!";
            case Integer i when i > 100 -> "big int " + i;
            case Integer i -> "int " + i;
            case String s when s.isEmpty() -> "empty string";
            case String s -> "string of " + s.length();
            case int[] arr -> "int array of " + arr.length;
            default -> "other " + o.getClass().getSimpleName();
        };
    }

    public static void main(String[] args) {
        Object[] data = {7, 500, "", "hello", new int[3], 2.5, null};
        for (Object o : data) System.out.println(describe(o));

        Object o = "abc";
        try {
            switch (o) {
                case Integer i -> System.out.println("int");
                default -> System.out.println("default, không null");
            }
            o = null;
            switch (o) {                    // không có case null → NPE
                case Integer i -> System.out.println("int");
                default -> System.out.println("default");
            }
        } catch (NullPointerException e) {
            System.out.println("NullPointerException: switch trên null không có case null");
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
int 7
big int 500
empty string
string of 5
int array of 3
other Double
null!
default, không null
NullPointerException: switch trên null không có case null
```
<!-- /EX -->

### 5. Các loại vòng lặp

<!-- EX:Ex05_Loops -->
`examples/ch02/Ex05_Loops.java`

```java
// objective: 2.1
// while, do-while (luôn chạy ít nhất 1 lần), for nhiều biến, for-each.
public class Ex05_Loops {
    public static void main(String[] args) {
        int i = 10;
        while (i < 10) { System.out.println("while"); i++; }
        do { System.out.println("do-while chạy 1 lần, i=" + i); i++; } while (i < 10);

        for (int a = 0, b = 10; a < b; a += 3, b -= 3) {
            System.out.print("(" + a + "," + b + ") ");
        }
        System.out.println();

        int[] nums = {1, 2, 3};
        for (int n : nums) { n *= 10; }             // n là bản sao: mảng không đổi
        System.out.println(nums[0] + " " + nums[1] + " " + nums[2]);

        int count = 0;
        for (;;) {                                  // vòng lặp vô hạn, thoát bằng break
            if (++count == 4) break;
        }
        System.out.println("count=" + count);

        int k = 0;
        while (k++ < 3) System.out.print(k + " ");
        System.out.println("-> k=" + k);
    }
}
```

Output thật (JDK 21.0.10):

```text
do-while chạy 1 lần, i=10
(0,10) (3,7)
1 2 3
count=4
1 2 3 -> k=4
```
<!-- /EX -->

### 6. Nhãn (label) với break / continue

<!-- EX:Ex06_Labels -->
`examples/ch02/Ex06_Labels.java`

```java
// objective: 2.1
// break / continue có nhãn (label) trong vòng lặp lồng nhau.
public class Ex06_Labels {
    public static void main(String[] args) {
        int[][] grid = {{1, 2, 3}, {4, -1, 6}, {7, 8, 9}};

        OUTER:
        for (int[] row : grid) {
            for (int v : row) {
                if (v < 0) break OUTER;          // thoát cả hai vòng
                System.out.print(v + " ");
            }
        }
        System.out.println("| sau break OUTER");

        ROW:
        for (int r = 0; r < 3; r++) {
            for (int c = 0; c < 3; c++) {
                if (c > r) continue ROW;         // sang hàng tiếp theo
                System.out.print(grid[r][c] + " ");
            }
        }
        System.out.println("| tam giác dưới");

        BLOCK: {
            System.out.print("trong block ");
            if (grid.length == 3) break BLOCK;   // break có nhãn dùng được với block thường
            System.out.print("không in ");
        }
        System.out.println("| hết block");
    }
}
```

Output thật (JDK 21.0.10):

```text
1 2 3 4 | sau break OUTER
1 4 -1 7 8 9 | tam giác dưới
trong block | hết block
```
<!-- /EX -->

### 7. instanceof pattern và flow scoping

<!-- EX:Ex07_FlowScoping -->
`examples/ch02/Ex07_FlowScoping.java`

```java
// objective: 2.1, 3.5
// Pattern matching với instanceof và "flow scoping": biến pattern có mặt ở đâu?
public class Ex07_FlowScoping {
    static int len(Object o) {
        if (!(o instanceof String s)) {
            return -1;
        }
        return s.length();                 // s dùng được: nhánh trên luôn return
    }

    public static void main(String[] args) {
        System.out.println(len("hello") + " " + len(42));

        Object o = "Java";
        if (o instanceof String s && s.length() > 3) {   // && : s đã được gán khi vế phải chạy
            System.out.println("dài: " + s.toUpperCase());
        }
        // if (o instanceof String s || s.isEmpty()) {}  // lỗi: s có thể chưa được gán

        Number n = 3.5;
        if (n instanceof Integer i) System.out.println("Integer " + i);
        else if (n instanceof Double d) System.out.println("Double " + (d * 2));

        String str = "x";
        if (str instanceof String t) System.out.println("Java 21 cho phép pattern không điều kiện: " + t);
        System.out.println(str instanceof CharSequence cs ? "CharSequence " + cs.length() : "no");
    }
}
```

Output thật (JDK 21.0.10):

```text
5 -1
dài: JAVA
Double 7.0
Java 21 cho phép pattern không điều kiện: x
CharSequence 1
```
<!-- /EX -->

### 8. Record pattern

<!-- EX:Ex08_RecordPatterns -->
`examples/ch02/Ex08_RecordPatterns.java`

```java
// objective: 2.1, 3.5
// Record pattern (Java 21): "mở" record ngay trong instanceof và switch, kể cả lồng nhau.
public class Ex08_RecordPatterns {
    record Point(int x, int y) {}
    record Line(Point from, Point to) {}

    sealed interface Shape permits Circle, Square {}
    record Circle(double r) implements Shape {}
    record Square(double side) implements Shape {}

    static double area(Shape s) {
        return switch (s) {                  // sealed + record: đủ các trường hợp, không cần default
            case Circle(double r) -> Math.PI * r * r;
            case Square(var side) -> side * side;
        };
    }

    public static void main(String[] args) {
        Object o = new Line(new Point(0, 0), new Point(3, 4));
        if (o instanceof Line(Point(var x1, var y1), Point(int x2, int y2))) {
            System.out.println("length = " + Math.hypot(x2 - x1, y2 - y1));
        }
        System.out.printf("%.2f %.2f%n", area(new Circle(1)), area(new Square(3)));

        Object p = new Point(5, 0);
        String where = switch (p) {
            case Point(int x, int y) when y == 0 -> "trên trục X tại " + x;
            case Point(int x, int y) -> "điểm " + x + "," + y;
            default -> "không phải Point";
        };
        System.out.println(where);
    }
}
```

Output thật (JDK 21.0.10):

```text
length = 5.0
3.14 9.00
trên trục X tại 5
```
<!-- /EX -->

### 9. Code không thể tới (unreachable)

<!-- EX:Ex09_Unreachable -->
`examples/ch02/Ex09_Unreachable.java`

```java
// objective: 2.1
// expect: compile-error
// Code không thể tới (unreachable) là lỗi biên dịch.
public class Ex09_Unreachable {
    public static void main(String[] args) {
        while (true) {
            break;
            System.out.println("sau break");
        }
        for (int i = 0; ; i++) { }
        System.out.println("sau vòng lặp vô hạn");
    }
}
```

Output thật của `javac` (JDK 21.0.10) — cố ý không biên dịch được:

```text
Ex09_Unreachable.java:8: error: unreachable statement
            System.out.println("sau break");
            ^
Ex09_Unreachable.java:11: error: unreachable statement
        System.out.println("sau vòng lặp vô hạn");
        ^
2 errors
```
<!-- /EX -->

### 10. Switch expression không đầy đủ

<!-- EX:Ex10_NotExhaustive -->
`examples/ch02/Ex10_NotExhaustive.java`

```java
// objective: 2.1
// expect: compile-error
// switch expression trên int phải đầy đủ (exhaustive): thiếu default là lỗi.
public class Ex10_NotExhaustive {
    public static void main(String[] args) {
        int n = 2;
        String s = switch (n) {
            case 1 -> "one";
            case 2 -> "two";
        };
    }
}
```

Output thật của `javac` (JDK 21.0.10) — cố ý không biên dịch được:

```text
Ex10_NotExhaustive.java:7: error: the switch expression does not cover all possible input values
        String s = switch (n) {
                   ^
1 error
```
<!-- /EX -->

### 11. Kiểu của selector trong switch

<!-- EX:Ex11_SwitchTypes -->
`examples/ch02/Ex11_SwitchTypes.java`

```java
// objective: 2.1
// Kiểu được phép trong switch cổ điển và giá trị null với String/enum.
public class Ex11_SwitchTypes {
    enum Color { RED, GREEN }

    public static void main(String[] args) {
        Color c = Color.GREEN;
        switch (c) {
            case RED -> System.out.println("red");        // nhãn enum: không viết Color.RED cũng được
            case Color.GREEN -> System.out.println("green (Java 21 cho phép tên đầy đủ)");
        }

        Integer boxed = 2;                                // wrapper được unboxing
        switch (boxed) { case 1 -> System.out.println("1"); case 2 -> System.out.println("2"); default -> {} }

        String s = null;
        try {
            switch (s) { case "a" -> System.out.println("a"); default -> System.out.println("d"); }
        } catch (NullPointerException e) {
            System.out.println("NPE: switch cổ điển trên String null");
        }
        long big = 1L;
        // switch (big) { case 1L -> ... }   // lỗi: long/float/double/boolean không dùng trong switch cổ điển
        System.out.println("long không dùng làm selector (trừ khi là pattern trên Object) " + big);
    }
}
```

Output thật (JDK 21.0.10):

```text
green (Java 21 cho phép tên đầy đủ)
2
NPE: switch cổ điển trên String null
long không dùng làm selector (trừ khi là pattern trên Object) 1
```
<!-- /EX -->

### 12. continue trong do-while, phạm vi biến vòng lặp

<!-- EX:Ex12_DoWhileScope -->
`examples/ch02/Ex12_DoWhileScope.java`

```java
// objective: 2.1
// Phạm vi biến trong vòng lặp, và continue trong do-while vẫn kiểm tra điều kiện.
public class Ex12_DoWhileScope {
    public static void main(String[] args) {
        int i = 0;
        do {
            i++;
            if (i % 2 == 0) continue;       // continue nhảy tới phần kiểm tra điều kiện
            System.out.print(i + " ");
        } while (i < 7);
        System.out.println();

        for (int j = 0; j < 2; j++) { int local = j * 10; System.out.print(local + " "); }
        // System.out.println(j);          // lỗi: j chỉ sống trong vòng for
        System.out.println();

        int total = 0;
        for (int a = 1; a <= 3; a++)
            for (int b = 1; b <= a; b++)
                total += b;
        System.out.println("total=" + total);
    }
}
```

Output thật (JDK 21.0.10):

```text
1 3 5 7
0 10
total=10
```
<!-- /EX -->

### 13. Case bị "che" (dominance)

<!-- EX:Ex13_Dominance -->
`examples/ch02/Ex13_Dominance.java`

```java
// objective: 2.1, 3.5
// expect: compile-error
// Thứ tự case trong pattern switch: case rộng hơn đứng trước sẽ "che" (dominate) case hẹp hơn.
public class Ex13_Dominance {
    static String f(Object o) {
        return switch (o) {
            case Number num -> "number";
            case Integer i -> "integer";     // không bao giờ tới được
            default -> "other";
        };
    }

    public static void main(String[] args) {
        System.out.println(f(1));
    }
}
```

Output thật của `javac` (JDK 21.0.10) — cố ý không biên dịch được:

```text
Ex13_Dominance.java:8: error: this case label is dominated by a preceding case label
            case Integer i -> "integer";     // không bao giờ tới được
                 ^
1 error
```
<!-- /EX -->

## Đi sâu

### Bốn dạng switch

| | Dạng `case X:` | Dạng `case X ->` |
|---|---|---|
| **Statement** | Fall-through; `break` để dừng. Không cần đầy đủ (trừ khi dùng pattern / `case null`) | Không fall-through. Nhánh là một biểu thức, một khối `{}` hoặc `throw` |
| **Expression** | Mỗi nhánh kết thúc bằng `yield value;` (hoặc `throw`). Phải đầy đủ | Nhánh là biểu thức → giá trị; khối `{}` phải `yield`. Phải đầy đủ |

Không được trộn `:` và `->` trong cùng một switch.

### Kiểu của selector

- **Switch cổ điển** (không có pattern): `char`, `byte`, `short`, `int`, các wrapper tương ứng, `String`, enum.
  **Không** dùng `long`, `float`, `double`, `boolean`.
- **Switch có pattern** (Java 21): selector là **bất kỳ kiểu tham chiếu** nào (`Object`, interface sealed…).
- Nhãn `case` cổ điển phải là **hằng số compile-time** (literal, biến `final` gán hằng số, hằng enum) và không trùng nhau.
- Java 21 cho phép viết tên đầy đủ của hằng enum: `case Color.GREEN ->`.

### Đầy đủ (exhaustiveness)

Phải đầy đủ khi: switch **expression**, hoặc switch statement dùng pattern hoặc `case null`.
Cách đạt: có `default`; hoặc liệt kê hết hằng enum; hoặc phủ hết các lớp con của một **sealed** type;
hoặc có một pattern không điều kiện (ví dụ `case Object o`).

### Pattern trong switch: thứ tự và `null`

- Case được thử **từ trên xuống**. Case rộng hơn đứng trước case hẹp hơn → lỗi *dominated*.
  Case có guard `when` phải đứng trước case cùng kiểu không guard.
- Selector là `null` → `NullPointerException`, **trừ khi** có `case null` (có thể viết `case null, default ->`).
  `default` một mình **không** bắt `null`.
- Guard: `case Integer i when i > 10 ->`. Guard là biểu thức `boolean` bất kỳ.
- Record pattern có thể lồng nhau và dùng `var`: `case Line(Point(var x1, var y1), Point p2) ->`.

### Flow scoping của biến pattern

Biến pattern chỉ có mặt ở nơi compiler **chắc chắn** nó đã được gán:

- `if (o instanceof String s && s.isEmpty())` — OK (vế phải chỉ chạy khi vế trái đúng).
- `if (o instanceof String s || s.isEmpty())` — lỗi.
- `if (!(o instanceof String s)) return;` → sau câu `if`, `s` dùng được.
- Trong Java 21, `str instanceof String t` (kiểu giống hệt) là hợp lệ; Java 17 thì báo lỗi.

### Vòng lặp

- `for (init; condition; update)`: cả ba phần đều tuỳ chọn. `for(;;)` là vòng vô hạn.
  `init` có thể khai báo nhiều biến **cùng kiểu**: `int i = 0, j = 10`.
- For-each dùng cho mảng và mọi `Iterable`. Biến lặp là **bản sao** giá trị (với object: bản sao tham chiếu).
- `do { } while (cond);` — nhớ dấu `;` cuối; thân chạy ít nhất một lần.
- `continue` trong `for` nhảy tới phần `update`; trong `while`/`do-while` nhảy tới phần kiểm tra điều kiện.
- `break LABEL` / `continue LABEL` áp dụng cho vòng lặp (hoặc khối, với `break`) mang nhãn đó.

### Unreachable code

Compiler báo lỗi nếu một lệnh chắc chắn không bao giờ chạy: sau `break`/`continue`/`return`/`throw`
trong cùng khối; sau `while(true)` không có `break`; thân của `while(false)` hay `for(;false;)`.
Lưu ý: `if (false) { ... }` **không** bị coi là unreachable (cố ý, để dùng như "conditional compilation").

## Lỗi và bẫy thường gặp (Exam traps)

1. Quên `break` → fall-through. `default` ở giữa vẫn có thể rơi xuống các case bên dưới.
2. Switch expression trên `int`/`String` thiếu `default` → lỗi biên dịch.
3. Khối `{}` trong switch expression thiếu `yield` → lỗi.
4. `case Number n` trước `case Integer i` → lỗi dominated.
5. `default` không bắt `null` → `NullPointerException` khi selector là `null`.
6. `else` gắn với `if` **gần nhất**, bất kể thụt lề.
7. `if (x = 5)` với `int x` → lỗi; nhưng với `boolean b`, `if (b = true)` biên dịch được.
8. For-each: gán biến lặp không thay đổi mảng.
9. `while (n++ < 3)` — nhớ lần kiểm tra cuối (sai) vẫn tăng `n`.
10. Biến pattern dùng với `||` → lỗi phạm vi.
11. `break` trong switch nằm trong vòng lặp chỉ thoát switch; `continue` thì áp dụng cho vòng lặp.
12. Selector `long` trong switch cổ điển → lỗi.

## Góc nhìn từ TypeScript

| TypeScript | Java 21 | Ghi chú |
|---|---|---|
| `if (value)` với giá trị truthy/falsy | Điều kiện **bắt buộc** là `boolean` | Không có truthy/falsy trong Java |
| `switch` chỉ có fall-through, so sánh `===` | Có cả `:` (fall-through) và `->` (không fall-through) | `->` giống cách viết an toàn hơn |
| Discriminated union + `switch (shape.kind)` + `never` để kiểm tra đầy đủ | `sealed interface` + record + pattern switch | Java kiểm tra đầy đủ ngay khi biên dịch, không cần mẹo `never` |
| Type guard: `if (typeof x === "string")` | `if (x instanceof String s)` | Java tạo luôn biến `s` đã có kiểu |
| Destructuring `const {x, y} = point` | Record pattern `if (o instanceof Point(int x, int y))` | Chỉ dùng trong `instanceof`/`switch` |
| `for (const x of arr)` | `for (int x : arr)` | Giống nhau |
| Label `outer:` + `break outer` | Giống hệt | Cả hai ngôn ngữ đều có |

## Tóm tắt

- `:` → fall-through, cần `break`. `->` → không fall-through.
- Switch expression phải đầy đủ; khối `{}` dùng `yield`.
- Pattern switch: thứ tự từ hẹp tới rộng; guard trước case không guard; `null` cần `case null`.
- Flow scoping: biến pattern có mặt ở chỗ chắc chắn đã gán (`&&`, nhánh đối của `if (!...) return`).
- `do-while` chạy ít nhất 1 lần; for-each không sửa mảng; nhãn dùng cho vòng lặp lồng nhau.
- Unreachable statement là lỗi biên dịch (trừ `if (false)`).

## Bài tập (có lời giải)

Mọi đáp án đã được `tools/book.py` biên dịch và chạy để xác nhận (code: `examples/questions/ch02/`).

### Câu hỏi

<!-- QUESTIONS:ch02 -->
#### Câu 02-01 · Dễ · objective 2.1

Chương trình sau in ra gì?

```java
public class Fall {
    public static void main(String[] args) {
        int x = 2;
        String r = "";
        switch (x) {
            case 1: r += "a";
            case 2: r += "b";
            case 3: r += "c"; break;
            default: r += "d";
        }
        System.out.println(r);
    }
}
```

- **A.** `b`
- **B.** `bc`
- **C.** `bcd`
- **D.** `abc`

#### Câu 02-02 · Dễ · objective 2.1

Chương trình sau in ra gì?

```java
public class Weekend {
    public static void main(String[] args) {
        String day = "SAT";
        int n = switch (day) {
            case "MON", "TUE" -> 1;
            case "SAT" -> {
                int k = 5;
                yield k * 2;
            }
            default -> 0;
        };
        System.out.println(n);
    }
}
```

- **A.** `5`
- **B.** `0`
- **C.** `10`
- **D.** `Không biên dịch được`

#### Câu 02-03 · Vừa · objective 2.1

Dòng nào gây lỗi biên dịch?

```java
public class Yield {
    public static void main(String[] args) {
        int v = 3;
        String a = switch (v) { case 1 -> "one"; default -> "other"; };                // L1
        String b = switch (v) { case 1: yield "one"; default: yield "other"; };        // L2
        String c = switch (v) { case 1 -> { yield "one"; } default -> "other"; };      // L3
        String d = switch (v) { case 1 -> "one"; case 2 -> "two"; };                   // L4
    }
}
```

- **A.** L1
- **B.** L2
- **C.** L3
- **D.** L4
- **E.** Không dòng nào

#### Câu 02-04 · Khó · objective 2.1

Chương trình sau in ra gì?

```java
public class Labels {
    public static void main(String[] args) {
        int count = 0;
        outer:
        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 4; j++) {
                if (j == i) continue outer;
                if (i + j > 4) break outer;
                count++;
            }
        }
        System.out.println(count);
    }
}
```

- **A.** `6`
- **B.** `4`
- **C.** `5`
- **D.** `3`

#### Câu 02-05 · Dễ · objective 2.1

Chương trình sau in ra gì?

```java
public class DoIt {
    public static void main(String[] args) {
        int i = 5;
        do {
            System.out.print(i + " ");
            i -= 2;
        } while (i > 5);
        System.out.println(i);
    }
}
```

- **A.** `3`
- **B.** `5 3`
- **C.** `5 3 1`
- **D.** `5`

#### Câu 02-06 · Vừa · objective 2.1, 3.5

Chương trình sau in ra gì?

```java
public class Guards {
    static String t(Object o) {
        return switch (o) {
            case Integer i when i > 10 -> "L";
            case Integer i -> "S";
            case String s when s.length() > 2 -> "W";
            case CharSequence cs -> "C";
            default -> "D";
        };
    }

    public static void main(String[] args) {
        System.out.println(t(5) + t(50) + t("hi") + t("hello")
                + t(new StringBuilder("x")) + t(1.0));
    }
}
```

- **A.** `SLCWCD`
- **B.** `SLWWCD`
- **C.** `LLCWCD`
- **D.** `SLCWDD`

#### Câu 02-07 · Khó · objective 2.1, 3.5

Chèn nhóm case nào vào chỗ `// INSERT CODE HERE` thì chương trình biên dịch được? **(Chọn 2 đáp án.)**

```java
public class Order {
    static String f(Object o) {
        return switch (o) {
            // INSERT CODE HERE
        };
    }

    public static void main(String[] args) {
        System.out.println(f("x"));
    }
}
```

- **A.** `case String s -> "S"; case CharSequence cs -> "C"; default -> "D";`
- **B.** `case CharSequence cs -> "C"; case String s -> "S"; default -> "D";`
- **C.** `case String s when s.isEmpty() -> "E"; case String s -> "S"; default -> "D";`
- **D.** `case String s -> "S"; case String s when s.isEmpty() -> "E"; default -> "D";`
- **E.** `case String s -> "S"; case Integer i -> "I";`

#### Câu 02-08 · Vừa · objective 2.1

Chương trình sau in ra gì?

```java
public class Loops {
    public static void main(String[] args) {
        int[] a = {1, 2, 3};
        for (int x : a) {
            x = x * 2;
        }
        int sum = 0;
        for (int i = 0; i < a.length; i++) {
            a[i] += i;
            sum += a[i];
        }
        System.out.println(sum);
    }
}
```

- **A.** `9`
- **B.** `12`
- **C.** `18`
- **D.** `6`

#### Câu 02-09 · Khó · objective 2.1

Chương trình sau in ra gì?

```java
public class DefaultFirst {
    static String f(int n) {
        String r = "";
        switch (n) {
            default: r += "d";
            case 1: r += "1";
            case 2: r += "2"; break;
            case 3: r += "3";
        }
        return r;
    }

    public static void main(String[] args) {
        System.out.println(f(1) + " " + f(3) + " " + f(9));
    }
}
```

- **A.** `12 3 d`
- **B.** `1 3 d12`
- **C.** `12 3 d12`
- **D.** `12 32 d12`

#### Câu 02-10 · Vừa · objective 2.1

Điền biểu thức nào vào chỗ `___` thì chương trình biên dịch được? **(Chọn 2 đáp án.)**

```java
public class Cond {
    public static void main(String[] args) {
        int x = 1;
        Boolean flag = Boolean.TRUE;
        if (___) System.out.println("ok");
    }
}
```

- **A.** `x`
- **B.** `x = 1`
- **C.** `flag`
- **D.** `x == 1 ? true : 0`
- **E.** `!(x > 2)`

#### Câu 02-11 · Dễ · objective 2.1

Chương trình sau in ra gì?

```java
public class Post {
    public static void main(String[] args) {
        int n = 0;
        while (n++ < 3) { }
        System.out.println(n);
    }
}
```

- **A.** `3`
- **B.** `2`
- **C.** `Vòng lặp vô hạn`
- **D.** `4`

#### Câu 02-12 · Khó · objective 2.1, 3.5

Chương trình sau in ra gì?

```java
public class Pairs {
    record Pair(Object a, Object b) {}

    static String m(Object o) {
        return switch (o) {
            case Pair(String s, Integer i) when i > 0 -> "SI+";
            case Pair(String s, Object x) -> "SO";
            case Pair(Object x, Integer i) -> "OI";
            case Pair p -> "P";
            default -> "D";
        };
    }

    public static void main(String[] args) {
        System.out.println(m(new Pair("a", 1)) + m(new Pair("a", -1)) + m(new Pair(1, 2))
                + m(new Pair(1, "b")) + m("z"));
    }
}
```

- **A.** `SOSOOIPD`
- **B.** `SI+SOOIPD`
- **C.** `SI+SOPPD`
- **D.** `Không biên dịch được`

#### Câu 02-13 · Vừa · objective 2.1

Hai phát biểu nào đúng? **(Chọn 2 đáp án.)**

- **A.** Switch cổ điển (không dùng pattern) có thể dùng selector kiểu `long`.
- **B.** Trong switch dạng arrow (`->`), không có fall-through giữa các nhánh.
- **C.** Switch **statement** trên enum không bắt buộc liệt kê hết các hằng số.
- **D.** `case null` dùng được khi selector có kiểu `int`.
- **E.** `yield` dùng được trong switch **statement** để thoát khỏi switch.

#### Câu 02-14 · Vừa · objective 2.1, 3.5

Chương trình sau in ra gì?

```java
public class Flow {
    static String f(Object o) {
        if (!(o instanceof Integer n) || n < 0) return "no";
        return "int " + (n + 1);
    }

    public static void main(String[] args) {
        System.out.println(f(5) + " | " + f(-1) + " | " + f("x"));
    }
}
```

- **A.** `int 6 | int 0 | no`
- **B.** `Không biên dịch được: n không dùng được sau if`
- **C.** `int 6 | no | no`
- **D.** `Ném ClassCastException với "x"`

#### Câu 02-15 · Khó · objective 2.1, 3.5

Dòng nào gây lỗi biên dịch?

```java
public class Scope {
    public static void main(String[] args) {
        Object o = "abc";
        if (o instanceof String s && s.length() > 2) System.out.println(s);   // L1
        if (o instanceof String t || t.isEmpty()) System.out.println("?");    // L2
        if (!(o instanceof String u)) return;
        System.out.println(u.length());                                         // L3
        int s = 5;                                                              // L4
    }
}
```

- **A.** L1
- **B.** L2
- **C.** L3
- **D.** L4
- **E.** L2 và L4

#### Câu 02-16 · Dễ · objective 2.1

Chương trình sau in ra gì?

```java
public class TwoVars {
    public static void main(String[] args) {
        for (int i = 0, j = 5; i < j; i++, j--)
            System.out.print(i + j + " ");
    }
}
```

- **A.** `05 14 23`
- **B.** `5 5 5 5`
- **C.** `Không biên dịch được`
- **D.** `5 5 5`

#### Câu 02-17 · Khó · objective 2.1

Đoạn code nào, chèn vào chỗ `// INSERT CODE HERE`, in ra đúng `2 4`? **(Chọn 3 đáp án.)**

```java
public class Evens {
    public static void main(String[] args) {
        // INSERT CODE HERE
        System.out.println();
    }
}
```

- **A.** `for (int i = 1; i <= 5; i++) { if (i % 2 != 0) continue; System.out.print(i + " "); }`
- **B.** `int i = 0; while (i < 5) { i += 2; System.out.print(i + " "); }`
- **C.** `int i = 0; do { i += 2; if (i > 4) break; System.out.print(i + " "); } while (true);`
- **D.** `for (int i = 2; i < 5; i += 2) System.out.print(i + " ");`
- **E.** `for (int i = 0; i < 5; i++) if (i % 2 == 0) System.out.print(i + " ");`

#### Câu 02-18 · Vừa · objective 2.1

Chương trình sau in ra gì?

```java
public class Strings {
    public static void main(String[] args) {
        String s = "Java";
        switch (s.toLowerCase()) {
            case "JAVA" -> System.out.print("A");
            case "java" -> System.out.print("B");
            default -> System.out.print("C");
        }
        switch (s) {
            case "java": System.out.print("D");
            default: System.out.print("E");
            case "Java": System.out.print("F");
        }
    }
}
```

- **A.** `BEF`
- **B.** `BF`
- **C.** `BDEF`
- **D.** `AF`

#### Câu 02-19 · Khó · objective 2.1

Chương trình sau in ra gì?

```java
public class LoopSwitch {
    public static void main(String[] args) {
        int total = 0;
        for (int i = 0; i < 5; i++) {
            switch (i) {
                case 1: continue;
                case 3: break;
                default: total += i;
            }
            total += 10;
        }
        System.out.println(total);
    }
}
```

- **A.** `46`
- **B.** `36`
- **C.** `40`
- **D.** `26`

#### Câu 02-20 · Vừa · objective 2.1

Dòng nào gây lỗi biên dịch?

```java
public class Reach {
    public static void main(String[] args) {
        int x = 0;
        while (x < 3) x++;                      // L1
        for (;;) { if (x > 5) break; x++; }     // L2
        do x--; while (x > 0);                   // L3
        while (false) { x++; }                   // L4
        System.out.println(x);
    }
}
```

- **A.** L1
- **B.** L2
- **C.** L3
- **D.** L4
- **E.** Không có lỗi; in ra 0
<!-- /QUESTIONS -->

### Lời giải

<!-- ANSWERS:ch02 -->
#### Câu 02-01 — Đáp án: **B** (Dễ · objective 2.1)

- **Vì sao đúng:** Switch dạng `:` cổ điển có **fall-through**: nhảy vào `case 2`, thêm `b`, rồi rơi xuống `case 3` thêm `c`, gặp `break` thì dừng. `default` không chạy.
- **A sai:** Không có `break` sau `case 2`, nên tiếp tục rơi xuống `case 3`.
- **C sai:** `break` ở `case 3` dừng switch trước khi tới `default`.
- **D sai:** Switch nhảy thẳng tới `case 2`; `case 1` không chạy.
- *Kiểm chứng:* `examples/questions/ch02/Q02_01/` — output confirmed (`python3 tools/book.py questions ch02`).

#### Câu 02-02 — Đáp án: **C** (Dễ · objective 2.1)

- **Vì sao đúng:** Switch expression trên `String` so khớp bằng `equals`. Nhánh `"SAT"` là một khối `{}` nên phải trả về giá trị bằng `yield`: `5 * 2 = 10`. Nhánh arrow không có fall-through.
- **A sai:** `yield k * 2` trả về 10, không phải giá trị của `k`.
- **B sai:** `"SAT"` khớp với `case "SAT"` nên không vào `default`.
- **D sai:** Khối `{}` trong nhánh arrow hợp lệ khi kết thúc bằng `yield`.
- *Kiểm chứng:* `examples/questions/ch02/Q02_02/` — output confirmed (`python3 tools/book.py questions ch02`).

#### Câu 02-03 — Đáp án: **D** (Vừa · objective 2.1)

- **Vì sao đúng:** Switch expression phải **đầy đủ (exhaustive)**. Với selector `int`, không thể liệt kê hết giá trị, nên bắt buộc có `default`. L4 thiếu `default` → "the switch expression does not cover all possible input values".
- **A sai:** Arrow + `default` là dạng chuẩn của switch expression.
- **B sai:** Switch expression được phép dùng dạng `:` nếu mỗi nhánh trả về bằng `yield`.
- **C sai:** Khối `{ yield ...; }` trong nhánh arrow là hợp lệ.
- **E sai:** L4 lỗi vì thiếu `default`.
- *Kiểm chứng:* `examples/questions/ch02/Q02_03/` — compile error confirmed at ['L4'] (`python3 tools/book.py questions ch02`).

#### Câu 02-04 — Đáp án: **C** (Khó · objective 2.1)

- **Vì sao đúng:** `continue outer` bỏ phần còn lại của vòng trong và sang `i` tiếp theo. i=0: không đếm. i=1: đếm j=0 (1). i=2: đếm j=0, 1 (3). i=3: đếm j=0 (4), j=1 (5); tới j=2 thì `3 + 2 > 4` → `break outer` thoát cả hai vòng.
- **A sai:** Vòng i=3 dừng ở j=2 do `break outer`, nên chỉ có 5 lần đếm.
- **B sai:** Với i=3, cả j=0 và j=1 đều được đếm (3+1 = 4 không lớn hơn 4).
- **D sai:** Xem cách đếm ở phần giải thích: tổng là 5.
- *Kiểm chứng:* `examples/questions/ch02/Q02_04/` — output confirmed (`python3 tools/book.py questions ch02`).

#### Câu 02-05 — Đáp án: **B** (Dễ · objective 2.1)

- **Vì sao đúng:** `do-while` chạy thân vòng lặp **ít nhất một lần** trước khi kiểm tra điều kiện: in `5 `, `i` thành 3, điều kiện `3 > 5` sai nên dừng; sau đó in `3`.
- **A sai:** Thân `do` luôn chạy lần đầu, nên có in `5 `.
- **C sai:** Điều kiện `3 > 5` sai nên vòng lặp chỉ chạy một lần.
- **D sai:** Sau vòng lặp còn lệnh `println(i)` in ra 3.
- *Kiểm chứng:* `examples/questions/ch02/Q02_05/` — output confirmed (`python3 tools/book.py questions ch02`).

#### Câu 02-06 — Đáp án: **A** (Vừa · objective 2.1, 3.5)

- **Vì sao đúng:** Các case được thử từ trên xuống. 5 → `S`; 50 thoả guard → `L`; `"hi"` không thoả guard `length() > 2` nên rơi xuống `CharSequence` → `C`; `"hello"` → `W`; `StringBuilder` là `CharSequence` → `C`; `Double` → `D`.
- **B sai:** `"hi"` có độ dài 2, không thoả `when s.length() > 2`.
- **C sai:** 5 không thoả `i > 10` nên vào `case Integer i` → `S`.
- **D sai:** `StringBuilder` implements `CharSequence`, nên khớp `case CharSequence cs`.
- *Kiểm chứng:* `examples/questions/ch02/Q02_06/` — output confirmed (`python3 tools/book.py questions ch02`).

#### Câu 02-07 — Đáp án: **A, C** (Khó · objective 2.1, 3.5)

- **Vì sao đúng:** Case hẹp (cụ thể hơn) phải đứng trước case rộng. A: `String` trước `CharSequence` — đúng thứ tự. C: case có guard đứng trước case cùng kiểu không guard — đúng. Cả hai có `default` nên đầy đủ.
- **B sai:** `CharSequence` đứng trước sẽ che (dominate) `String` → lỗi "dominated by a preceding case label".
- **D sai:** `case String s` không guard đã bắt mọi `String`, nên case có guard phía sau bị che → lỗi.
- **E sai:** Selector kiểu `Object` mà không có `default` (hay case `Object`) → switch không đầy đủ → lỗi.
- *Kiểm chứng:* `examples/questions/ch02/Q02_07/` — variants: AC satisfy compiles (`python3 tools/book.py questions ch02`).

#### Câu 02-08 — Đáp án: **A** (Vừa · objective 2.1)

- **Vì sao đúng:** Trong for-each, `x` là **bản sao** của phần tử; gán `x` không đổi mảng. Vòng thứ hai biến mảng thành `{1, 3, 5}` và tổng là 9.
- **B sai:** 12 là tổng khi mảng đã bị nhân đôi `{2, 4, 6}` — nhưng for-each không sửa mảng.
- **C sai:** Như B, mảng không bị nhân đôi.
- **D sai:** 6 là tổng ban đầu; vòng thứ hai cộng thêm chỉ số vào từng phần tử.
- *Kiểm chứng:* `examples/questions/ch02/Q02_08/` — output confirmed (`python3 tools/book.py questions ch02`).

#### Câu 02-09 — Đáp án: **C** (Khó · objective 2.1)

- **Vì sao đúng:** `default` được chọn khi không case nào khớp, **bất kể vị trí**; sau đó vẫn fall-through như thường. f(1): "1" rồi rơi xuống "2", `break`. f(3): "3" là case cuối. f(9): vào `default` "d", rơi xuống "1", "2", `break`.
- **A sai:** Sau `default` không có `break`, nên tiếp tục rơi xuống `case 1` và `case 2`.
- **B sai:** `case 1` không có `break`, nên rơi xuống `case 2`: f(1) là "12".
- **D sai:** `case 3` là case cuối cùng; không có gì chạy sau nó, và không quay lại đầu switch.
- *Kiểm chứng:* `examples/questions/ch02/Q02_09/` — output confirmed (`python3 tools/book.py questions ch02`).

#### Câu 02-10 — Đáp án: **C, E** (Vừa · objective 2.1)

- **Vì sao đúng:** Điều kiện của `if` phải có kiểu `boolean` (hoặc `Boolean`, sẽ được unboxing). `flag` là `Boolean` → OK. `!(x > 2)` là `boolean` → OK.
- **A sai:** `int` không tự đổi sang `boolean` như trong TypeScript/JavaScript.
- **B sai:** `x = 1` là phép gán, có kiểu `int`, không phải `boolean`.
- **D sai:** Hai nhánh là `boolean` và `int`, kiểu kết quả không phải `boolean` → lỗi incompatible types.
- *Kiểm chứng:* `examples/questions/ch02/Q02_10/` — variants: CE satisfy compiles (`python3 tools/book.py questions ch02`).

#### Câu 02-11 — Đáp án: **D** (Dễ · objective 2.1)

- **Vì sao đúng:** `n++ < 3` so sánh giá trị **cũ** rồi mới tăng. Các lần kiểm tra: 0<3 (n=1), 1<3 (n=2), 2<3 (n=3), 3<3 sai (n vẫn tăng thành 4). In ra 4.
- **A sai:** Lần kiểm tra cuối cùng (sai) vẫn tăng `n` thêm 1.
- **B sai:** Có 4 lần kiểm tra, mỗi lần tăng `n` một đơn vị.
- **C sai:** `n` tăng mỗi lần kiểm tra, nên điều kiện sẽ sai.
- *Kiểm chứng:* `examples/questions/ch02/Q02_11/` — output confirmed (`python3 tools/book.py questions ch02`).

#### Câu 02-12 — Đáp án: **B** (Khó · objective 2.1, 3.5)

- **Vì sao đúng:** Record pattern "mở" record và so khớp từng thành phần theo kiểu. `("a", 1)` khớp case đầu (guard đúng). `("a", -1)` guard sai → `Pair(String, Object)` → SO. `(1, 2)` → `Pair(Object, Integer)` → OI. `(1, "b")` → `Pair p` → P. `"z"` không phải `Pair` → D.
- **A sai:** `("a", 1)` thoả guard `i > 0`, nên khớp case đầu tiên là `SI+`.
- **C sai:** `(1, 2)` có thành phần thứ hai là `Integer`, khớp `Pair(Object x, Integer i)` → OI.
- **D sai:** Không case nào bị che: mỗi case sau rộng hơn hoặc khác case trước, và có `default`.
- *Kiểm chứng:* `examples/questions/ch02/Q02_12/` — output confirmed (`python3 tools/book.py questions ch02`).

#### Câu 02-13 — Đáp án: **B, C** (Vừa · objective 2.1)

- **Vì sao đúng:** B: mỗi nhánh arrow chạy độc lập, không rơi xuống nhánh sau. C: switch **statement** kiểu cổ điển trên enum (không có pattern, không có `case null`) không cần đầy đủ; hằng số không khớp thì đơn giản là không làm gì.
- **A sai:** Switch cổ điển chỉ nhận `char`, `byte`, `short`, `int` (và wrapper), `String`, enum. `long` → lỗi.
- **D sai:** `case null` chỉ dùng được khi selector là kiểu tham chiếu (reference type); `int` không bao giờ `null`.
- **E sai:** `yield` chỉ dùng để trả giá trị từ switch **expression**; trong switch statement dùng `break`.
- *Kiểm chứng:* `examples/questions/ch02/Q02_13/` — each option proven true/false by a program (`python3 tools/book.py questions ch02`).

#### Câu 02-14 — Đáp án: **C** (Vừa · objective 2.1, 3.5)

- **Vì sao đúng:** Flow scoping: `n` có mặt ở vế phải của `||` (vì chỉ tới đó khi `instanceof` đúng) và cả **sau** câu `if`, vì nhánh `if` luôn `return`. f(5) → `int 6`; f(-1) → `n < 0` → `no`; f("x") → không phải Integer → `no`.
- **A sai:** -1 thoả `n < 0` nên trả về `no`.
- **B sai:** Vì nhánh `if` luôn thoát bằng `return`, compiler biết `n` chắc chắn đã được gán ở phía sau.
- **D sai:** `instanceof` không bao giờ ném `ClassCastException`; nó chỉ trả về `false`.
- *Kiểm chứng:* `examples/questions/ch02/Q02_14/` — output confirmed (`python3 tools/book.py questions ch02`).

#### Câu 02-15 — Đáp án: **B** (Khó · objective 2.1, 3.5)

- **Vì sao đúng:** Ở L2, vế phải của `||` chỉ chạy khi `instanceof` **sai**, lúc đó `t` chưa được gán → `t` không nằm trong phạm vi → lỗi "cannot find symbol". L1 hợp lệ vì `&&`. L3 hợp lệ vì câu `if` phía trên luôn `return`. L4 hợp lệ vì biến pattern `s` ở L1 chỉ sống trong câu `if` đó.
- **A sai:** Với `&&`, vế phải chỉ chạy khi `instanceof` đúng, nên `s` đã được gán.
- **C sai:** `if (!(o instanceof String u)) return;` làm `u` có mặt ở các lệnh sau.
- **D sai:** Phạm vi của `s` (pattern ở L1) kết thúc cùng câu `if` L1, nên khai báo `int s` mới là hợp lệ.
- **E sai:** L4 hợp lệ (xem D).
- *Kiểm chứng:* `examples/questions/ch02/Q02_15/` — compile error confirmed at ['L2'] (`python3 tools/book.py questions ch02`).

#### Câu 02-16 — Đáp án: **D** (Dễ · objective 2.1)

- **Vì sao đúng:** `for` cho phép khai báo nhiều biến cùng kiểu và nhiều biểu thức cập nhật cách nhau bởi dấu phẩy. `i + j + " "` tính từ trái: `i + j` là phép cộng số (luôn bằng 5), rồi mới nối chuỗi. Vòng chạy với (0,5), (1,4), (2,3); tới (3,2) thì dừng.
- **A sai:** `i + j` được tính trước khi gặp chuỗi, nên là phép cộng số, không phải nối chuỗi.
- **B sai:** Chỉ có 3 lần lặp: (3,2) không thoả `i < j`.
- **C sai:** Khai báo `int i = 0, j = 5` và cập nhật `i++, j--` đều hợp lệ.
- *Kiểm chứng:* `examples/questions/ch02/Q02_16/` — output confirmed (`python3 tools/book.py questions ch02`).

#### Câu 02-17 — Đáp án: **A, C, D** (Khó · objective 2.1)

- **Vì sao đúng:** A bỏ qua số lẻ bằng `continue` → 2 4. C tăng 2 mỗi lần, `break` khi vượt 4 → 2 4. D bắt đầu từ 2, bước 2, dừng trước 5 → 2 4.
- **B sai:** Điều kiện kiểm tra **trước** khi cộng: khi i = 4 vẫn vào vòng, cộng thành 6 và in `2 4 6`.
- **E sai:** 0 cũng là số chẵn, nên in `0 2 4`.
- *Kiểm chứng:* `examples/questions/ch02/Q02_17/` — variants: ACD satisfy output (`python3 tools/book.py questions ch02`).

#### Câu 02-18 — Đáp án: **B** (Vừa · objective 2.1)

- **Vì sao đúng:** Switch trên `String` so khớp bằng `equals` (phân biệt hoa thường). Switch đầu: `"java"` → B. Switch thứ hai: `"Java"` khớp đúng `case "Java"`, là case cuối nên chỉ in F.
- **A sai:** `default` chỉ chạy khi không case nào khớp; ở đây `case "Java"` khớp.
- **C sai:** `"Java"` không bằng `"java"` (phân biệt hoa thường), nên không bắt đầu từ `case "java"`.
- **D sai:** `s.toLowerCase()` là `"java"`, không khớp `"JAVA"`.
- *Kiểm chứng:* `examples/questions/ch02/Q02_18/` — output confirmed (`python3 tools/book.py questions ch02`).

#### Câu 02-19 — Đáp án: **A** (Khó · objective 2.1)

- **Vì sao đúng:** `break` trong switch chỉ thoát **switch**, còn `continue` áp dụng cho **vòng lặp**. i=0: +0 +10; i=1: `continue` bỏ qua `+10`; i=2: +2 +10; i=3: `break` rồi +10; i=4: +4 +10. Tổng 10+12+10+14 = 46.
- **B sai:** i=3 vẫn cộng 10 vì `break` chỉ thoát switch, không thoát vòng lặp.
- **C sai:** i=1 không cộng 10 vì `continue` nhảy sang lần lặp tiếp theo; tổng là 46.
- **D sai:** Tính lại: chỉ có i=1 bị bỏ `+10`.
- *Kiểm chứng:* `examples/questions/ch02/Q02_19/` — output confirmed (`python3 tools/book.py questions ch02`).

#### Câu 02-20 — Đáp án: **D** (Vừa · objective 2.1)

- **Vì sao đúng:** `while (false)` có điều kiện là hằng số `false`, nên thân vòng lặp **không thể tới (unreachable)** → lỗi biên dịch. L2 hợp lệ vì có `break`, nên lệnh phía sau vẫn tới được.
- **A sai:** Vòng `while` với điều kiện bình thường là hợp lệ.
- **B sai:** `for(;;)` có `break` bên trong, nên code phía sau vẫn tới được.
- **C sai:** `do x--; while (x > 0);` là cú pháp hợp lệ (thân một lệnh không cần `{}`).
- **E sai:** L4 lỗi biên dịch (unreachable statement).
- *Kiểm chứng:* `examples/questions/ch02/Q02_20/` — compile error confirmed at ['L4'] (`python3 tools/book.py questions ch02`).
<!-- /ANSWERS -->

## Đọc thêm (link chính thức — bị chặn trong sandbox nên mình chưa mở được)

- JLS §14.11 The switch Statement, §15.28 Switch Expressions, §14.30 Patterns:
  https://docs.oracle.com/javase/specs/jls/se21/html/jls-14.html
- JEP 441 Pattern Matching for switch, JEP 440 Record Patterns: https://openjdk.org/jeps/441 , https://openjdk.org/jeps/440

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:

- Kiểm thử của javac cho pattern switch trong mã nguồn JDK 21 (thư mục `test/langtools/tools/javac/patterns`):
  https://raw.githubusercontent.com/openjdk/jdk21u/master/test/langtools/tools/javac/patterns/SwitchErrors.java
- `MatchException.java` (exception khi pattern switch không khớp lúc chạy): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/lang/MatchException.java
- Mọi hành vi trong chương đều được kiểm chứng bằng cách chạy code với OpenJDK 21.0.10 (xem output ở trên).
