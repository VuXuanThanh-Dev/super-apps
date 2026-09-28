# Chương 1 — Dữ liệu: số, boolean, chuỗi và ngày giờ

## Mục tiêu

Sau chương này, bạn làm được:

- Dùng đúng 8 kiểu nguyên thủy (primitive type) và các lớp bao (wrapper class) tương ứng (objective 1.1).
- Tính đúng giá trị biểu thức số học và logic: thứ tự ưu tiên (precedence), nâng kiểu (numeric promotion),
  ép kiểu (casting), và các hàm của `Math` (objective 1.2).
- Xử lý chuỗi với `String`, `StringBuilder` và text block (objective 1.3).
- Làm việc với ngày giờ: `LocalDate`, `LocalTime`, `LocalDateTime`, `ZonedDateTime`, `Instant`,
  `Period`, `Duration`, múi giờ và giờ mùa hè — daylight saving time (DST) (objective 1.4).

## Giải thích đơn giản

**Primitive và object.** Java có 8 kiểu nguyên thủy: `byte`, `short`, `int`, `long`, `float`, `double`,
`char`, `boolean`. Biến primitive chứa **giá trị** trực tiếp. Mọi thứ khác là **object**; biến chỉ chứa
**tham chiếu (reference)** tới object. Mỗi primitive có một wrapper class: `Integer`, `Long`, `Character`,
`Boolean`… Java tự chuyển qua lại giữa hai loại: **autoboxing** (int → Integer) và **unboxing** (Integer → int).

**Biểu thức.** Khi tính toán, Java "nâng" kiểu nhỏ lên kiểu lớn. Quy tắc quan trọng nhất cho đề thi:
`byte`, `short`, `char` khi tham gia phép toán **luôn thành `int`**. Muốn gán về kiểu nhỏ hơn thì phải
ép kiểu (cast) — trừ vài trường hợp đặc biệt (hằng số compile-time, toán tử `+=`).

**Chuỗi.** `String` là **bất biến (immutable)**: mọi method như `toUpperCase()` trả về chuỗi **mới**,
chuỗi cũ không đổi. `StringBuilder` thì **thay đổi được (mutable)**: `append`, `insert`, `reverse`…
sửa trực tiếp object và trả về chính nó.

**Ngày giờ.** Gói `java.time` cũng bất biến. `LocalDate` = ngày không có múi giờ, `LocalTime` = giờ,
`LocalDateTime` = cả hai, `ZonedDateTime` = có múi giờ, `Instant` = một điểm trên trục thời gian (UTC).
`Period` đo theo năm/tháng/ngày (lịch), `Duration` đo theo giây/nano (đồng hồ).

## Ví dụ

Tất cả ví dụ nằm trong `examples/ch01/`. Chạy lại toàn bộ: `python3 tools/book.py examples ch01`.
Output bên dưới là output thật, chạy bằng OpenJDK 21.0.10 (locale `en_US`, múi giờ UTC).

### 1. Primitive, literal và giá trị mặc định

Field (biến của lớp) có giá trị mặc định (`0`, `false`, `'\u0000'`, `null`). Biến cục bộ (local variable)
**không** có — dùng trước khi gán sẽ lỗi biên dịch.

<!-- EX:Ex01_Primitives -->
`examples/ch01/Ex01_Primitives.java`

```java
// objective: 1.1
// 8 kiểu nguyên thủy (primitive), literal và giá trị mặc định của field.
public class Ex01_Primitives {
    static int defaultInt;        // field: có giá trị mặc định
    static boolean defaultBool;
    static char defaultChar;
    static double defaultDouble;

    public static void main(String[] args) {
        System.out.println("byte  : " + Byte.MIN_VALUE + " .. " + Byte.MAX_VALUE);
        System.out.println("short : " + Short.MIN_VALUE + " .. " + Short.MAX_VALUE);
        System.out.println("int   : " + Integer.MIN_VALUE + " .. " + Integer.MAX_VALUE);
        System.out.println("long  : " + Long.MIN_VALUE + " .. " + Long.MAX_VALUE);
        System.out.println("char  : " + (int) Character.MIN_VALUE + " .. " + (int) Character.MAX_VALUE);
        System.out.println("float max  = " + Float.MAX_VALUE);
        System.out.println("double max = " + Double.MAX_VALUE);

        int million = 1_000_000;      // dấu gạch dưới giúp dễ đọc
        int hex = 0xFF, oct = 017, bin = 0b1010;
        long big = 3_000_000_000L;    // cần hậu tố L
        float f = 1.5f;               // cần hậu tố f
        char c = 'A' + 1;             // hằng số int vừa kiểu char → OK
        System.out.println(million + " " + hex + " " + oct + " " + bin + " " + big + " " + f + " " + c);

        System.out.println("defaults: " + defaultInt + " " + defaultBool + " ["
                + (int) defaultChar + "] " + defaultDouble);
    }
}
```

Output thật (JDK 21.0.10):

```text
byte  : -128 .. 127
short : -32768 .. 32767
int   : -2147483648 .. 2147483647
long  : -9223372036854775808 .. 9223372036854775807
char  : 0 .. 65535
float max  = 3.4028235E38
double max = 1.7976931348623157E308
1000000 255 15 10 3000000000 1.5 B
defaults: 0 false [0] 0.0
```
<!-- /EX -->

### 2. Wrapper class và cache của `Integer`

<!-- EX:Ex02_Wrappers -->
`examples/ch01/Ex02_Wrappers.java`

```java
// objective: 1.1
// Wrapper class, autoboxing/unboxing, cache của Integer và bẫy null.
public class Ex02_Wrappers {
    public static void main(String[] args) {
        Integer a = 127, b = 127;        // autoboxing dùng Integer.valueOf → có cache -128..127
        Integer c = 128, d = 128;
        System.out.println("127 == 127 ? " + (a == b));
        System.out.println("128 == 128 ? " + (c == d));
        System.out.println("128 equals 128 ? " + c.equals(d));

        int p = Integer.parseInt("42");      // trả về int (primitive)
        Integer w = Integer.valueOf("42");   // trả về Integer (object)
        System.out.println(p + w);           // unboxing rồi cộng: 84

        Long l = 42L;
        System.out.println("Long(42).equals(42) ? " + l.equals(42)); // 42 boxing thành Integer!

        System.out.println(Character.isDigit('7') + " " + Character.toUpperCase('x')
                + " " + Boolean.parseBoolean("TRUE") + " " + Boolean.parseBoolean("yes"));

        Integer nothing = null;
        try {
            int boom = nothing;              // unboxing null → NullPointerException
            System.out.println(boom);
        } catch (NullPointerException e) {
            System.out.println("NPE khi unboxing null");
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
127 == 127 ? true
128 == 128 ? false
128 equals 128 ? true
84
Long(42).equals(42) ? false
true X true false
NPE khi unboxing null
```
<!-- /EX -->

### 3. Numeric promotion và tràn số

<!-- EX:Ex03_Promotion -->
`examples/ch01/Ex03_Promotion.java`

```java
// objective: 1.2
// Numeric promotion: byte/short/char + ... luôn thành int; compound assignment tự ép kiểu.
public class Ex03_Promotion {
    public static void main(String[] args) {
        byte x = 10, y = 20;
        // byte z = x + y;        // KHÔNG biên dịch: x + y là int
        byte z = (byte) (x + y);  // phải ép kiểu
        x += 5;                   // OK: += có ép kiểu ngầm (implicit cast)
        System.out.println(z + " " + x);

        short s = 1;
        char ch = 'a';
        var r1 = s + ch;          // int
        var r2 = 1 + 2L;          // long
        var r3 = 1L + 2.0f;       // float
        var r4 = 'a' + 1.0;       // double
        System.out.println(((Object) r1).getClass().getSimpleName() + " "
                + ((Object) r2).getClass().getSimpleName() + " "
                + ((Object) r3).getClass().getSimpleName() + " "
                + ((Object) r4).getClass().getSimpleName());

        int max = Integer.MAX_VALUE;
        System.out.println("overflow: " + (max + 1));       // tràn số, không có exception
        long ok = max + 1L;                                 // tính bằng long ngay từ đầu
        System.out.println("long    : " + ok);
        long wrong = max * 2;                               // nhân bằng int rồi mới mở rộng
        System.out.println("int*int : " + wrong);
    }
}
```

Output thật (JDK 21.0.10):

```text
30 15
Integer Long Float Double
overflow: -2147483648
long    : 2147483648
int*int : -2
```
<!-- /EX -->

### 4. Ép kiểu (casting)

<!-- EX:Ex04_Casting -->
`examples/ch01/Ex04_Casting.java`

```java
// objective: 1.2
// Ép kiểu thu hẹp (narrowing) cắt bit; ép double → int bỏ phần thập phân.
public class Ex04_Casting {
    public static void main(String[] args) {
        System.out.println((int) 3.99);         // 3 (cắt, không làm tròn)
        System.out.println((int) -3.99);        // -3
        System.out.println((byte) 200);         // 200 - 256 = -56
        System.out.println((short) 70000);      // 70000 - 65536 = 4464
        System.out.println((char) 66);          // B
        System.out.println((int) 'z');          // 122
        System.out.println((int) 1e20);         // bão hòa ở Integer.MAX_VALUE
        System.out.println((long) Double.NaN);  // NaN → 0

        final int small = 100;
        byte fits = small;                      // hằng số compile-time vừa byte → OK không cần cast
        System.out.println(fits);

        double d = 10 / 4;                      // chia int trước → 2, rồi mới thành 2.0
        double e = 10 / 4.0;
        System.out.println(d + " " + e);
    }
}
```

Output thật (JDK 21.0.10):

```text
3
-3
-56
4464
B
122
2147483647
0
100
2.0 2.5
```
<!-- /EX -->

### 5. Toán tử và thứ tự ưu tiên

<!-- EX:Ex05_Operators -->
`examples/ch01/Ex05_Operators.java`

```java
// objective: 1.2
// Thứ tự ưu tiên (precedence), ++/--, short-circuit, % với số âm.
public class Ex05_Operators {
    static boolean check(String name, boolean v) {
        System.out.print(name + " ");
        return v;
    }

    public static void main(String[] args) {
        int i = 5;
        int j = i++ + ++i;       // 5 + 7
        System.out.println("i=" + i + " j=" + j);

        System.out.println(2 + 3 * 4 - 6 / 4);    // 2 + 12 - 1 = 13
        System.out.println(-7 / 2 + " " + -7 % 2 + " " + 7 % -2);
        System.out.println(1 + 2 + "3" + 4 + 5);  // "3345"

        boolean r = check("A", false) && check("B", true);   // B không chạy
        System.out.println("-> " + r);
        r = check("A", false) & check("B", true);            // & luôn chạy cả hai
        System.out.println("-> " + r);
        r = check("A", true) || check("B", true);
        System.out.println("-> " + r);

        int k = 10;
        k += k++ + ++k;          // k = 10 + (10 + 12)
        System.out.println("k=" + k);

        int t = 3;
        String size = t > 5 ? "big" : t > 2 ? "medium" : "small";
        System.out.println(size + " " + (5 & 3) + " " + (5 | 3) + " " + (5 ^ 3) + " " + (~5));
    }
}
```

Output thật (JDK 21.0.10):

```text
i=7 j=12
13
-3 -1 1
3345
A -> false
A B -> false
A -> true
k=32
medium 1 7 6 -6
```
<!-- /EX -->

### 6. Math API

<!-- EX:Ex06_MathApi -->
`examples/ch01/Ex06_MathApi.java`

```java
// objective: 1.2
// Các hàm hay gặp của Math.
public class Ex06_MathApi {
    public static void main(String[] args) {
        System.out.println(Math.round(2.5) + " " + Math.round(-2.5) + " " + Math.round(2.4f));
        System.out.println(Math.floor(-1.1) + " " + Math.ceil(-1.1) + " " + Math.rint(2.5));
        System.out.println(Math.max(3, 7L) + " " + Math.min(-0.0, 0.0) + " " + Math.abs(-4.5));
        System.out.println(Math.pow(2, 10) + " " + Math.sqrt(-1) + " " + Math.cbrt(27));
        System.out.println(Math.abs(Integer.MIN_VALUE));        // vẫn âm! (tràn số)
        System.out.println(Math.floorDiv(-7, 2) + " " + Math.floorMod(-7, 2));
        System.out.println(1.0 / 0 + " " + -1.0 / 0 + " " + 0.0 / 0);
        System.out.println(0.1 + 0.2);
        try {
            System.out.println(Math.addExact(Integer.MAX_VALUE, 1));
        } catch (ArithmeticException e) {
            System.out.println("ArithmeticException: " + e.getMessage());
        }
        try {
            System.out.println(10 / 0);
        } catch (ArithmeticException e) {
            System.out.println("ArithmeticException: " + e.getMessage());
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
3 -2 2
-2.0 -1.0 2.0
7 -0.0 4.5
1024.0 NaN 3.0
-2147483648
-4 1
Infinity -Infinity NaN
0.30000000000000004
ArithmeticException: integer overflow
ArithmeticException: / by zero
```
<!-- /EX -->

### 7. String

<!-- EX:Ex07_Strings -->
`examples/ch01/Ex07_Strings.java`

```java
// objective: 1.3
// String bất biến (immutable), string pool, các method hay gặp.
public class Ex07_Strings {
    public static void main(String[] args) {
        String s1 = "java";
        String s2 = "ja" + "va";          // hằng số compile-time → cùng object trong pool
        String part = "ja";
        String s3 = part + "va";          // tạo lúc chạy → object mới
        System.out.println((s1 == s2) + " " + (s1 == s3) + " " + s1.equals(s3) + " " + (s1 == s3.intern()));

        String s = "  Hello World  ";
        s.toUpperCase();                  // kết quả bị bỏ đi: String không đổi
        System.out.println("[" + s + "]");
        System.out.println("[" + s.strip() + "] [" + s.stripLeading() + "] [" + s.trim().toLowerCase() + "]");

        String t = "banana";
        System.out.println(t.indexOf('a') + " " + t.indexOf("an", 2) + " " + t.lastIndexOf('a')
                + " " + t.charAt(2) + " " + t.substring(1, 3) + " " + t.substring(3));
        System.out.println(t.replace('a', 'o') + " " + t.replace("an", "") + " " + t.contains("nan")
                + " " + t.startsWith("ban") + " " + t.startsWith("na", 2));
        System.out.println("ab".repeat(3) + " " + " ".isBlank() + " " + "".isEmpty() + " " + "A".compareTo("C")
                + " " + "abc".equalsIgnoreCase("ABC"));
        System.out.println(String.join("-", "a", "b", "c") + " " + "a,b,,c".split(",").length
                + " " + "x".concat("y") + " " + String.valueOf(3.0));
        System.out.println("%s has %d chars".formatted(t, t.length()));
        try {
            System.out.println(t.substring(4, 2));
        } catch (StringIndexOutOfBoundsException e) {
            System.out.println("StringIndexOutOfBoundsException");
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
true false true true
[  Hello World  ]
[Hello World] [Hello World  ] [hello world]
1 3 5 n an ana
bonono ba true true true
ababab true true -2 true
a-b-c 4 xy 3.0
banana has 6 chars
StringIndexOutOfBoundsException
```
<!-- /EX -->

### 8. StringBuilder

<!-- EX:Ex08_StringBuilder -->
`examples/ch01/Ex08_StringBuilder.java`

```java
// objective: 1.3
// StringBuilder có thể thay đổi (mutable); các method trả về chính nó (method chaining).
public class Ex08_StringBuilder {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("abc");
        sb.append(1).append('x').append(true);
        System.out.println(sb + " len=" + sb.length());
        sb.insert(0, "->").delete(2, 4).deleteCharAt(sb.length() - 1);
        System.out.println(sb);
        sb.reverse();
        System.out.println(sb);
        sb.setLength(3);
        System.out.println(sb + " " + sb.indexOf("u") + " " + sb.charAt(0));
        sb.replace(0, 1, "ZZZ").setCharAt(1, 'y');
        System.out.println(sb);

        StringBuilder a = new StringBuilder("hi");
        StringBuilder b = new StringBuilder("hi");
        System.out.println(a.equals(b) + " " + a.toString().equals(b.toString()) + " " + (a.compareTo(b) == 0));

        StringBuilder same = a.append("!");     // cùng một object
        System.out.println((same == a) + " " + a);

        String sub = a.substring(1);            // substring trả về String, không đổi a
        System.out.println(sub + " " + a);
    }
}
```

Output thật (JDK 21.0.10):

```text
abc1xtrue len=9
->c1xtru
urtx1c>-
urt 0 u
ZyZrt
false true true
true hi!
i! hi!
```
<!-- /EX -->

### 9. Text block

<!-- EX:Ex09_TextBlocks -->
`examples/ch01/Ex09_TextBlocks.java`

```java
// objective: 1.3
// Text block: thụt lề (incidental whitespace), \s, \ nối dòng, dấu " bên trong.
public class Ex09_TextBlocks {
    public static void main(String[] args) {
        String json = """
            {
              "name": "Nobin",
              "lang": "Java"
            }
            """;
        System.out.print(json);
        System.out.println("ends with newline? " + json.endsWith("\n"));

        String noNewline = """
            one line \
            continued""";
        System.out.println("[" + noNewline + "]");

        String keepSpace = """
            a  \s
            b""";
        System.out.println(keepSpace.replace(' ', '.'));

        String closingLeft = """
                indented
            """;                      // dấu """ đóng lệch trái → giữ 4 dấu cách
        System.out.print(closingLeft.replace(' ', '.'));

        String quotes = """
            She said "hi" and \""" is fine""";
        System.out.println(quotes);
        System.out.println(json.lines().count() + " lines");
    }
}
```

Output thật (JDK 21.0.10):

```text
{
  "name": "Nobin",
  "lang": "Java"
}
ends with newline? true
[one line continued]
a...
b
....indented
She said "hi" and """ is fine
4 lines
```
<!-- /EX -->

### 10. LocalDate, LocalTime, LocalDateTime

<!-- EX:Ex10_LocalDate -->
`examples/ch01/Ex10_LocalDate.java`

```java
// objective: 1.4
// LocalDate/LocalTime/LocalDateTime là bất biến; phép cộng trả về object mới.
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

public class Ex10_LocalDate {
    public static void main(String[] args) {
        LocalDate d = LocalDate.of(2024, Month.JANUARY, 31);
        d.plusDays(1);                              // kết quả bị bỏ → d không đổi
        System.out.println(d + " " + d.plusMonths(1) + " " + d.plusMonths(1).plusMonths(1));
        System.out.println(d.getDayOfWeek() + " " + d.isLeapYear() + " " + d.lengthOfMonth());

        LocalTime t = LocalTime.of(23, 30);
        System.out.println(t.plusHours(2) + " " + t.minusMinutes(90) + " " + LocalTime.MIDNIGHT);

        LocalDateTime dt = LocalDateTime.of(d, t);
        System.out.println(dt + " " + dt.plusMinutes(45));
        System.out.println(ChronoUnit.DAYS.between(LocalDate.of(2024, 1, 1), d));
        System.out.println(d.withDayOfMonth(1) + " " + d.with(DayOfWeek.MONDAY));

        LocalDate parsed = LocalDate.parse("2024-02-29");
        System.out.println(parsed.plusYears(1) + " " + parsed.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
        try {
            LocalDate.of(2023, 2, 29);
        } catch (DateTimeException e) {
            System.out.println("DateTimeException: " + e.getMessage());
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
2024-01-31 2024-02-29 2024-03-29
WEDNESDAY true 31
01:30 22:00 00:00
2024-01-31T23:30 2024-02-01T00:15
30
2024-01-01 2024-01-29
2025-02-28 29/02/2024
DateTimeException: Invalid date 'February 29' as '2023' is not a leap year
```
<!-- /EX -->

### 11. Period, Duration, Instant

<!-- EX:Ex11_PeriodDuration -->
`examples/ch01/Ex11_PeriodDuration.java`

```java
// objective: 1.4
// Period (năm/tháng/ngày) vs Duration (giây/nano) vs Instant (điểm trên trục thời gian UTC).
import java.time.*;

public class Ex11_PeriodDuration {
    public static void main(String[] args) {
        Period p = Period.of(1, 14, 40);
        System.out.println(p + " normalized=" + p.normalized());
        System.out.println(Period.ofWeeks(2) + " " + Period.ofYears(1).ofMonths(3)); // bẫy: static method!
        System.out.println(Period.between(LocalDate.of(2024, 1, 31), LocalDate.of(2024, 3, 1)));

        Duration du = Duration.ofMinutes(135);
        System.out.println(du + " " + du.toHours() + "h " + du.toMinutesPart() + "m");
        System.out.println(Duration.ofDays(1) + " " + Duration.ofSeconds(90).plusMillis(500));
        System.out.println(Duration.between(LocalTime.of(10, 0), LocalTime.of(8, 30)));

        Instant i = Instant.parse("2024-03-10T06:59:00Z");
        System.out.println(i.plus(Duration.ofMinutes(2)) + " " + i.getEpochSecond());
        try {
            LocalDate.of(2024, 1, 1).plus(Duration.ofDays(1));   // LocalDate không hỗ trợ Duration
        } catch (Exception e) {
            System.out.println(e.getClass().getSimpleName() + ": " + e.getMessage());
        }
        System.out.println(LocalDate.of(2024, 1, 1).plus(Period.ofDays(1)));
    }
}
```

Output thật (JDK 21.0.10):

```text
P1Y14M40D normalized=P2Y2M40D
P14D P3M
P1M1D
PT2H15M 2h 15m
PT24H PT1M30.5S
PT-1H-30M
2024-03-10T07:01:00Z 1710053940
UnsupportedTemporalTypeException: Unsupported unit: Seconds
2024-01-02
```
<!-- /EX -->

### 12. Múi giờ và giờ mùa hè (DST)

<!-- EX:Ex12_ZonesDst -->
`examples/ch01/Ex12_ZonesDst.java`

```java
// objective: 1.4
// ZonedDateTime và giờ mùa hè (daylight saving time, DST) ở America/New_York.
import java.time.*;

public class Ex12_ZonesDst {
    public static void main(String[] args) {
        ZoneId ny = ZoneId.of("America/New_York");
        // 2024-03-10: đồng hồ nhảy từ 02:00 lên 03:00 (gap) → 02:30 không tồn tại
        ZonedDateTime gap = ZonedDateTime.of(LocalDateTime.of(2024, 3, 10, 2, 30), ny);
        System.out.println("gap     : " + gap);
        ZonedDateTime before = ZonedDateTime.of(LocalDateTime.of(2024, 3, 10, 1, 30), ny);
        System.out.println("+1h     : " + before.plusHours(1));
        System.out.println("+1 day  : " + before.plusDays(1));          // giữ giờ địa phương
        System.out.println("+24h    : " + before.plusHours(24));        // cộng đúng 24 giờ thật

        // 2024-11-03: đồng hồ lùi từ 02:00 về 01:00 (overlap) → 01:30 xảy ra 2 lần
        ZonedDateTime overlap = ZonedDateTime.of(LocalDateTime.of(2024, 11, 3, 1, 30), ny);
        System.out.println("overlap : " + overlap + " / later: " + overlap.withLaterOffsetAtOverlap());
        System.out.println("hours in 2024-11-03: " + Duration.between(
                ZonedDateTime.of(LocalDate.of(2024, 11, 3), LocalTime.MIDNIGHT, ny),
                ZonedDateTime.of(LocalDate.of(2024, 11, 4), LocalTime.MIDNIGHT, ny)).toHours());

        ZonedDateTime hanoi = before.withZoneSameInstant(ZoneId.of("Asia/Ho_Chi_Minh"));
        System.out.println("same instant in VN: " + hanoi);
        System.out.println("same local in VN  : " + before.withZoneSameLocal(ZoneId.of("Asia/Ho_Chi_Minh")));
        System.out.println(OffsetDateTime.of(2024, 1, 1, 12, 0, 0, 0, ZoneOffset.ofHours(7)).toInstant());
    }
}
```

Output thật (JDK 21.0.10):

```text
gap     : 2024-03-10T03:30-04:00[America/New_York]
+1h     : 2024-03-10T03:30-04:00[America/New_York]
+1 day  : 2024-03-11T01:30-04:00[America/New_York]
+24h    : 2024-03-11T02:30-04:00[America/New_York]
overlap : 2024-11-03T01:30-04:00[America/New_York] / later: 2024-11-03T01:30-05:00[America/New_York]
hours in 2024-11-03: 25
same instant in VN: 2024-03-10T13:30+07:00[Asia/Ho_Chi_Minh]
same local in VN  : 2024-03-10T01:30+07:00[Asia/Ho_Chi_Minh]
2024-01-01T05:00:00Z
```
<!-- /EX -->

### 13. Lỗi biên dịch khi thu hẹp kiểu

<!-- EX:Ex13_NarrowingError -->
`examples/ch01/Ex13_NarrowingError.java`

```java
// objective: 1.1, 1.2
// expect: compile-error
// Gán long cho int và dùng kết quả byte + byte mà không ép kiểu: javac báo lỗi.
public class Ex13_NarrowingError {
    public static void main(String[] args) {
        long big = 10L;
        int small = big;
        byte a = 1, b = 2;
        byte c = a + b;
        float f = 3.14;
    }
}
```

Output thật của `javac` (JDK 21.0.10) — cố ý không biên dịch được:

```text
Ex13_NarrowingError.java:7: error: incompatible types: possible lossy conversion from long to int
        int small = big;
                    ^
Ex13_NarrowingError.java:9: error: incompatible types: possible lossy conversion from int to byte
        byte c = a + b;
                   ^
Ex13_NarrowingError.java:10: error: incompatible types: possible lossy conversion from double to float
        float f = 3.14;
                  ^
3 errors
```
<!-- /EX -->

## Đi sâu

### Bảng primitive

| Kiểu | Kích thước | Khoảng giá trị / ghi chú | Literal |
|---|---|---|---|
| `byte` | 8 bit | -128 .. 127 | `(byte) 1` hoặc hằng số vừa khoảng |
| `short` | 16 bit | -32768 .. 32767 | |
| `int` | 32 bit | ~ ±2,1 tỷ | `10`, `0xFF`, `017` (bát phân), `0b1010`, `1_000` |
| `long` | 64 bit | | `10L` |
| `float` | 32 bit | số thực, ~7 chữ số | `1.5f` (bắt buộc `f`) |
| `double` | 64 bit | số thực, ~15 chữ số | `1.5`, `1e3`, `1.5d` |
| `char` | 16 bit | 0 .. 65535, không dấu | `'A'`, `'A'`, `65` (nếu là hằng số) |
| `boolean` | — | `true` / `false` (không phải 0/1) | |

Quy tắc dấu gạch dưới `_` trong literal: chỉ được đặt **giữa hai chữ số**. `1_000` hợp lệ;
`_1000`, `1000_`, `1_.5`, `0x_FF` đều lỗi.

### Quy tắc nâng kiểu (numeric promotion) — JLS §5.6

1. Nếu một toán hạng là `double` → cả hai thành `double`.
2. Nếu không, nếu một là `float` → `float`.
3. Nếu không, nếu một là `long` → `long`.
4. Nếu không → **`int`** (kể cả `byte + byte`, `char + char`, `short + byte`).

Hệ quả: `short s = 1; s = s + 1;` lỗi biên dịch, nhưng `s += 1;` và `s++` thì được, vì toán tử gán
kết hợp (compound assignment) tự ép kiểu về kiểu của biến trái.

**Ngoại lệ "hằng số compile-time":** `final int k = 10; byte b = k;` biên dịch được, vì `k` là hằng số
và giá trị 10 vừa với `byte`. Nếu bỏ `final` thì lỗi. Điều này chỉ đúng cho `byte`, `short`, `char`, `int`
— **không** áp dụng cho `long` → `int` hay `double` → `float` (`float f = 3.14;` luôn lỗi).

### Wrapper class

- `Integer.valueOf(...)` và autoboxing dùng **cache** cho giá trị -128..127 (Javadoc của `Integer.valueOf`
  trong mã nguồn JDK 21 ghi rõ điều này). Vì vậy `==` giữa hai `Integer` 127 cho `true`, 128 cho `false`.
  **Luôn dùng `equals`** để so sánh wrapper.
- `parseXxx` trả về primitive, `valueOf` trả về wrapper.
- `equals` của wrapper kiểm tra **cả kiểu**: `Long.valueOf(42).equals(42)` là `false` vì `42` được boxing
  thành `Integer`.
- Unboxing `null` → `NullPointerException`.
- Wrapper không "nới rộng rồi boxing": `Long x = 5;` **lỗi** (5 là int, chỉ boxing được thành Integer).
  `long y = 5;` thì OK.

### Toán tử: thứ tự ưu tiên (từ cao xuống thấp, rút gọn)

| Nhóm | Toán tử |
|---|---|
| Hậu tố | `x++` `x--` |
| Tiền tố, một ngôi | `++x` `--x` `+` `-` `!` `~` `(cast)` |
| Nhân chia | `*` `/` `%` |
| Cộng trừ | `+` `-` |
| Dịch bit | `<<` `>>` `>>>` |
| So sánh | `<` `>` `<=` `>=` `instanceof` |
| Bằng | `==` `!=` |
| Bit / logic | `&` rồi `^` rồi `\|` |
| Short-circuit | `&&` rồi `\|\|` |
| Ba ngôi | `? :` |
| Gán | `=` `+=` `-=` … (kết hợp từ phải sang trái) |

Biểu thức luôn được **đánh giá từ trái sang phải** (toán hạng trái tính trước), sau đó mới áp dụng
thứ tự ưu tiên để ghép. Vì vậy `i++ + ++i` với `i = 5` là `5 + 7`.

`+` với `String`: tính từ trái sang phải; khi gặp `String` thì từ đó trở đi là nối chuỗi.
`1 + 2 + "3" + 4 + 5` → `"3" + ...` → `"3345"`.

### Math API cần nhớ

| Method | Kết quả đáng nhớ |
|---|---|
| `Math.round(double)` | trả về `long`; làm tròn nửa lên (`floor(x + 0.5)`): `round(-2.5) = -2` |
| `Math.round(float)` | trả về `int` |
| `Math.floor/ceil/rint` | trả về `double`; `rint(2.5) = 2.0` (làm tròn về số chẵn) |
| `Math.max/min` | theo kiểu đã nâng: `max(3, 7L)` là `long` |
| `Math.abs(Integer.MIN_VALUE)` | vẫn âm (tràn số) |
| `Math.pow`, `Math.sqrt` | luôn `double`; `sqrt(-1) = NaN` |
| `Math.addExact`, `multiplyExact` | ném `ArithmeticException` khi tràn |
| Chia số nguyên cho 0 | `ArithmeticException`; chia số thực cho 0 → `Infinity` / `NaN` |

### String: những method hay ra đề

- `substring(begin, end)`: lấy từ `begin` tới **trước** `end`. `end < begin` → `StringIndexOutOfBoundsException`.
- `indexOf` trả về -1 nếu không thấy; `charAt` ngoài khoảng → exception.
- `strip()` hiểu khoảng trắng Unicode; `trim()` chỉ bỏ ký tự ≤ `' '`. `isBlank()` vs `isEmpty()`.
- `split(",")` bỏ các chuỗi rỗng **ở cuối**, nhưng giữ chuỗi rỗng ở giữa: `"a,b,,c"` → 4 phần tử.
- String pool: literal và biểu thức hằng số (`"ja" + "va"`) dùng chung object; chuỗi tạo lúc chạy thì không.
  `intern()` trả về bản trong pool.

### StringBuilder

- Không override `equals` → so sánh bằng `==` (tham chiếu). So nội dung: `toString().equals(...)`
  hoặc `compareTo` (có từ Java 11).
- `delete(start, end)`, `insert(offset, x)`, `replace(start, end, str)`, `reverse()`, `setLength(n)`.
- `substring` trả về `String`, **không** thay đổi builder.

### Text block (Java 15+)

- Mở bằng `"""` rồi **xuống dòng ngay** (không được viết nội dung trên cùng dòng mở).
- Khoảng trắng thụt lề chung (incidental whitespace) bị bỏ; vị trí dấu `"""` đóng cũng tính vào.
- Khoảng trắng cuối dòng bị xoá; dùng `\s` để giữ một dấu cách. `\` ở cuối dòng = nối dòng (không xuống dòng).
- Nếu `"""` đóng nằm trên dòng riêng → chuỗi kết thúc bằng `\n`.

### Ngày giờ

- Tất cả đều bất biến; quên gán kết quả (`d.plusDays(1);`) là bẫy kinh điển.
- `plusMonths` giữ ngày nếu được, nếu không thì lấy **ngày cuối tháng**: 31/1 + 1 tháng = 29/2/2024.
- `Period.of(1, 14, 40)` **không** tự chuẩn hoá; `normalized()` chỉ gộp tháng thành năm, không đụng ngày.
- `Period.ofYears(1).ofMonths(3)` = `P3M`: các `ofXxx` là **static**, gọi nối chuỗi sẽ bỏ kết quả trước.
- `Duration` dùng được với `LocalTime`, `LocalDateTime`, `Instant`, `ZonedDateTime`; **không** dùng với `LocalDate`
  (`UnsupportedTemporalTypeException`). `Period` không dùng được với `LocalTime`.
- DST: khi giờ địa phương **không tồn tại** (gap), `ZonedDateTime` dời tới sau khoảng trống (02:30 → 03:30).
  Khi giờ địa phương **xảy ra hai lần** (overlap), mặc định chọn offset **sớm hơn**.
  `plusDays(1)` giữ giờ địa phương; `plusHours(24)` cộng đúng 24 giờ thật.

## Lỗi và bẫy thường gặp (Exam traps)

1. `int x = 10L;`, `float f = 1.0;`, `long l = 3_000_000_000;` (literal int quá lớn) → **không biên dịch**.
2. `byte b = a + c;` với `a`, `c` là `byte` → lỗi (kết quả là `int`). Nhưng `b += c;` thì được.
3. `Integer` so sánh bằng `==`: đúng với -128..127, sai ngoài khoảng đó.
4. `Long l = 5;` lỗi; `long l = 5;` OK; `Long l = 5L;` OK.
5. Quên gán lại kết quả của `String`/`LocalDate` (bất biến) — nhưng `StringBuilder` thì không cần gán.
6. `StringBuilder.equals` so sánh tham chiếu.
7. `Math.round(-2.5)` là `-2`, không phải `-3`. `Math.round` trả về `long` với tham số `double`.
8. `i = i++;` → `i` **không đổi**.
9. `&&` / `||` có thể **bỏ qua** vế phải (short-circuit) → biến trong vế phải không được tăng.
10. `Period.ofYears(1).ofMonths(3)` chỉ còn 3 tháng.
11. `substring(3, 1)` ném exception, không trả chuỗi rỗng.
12. Chuỗi rỗng ở cuối kết quả `split` bị bỏ.

## Góc nhìn từ TypeScript

| TypeScript | Java | Ghi chú |
|---|---|---|
| `number` (một kiểu cho tất cả) | `byte`…`double` (6 kiểu số) | Java có chia số nguyên thật: `7 / 2 == 3` |
| `bigint` | `long` / `BigInteger` | `long` tràn số âm thầm, không báo lỗi |
| `===` so sánh giá trị với primitive | `==` với primitive; `equals` với object | `Integer == Integer` so sánh tham chiếu! |
| `string` (bất biến) | `String` (bất biến) | Giống nhau. Nhưng Java có thêm `StringBuilder` mutable |
| Template literal `` `Hi ${name}` `` | `"Hi %s".formatted(name)` hoặc nối `+` | String templates của Java 21 là preview, **không** thi |
| Chuỗi nhiều dòng bằng backtick | Text block `"""` | Text block bỏ thụt lề chung, backtick thì không |
| `Date` (mutable, lộn xộn) | `java.time` (bất biến, rõ ràng) | Tương tự thư viện `Temporal` mới của JS |
| `undefined` / `null` | chỉ có `null` (cho object) | Primitive không bao giờ `null` |

## Tóm tắt

- `byte/short/char` + bất cứ gì → ít nhất `int`. Thu hẹp kiểu phải cast, trừ hằng số compile-time và `+=`.
- Wrapper: dùng `equals`; cache -128..127; unboxing `null` → NPE.
- Đánh giá trái sang phải, rồi mới ưu tiên. `&&`, `||` short-circuit.
- `String` bất biến, `StringBuilder` mutable và không override `equals`.
- Text block: bỏ thụt lề chung, `\s` giữ khoảng trắng, `\` nối dòng.
- `java.time` bất biến; `Period` cho ngày, `Duration` cho giờ; DST gap dời giờ tới trước, overlap chọn offset sớm.

## Bài tập (có lời giải)

20 câu hỏi tự viết theo phong cách đề thi. Mọi đáp án đã được script `tools/book.py` biên dịch và chạy
để xác nhận (code trong `examples/questions/ch01/`). Làm hết rồi mới xem lời giải.

### Câu hỏi

<!-- QUESTIONS:ch01 -->
#### Câu 01-01 · Dễ · objective 1.1

Chương trình sau in ra gì?

```java
public class Cache {
    public static void main(String[] args) {
        Integer a = 100, b = 100;
        Integer c = 1000, d = 1000;
        System.out.println((a == b) + " " + (c == d) + " " + c.equals(d));
    }
}
```

- **A.** `true true true`
- **B.** `true false true`
- **C.** `false false true`
- **D.** `true false false`

#### Câu 01-02 · Vừa · objective 1.2

Dòng nào gây lỗi biên dịch?

```java
public class Promo {
    public static void main(String[] args) {
        short s = 10;
        s += 5;          // L1
        s = s * 2;       // L2
        char c = 'a';
        c++;             // L3
        final byte k = 3;
        byte b = k + 1;  // L4
    }
}
```

- **A.** Chỉ L1
- **B.** Chỉ L4
- **C.** Chỉ L2
- **D.** L2 và L4
- **E.** Không có lỗi, chương trình biên dịch được

#### Câu 01-03 · Vừa · objective 1.2

Chương trình sau in ra gì?

```java
public class Incr {
    public static void main(String[] args) {
        int i = 3;
        int j = i++ * 2 + --i;
        System.out.println(i + " " + j);
    }
}
```

- **A.** `4 9`
- **B.** `3 8`
- **C.** `3 9`
- **D.** `4 10`

#### Câu 01-04 · Dễ · objective 1.3

Chương trình sau in ra gì?

```java
public class Immutable {
    public static void main(String[] args) {
        String s = "java";
        s.concat(" rocks");
        s.toUpperCase();
        StringBuilder sb = new StringBuilder("java");
        sb.append(" rocks");
        System.out.println(s + " | " + sb);
    }
}
```

- **A.** `JAVA ROCKS | java rocks`
- **B.** `java rocks | java rocks`
- **C.** `java | java`
- **D.** `java | java rocks`

#### Câu 01-05 · Vừa · objective 1.3

Chương trình sau in ra gì?

```java
public class Builder {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("0123456789");
        sb.delete(2, 5).insert(3, "-").reverse();
        System.out.println(sb);
    }
}
```

- **A.** `9876-510`
- **B.** `98765-10`
- **C.** `015-6789`
- **D.** `9876-5210`

#### Câu 01-06 · Khó · objective 1.3

Chương trình sau in ra gì?

```java
public class Block {
    public static void main(String[] args) {
        String tb = """
            A\s
              B \
            C
            """;
        System.out.print(tb.replace(' ', '.').replace("\n", "|"));
    }
}
```

- **A.** `A|..B.C|`
- **B.** `A.|..B.C|`
- **C.** `A.|..B.|C|`
- **D.** `A.|B.C|`

#### Câu 01-07 · Vừa · objective 1.4

Chương trình sau in ra gì?

```java
import java.time.LocalDate;

public class Months {
    public static void main(String[] args) {
        LocalDate d = LocalDate.of(2023, 1, 31);
        d.plusDays(1);
        LocalDate e = d.plusMonths(1);
        System.out.println(d + " " + e);
    }
}
```

- **A.** `2023-02-01 2023-03-01`
- **B.** `2023-01-31 2023-03-03`
- **C.** `Ném DateTimeException lúc chạy`
- **D.** `2023-01-31 2023-02-28`

#### Câu 01-08 · Khó · objective 1.4

Ở múi giờ America/New_York, ngày 2024-03-10 đồng hồ nhảy từ 02:00 lên 03:00. Chương trình sau in ra gì?

```java
import java.time.*;

public class Dst {
    public static void main(String[] args) {
        ZoneId z = ZoneId.of("America/New_York");
        ZonedDateTime t = ZonedDateTime.of(2024, 3, 10, 1, 45, 0, 0, z);
        ZonedDateTime a = t.plusMinutes(30);
        ZonedDateTime b = t.plusDays(1).minusHours(24);
        System.out.println(a.toLocalTime() + " " + b.toLocalTime());
    }
}
```

- **A.** `03:15 00:45`
- **B.** `03:15 01:45`
- **C.** `02:15 01:45`
- **D.** `02:15 00:45`

#### Câu 01-09 · Vừa · objective 1.4

Chương trình sau in ra gì?

```java
import java.time.*;

public class Amounts {
    public static void main(String[] args) {
        Period p = Period.ofMonths(1).ofDays(10);
        Duration d = Duration.ofHours(25);
        System.out.println(p + " " + d);
    }
}
```

- **A.** `P1M10D PT25H`
- **B.** `P10D PT25H`
- **C.** `P1M10D P1DT1H`
- **D.** `P10D P1DT1H`

#### Câu 01-10 · Vừa · objective 1.1

Chèn dòng nào vào chỗ `// INSERT CODE HERE` thì chương trình biên dịch được? **(Chọn 2 đáp án.)**

```java
public class Decl {
    public static void main(String[] args) {
        // INSERT CODE HERE
    }
}
```

- **A.** `Long a = 5;`
- **B.** `float b = 2.5;`
- **C.** `char c = 65;`
- **D.** `int d = 1_000_;`
- **E.** `double e = 0x1F;`
- **F.** `byte f = 128;`

#### Câu 01-11 · Khó · objective 1.2

Chương trình sau in ra gì?

```java
public class Rounding {
    public static void main(String[] args) {
        System.out.println(Math.round(-3.5) + " " + Math.round(3.49f) + " "
                + Math.floor(-3.5) + " " + Math.ceil(-3.5));
    }
}
```

- **A.** `-4 3 -4.0 -3.0`
- **B.** `-3 3 -4.0 -3.0`
- **C.** `-3 3.0 -4.0 -3.0`
- **D.** `-4 3 -3.0 -4.0`

#### Câu 01-12 · Vừa · objective 1.2

Chương trình sau in ra gì?

```java
public class ShortCircuit {
    public static void main(String[] args) {
        int a = 0, b = 0;
        boolean r = (a++ > 0) && (b++ > 0);
        boolean s = (a++ > 0) | (b++ > 0);
        System.out.println(a + " " + b + " " + r + " " + s);
    }
}
```

- **A.** `2 2 false true`
- **B.** `1 1 false true`
- **C.** `2 1 false false`
- **D.** `2 1 false true`

#### Câu 01-13 · Khó · objective 1.1

Hai phát biểu nào đúng với Java 21? **(Chọn 2 đáp án.)**

- **A.** `Integer.valueOf(127) == Integer.valueOf(127)` luôn là `true`.
- **B.** `new Integer(5)` không còn biên dịch được trong Java 21.
- **C.** `Long.valueOf(10).equals(10)` trả về `true`.
- **D.** Unboxing một biến `Integer` có giá trị `null` ném `NullPointerException`.
- **E.** `Character.isLetter('9')` trả về `true`.

#### Câu 01-14 · Dễ · objective 1.3

Chương trình sau in ra gì?

```java
public class Sub {
    public static void main(String[] args) {
        String s = "Programming";
        System.out.println(s.substring(3, 6) + s.indexOf('m') + s.charAt(s.length() - 1));
    }
}
```

- **A.** `gra6g`
- **B.** `gram6g`
- **C.** `gra7g`
- **D.** `ogr6g`

#### Câu 01-15 · Khó · objective 1.3

Chèn dòng nào vào chỗ `// INSERT CODE HERE` thì chương trình in ra `true`? **(Chọn 2 đáp án.)**

```java
public class Pool {
    public static void main(String[] args) {
        String a = "hello";
        String b = "hel";
        // INSERT CODE HERE
    }
}
```

- **A.** `System.out.println(a == "hel" + "lo");`
- **B.** `System.out.println(a == b + "lo");`
- **C.** `System.out.println(a == (b + "lo").intern());`
- **D.** `System.out.println(a == new String("hello"));`
- **E.** `System.out.println(new StringBuilder(a).equals(new StringBuilder(a)));`

#### Câu 01-16 · Vừa · objective 1.4

Kết quả của chương trình là gì?

```java
import java.time.*;

public class AddDuration {
    public static void main(String[] args) {
        LocalDate d = LocalDate.of(2024, 5, 20);
        LocalDate e = d.plus(Duration.ofDays(2));
        System.out.println(e);
    }
}
```

- **A.** In ra `2024-05-22`
- **B.** Không biên dịch được
- **C.** Ném `UnsupportedTemporalTypeException` lúc chạy
- **D.** In ra `2024-05-20`

#### Câu 01-17 · Khó · objective 1.2

Chương trình sau in ra gì?

```java
public class Chars {
    public static void main(String[] args) {
        char c = 'A';
        c += 2;
        int i = c + 1;
        c++;
        System.out.println(c + " " + i + " " + (char) i + (c + 1));
    }
}
```

- **A.** `D 68 D69`
- **B.** `D 68 DE`
- **C.** `E 68 D69`
- **D.** `D 68 68E`

#### Câu 01-18 · Vừa · objective 1.4

Hai phát biểu nào đúng? **(Chọn 2 đáp án.)**

- **A.** `LocalTime.of(10, 0).plus(Period.ofDays(1))` ném exception lúc chạy.
- **B.** `Instant` có method `getYear()`.
- **C.** `Duration.between(t1, t2)` có thể trả về giá trị âm.
- **D.** `Period.between(...)` nhận hai tham số `LocalDateTime`.
- **E.** `LocalDate.of(2024, 13, 1)` trả về 2025-01-01.

#### Câu 01-19 · Dễ · objective 1.1

Chương trình sau in ra gì?

```java
public class Defaults {
    static boolean flag;
    static double value;
    static String name;

    public static void main(String[] args) {
        System.out.println(flag + " " + value + " " + name);
    }
}
```

- **A.** `false 0 null`
- **B.** `null null null`
- **C.** `Không biên dịch được vì field chưa được khởi tạo`
- **D.** `false 0.0 null`

#### Câu 01-20 · Khó · objective 1.1

Những dòng nào gây lỗi biên dịch?

```java
public class Lits {
    public static void main(String[] args) {
        long a = 2_147_483_648L;   // L1
        int b = 2_147_483_648;     // L2
        float c = 1e3f;            // L3
        double d = 1_0.0_1;        // L4
        int e = 0b1_0;             // L5
        int f = 0x_1F;             // L6
    }
}
```

- **A.** Chỉ L2
- **B.** L2 và L4
- **C.** L2 và L6
- **D.** L4 và L6
- **E.** L2, L4 và L6
<!-- /QUESTIONS -->

### Lời giải

<!-- ANSWERS:ch01 -->
#### Câu 01-01 — Đáp án: **B** (Dễ · objective 1.1)

- **Vì sao đúng:** Autoboxing gọi `Integer.valueOf`, method này luôn cache các giá trị từ -128 đến 127. Hai biến `a`, `b` trỏ cùng một object nên `a == b` là `true`. 1000 nằm ngoài cache nên `c` và `d` là hai object khác nhau: `==` là `false`, còn `equals` so sánh giá trị nên `true`.
- **A sai:** `c == d` so sánh tham chiếu; 1000 nằm ngoài cache nên là hai object khác nhau.
- **C sai:** 100 nằm trong khoảng cache -128..127, nên `a == b` là `true`.
- **D sai:** `Integer.equals` so sánh giá trị số, 1000 bằng 1000 nên `true`.
- *Kiểm chứng:* `examples/questions/ch01/Q01_01/` — output confirmed (`python3 tools/book.py questions ch01`).

#### Câu 01-02 — Đáp án: **C** (Vừa · objective 1.2)

- **Vì sao đúng:** `s * 2` được nâng kiểu (numeric promotion) thành `int`; gán `int` cho `short` mà không cast là lỗi. Các dòng khác hợp lệ: `+=` và `++` tự ép kiểu về kiểu của biến; `k + 1` là hằng số compile-time (vì `k` là `final` và được gán hằng số) với giá trị 4 vừa với `byte`.
- **A sai:** Toán tử gán kết hợp `+=` có ép kiểu ngầm: `s += 5` tương đương `s = (short)(s + 5)`.
- **B sai:** `k` là `final byte` gán bằng hằng số, nên `k + 1` là hằng số compile-time 4, vừa `byte` → hợp lệ.
- **D sai:** L4 hợp lệ (xem giải thích B).
- **E sai:** L2 gán kết quả `int` cho `short` nên không biên dịch.
- *Kiểm chứng:* `examples/questions/ch01/Q01_02/` — compile error confirmed at ['L2'] (`python3 tools/book.py questions ch01`).

#### Câu 01-03 — Đáp án: **C** (Vừa · objective 1.2)

- **Vì sao đúng:** Biểu thức được đánh giá từ trái sang phải. `i++` cho giá trị 3 rồi `i` thành 4. `3 * 2 = 6`. Sau đó `--i` giảm `i` về 3 và cho giá trị 3. `j = 6 + 3 = 9`, `i = 3`.
- **A sai:** `--i` chạy sau `i++`, nên `i` cuối cùng là 3, không phải 4.
- **B sai:** `--i` cho giá trị 3 (không phải 2), vì `i` đã là 4 sau `i++`.
- **D sai:** `i` cuối cùng là 3 và `j` là 6 + 3 = 9.
- *Kiểm chứng:* `examples/questions/ch01/Q01_03/` — output confirmed (`python3 tools/book.py questions ch01`).

#### Câu 01-04 — Đáp án: **D** (Dễ · objective 1.3)

- **Vì sao đúng:** `String` bất biến: `concat` và `toUpperCase` trả về chuỗi mới nhưng kết quả không được gán lại, nên `s` vẫn là `"java"`. `StringBuilder` thay đổi được: `append` sửa trực tiếp `sb`.
- **A sai:** Kết quả của `concat`/`toUpperCase` bị bỏ đi; `s` không đổi.
- **B sai:** Như trên — `s.concat(...)` không sửa `s`.
- **C sai:** `sb.append` sửa chính object `sb`, không cần gán lại.
- *Kiểm chứng:* `examples/questions/ch01/Q01_04/` — output confirmed (`python3 tools/book.py questions ch01`).

#### Câu 01-05 — Đáp án: **A** (Vừa · objective 1.3)

- **Vì sao đúng:** `delete(2, 5)` xoá chỉ số 2, 3, 4 → `"0156789"`. `insert(3, "-")` chèn trước chỉ số 3 → `"015-6789"`. `reverse()` đảo ngược → `"9876-510"`. Các method trả về cùng object nên nối chuỗi (chaining) được.
- **B sai:** Dấu `-` được chèn ở chỉ số 3 của `"0156789"`, tức là giữa `5` và `6`, nên sau khi đảo là `9876-510`.
- **C sai:** Đây là chuỗi trước khi `reverse()`; `reverse()` sửa chính builder.
- **D sai:** `delete(2, 5)` xoá cả ký tự `2` (chỉ số 2), nên không còn `2` trong kết quả.
- *Kiểm chứng:* `examples/questions/ch01/Q01_05/` — output confirmed (`python3 tools/book.py questions ch01`).

#### Câu 01-06 — Đáp án: **B** (Khó · objective 1.3)

- **Vì sao đúng:** Thụt lề chung (4 dấu cách, tính cả dòng `"""` đóng) bị bỏ. `\s` được xử lý sau khi xoá khoảng trắng cuối dòng nên giữ lại một dấu cách sau `A`. Dòng `B` giữ 2 dấu cách thụt lề thêm; dấu cách trước `\` không phải khoảng trắng cuối dòng nên được giữ, và `\` nối dòng với `C`. Dòng `"""` đóng riêng → có `\n` cuối. Kết quả `"A \n  B C\n"`.
- **A sai:** `\s` giữ lại một dấu cách sau `A`, nên phải có `.` sau `A`.
- **C sai:** `\` ở cuối dòng là nối dòng (line continuation): không có xuống dòng giữa `B` và `C`.
- **D sai:** Chỉ bỏ phần thụt lề chung (4 dấu cách); dòng `B` thụt thêm 2 dấu cách nên còn `..B`.
- *Kiểm chứng:* `examples/questions/ch01/Q01_06/` — output confirmed (`python3 tools/book.py questions ch01`).

#### Câu 01-07 — Đáp án: **D** (Vừa · objective 1.4)

- **Vì sao đúng:** `LocalDate` bất biến nên `d.plusDays(1)` không đổi `d`. `plusMonths(1)` từ 31/1/2023: tháng 2/2023 chỉ có 28 ngày, nên kết quả được điều chỉnh về ngày hợp lệ cuối cùng: 28/2/2023.
- **A sai:** Kết quả của `plusDays(1)` không được gán, `d` vẫn là 2023-01-31.
- **B sai:** `plusMonths` không "tràn" sang tháng sau; nó lấy ngày cuối tháng hợp lệ.
- **C sai:** `plusMonths` tự điều chỉnh ngày, không ném exception (khác với `LocalDate.of(2023, 2, 31)`).
- *Kiểm chứng:* `examples/questions/ch01/Q01_07/` — output confirmed (`python3 tools/book.py questions ch01`).

#### Câu 01-08 — Đáp án: **A** (Khó · objective 1.4)

- **Vì sao đúng:** `plusMinutes(30)` cộng thời gian thật: 01:45 EST + 30 phút = thời điểm mà đồng hồ hiển thị 03:15 EDT (02:15 không tồn tại). `plusDays(1)` giữ giờ địa phương: 2024-03-11 01:45 EDT. Trừ 24 giờ thật quay về 2024-03-10 lúc 00:45 EST, vì ngày 10/3 chỉ có 23 giờ.
- **B sai:** `plusDays(1)` rồi `minusHours(24)` không triệt tiêu nhau: ngày 10/3 chỉ dài 23 giờ, nên ra 00:45.
- **C sai:** 02:15 không tồn tại ngày hôm đó (nằm trong khoảng nhảy giờ - gap).
- **D sai:** 02:15 không tồn tại; `ZonedDateTime` luôn cho giờ hợp lệ là 03:15.
- *Kiểm chứng:* `examples/questions/ch01/Q01_08/` — output confirmed (`python3 tools/book.py questions ch01`).

#### Câu 01-09 — Đáp án: **B** (Vừa · objective 1.4)

- **Vì sao đúng:** `ofDays` là method **static**; gọi nó qua kết quả của `ofMonths(1)` vẫn chỉ tạo `Period` 10 ngày, kết quả `ofMonths(1)` bị bỏ. `Duration.toString()` chỉ dùng giờ/phút/giây: 25 giờ in là `PT25H`.
- **A sai:** `Period.ofMonths(1).ofDays(10)` không cộng dồn: `ofDays` là static nên chỉ còn `P10D`.
- **C sai:** Cả hai phần đều sai: `P10D` (xem A) và `Duration` không bao giờ in phần ngày `D` trước `T`.
- **D sai:** `Duration.toString()` không đổi giờ ra ngày; 25 giờ là `PT25H`.
- *Kiểm chứng:* `examples/questions/ch01/Q01_09/` — output confirmed (`python3 tools/book.py questions ch01`).

#### Câu 01-10 — Đáp án: **C, E** (Vừa · objective 1.1)

- **Vì sao đúng:** `char c = 65;`: 65 là hằng số `int` vừa khoảng của `char` nên được gán không cần cast. `double e = 0x1F;`: literal hex kiểu `int` (31) được mở rộng (widening) thành `double`.
- **A sai:** `5` là `int`; Java không nới rộng rồi mới boxing, nên không thể thành `Long`. Cần `5L`.
- **B sai:** `2.5` là `double`; gán cho `float` cần `2.5f` hoặc cast.
- **D sai:** Dấu `_` không được đứng cuối literal.
- **F sai:** 128 vượt quá `byte` (-128..127), cần cast.
- *Kiểm chứng:* `examples/questions/ch01/Q01_10/` — variants: CE satisfy compiles (`python3 tools/book.py questions ch01`).

#### Câu 01-11 — Đáp án: **B** (Khó · objective 1.2)

- **Vì sao đúng:** `Math.round` làm tròn "nửa lên phía dương vô cực": `round(-3.5)` = `floor(-3.5 + 0.5)` = -3, kiểu `long`. `round(3.49f)` = 3 kiểu `int`. `floor` và `ceil` trả về `double`: `floor(-3.5) = -4.0`, `ceil(-3.5) = -3.0`.
- **A sai:** `Math.round(-3.5)` là -3 (làm tròn về phía dương), không phải -4.
- **C sai:** `Math.round(float)` trả về `int`, in ra `3`, không có `.0`.
- **D sai:** `floor` luôn đi xuống (-4.0), `ceil` luôn đi lên (-3.0); và `round(-3.5)` là -3.
- *Kiểm chứng:* `examples/questions/ch01/Q01_11/` — output confirmed (`python3 tools/book.py questions ch01`).

#### Câu 01-12 — Đáp án: **D** (Vừa · objective 1.2)

- **Vì sao đúng:** Dòng 1: `a++ > 0` là `0 > 0` = `false` (a thành 1); `&&` short-circuit nên `b++` **không** chạy; `r = false`. Dòng 2: `|` luôn đánh giá cả hai vế: `1 > 0` = `true` (a thành 2), `0 > 0` = `false` (b thành 1); `s = true`.
- **A sai:** `b++` ở dòng 1 bị bỏ qua do `&&`, nên `b` chỉ tăng một lần.
- **B sai:** `a++` chạy ở cả hai dòng, nên `a = 2`.
- **C sai:** `true | false` là `true`.
- *Kiểm chứng:* `examples/questions/ch01/Q01_12/` — output confirmed (`python3 tools/book.py questions ch01`).

#### Câu 01-13 — Đáp án: **A, D** (Khó · objective 1.1)

- **Vì sao đúng:** Javadoc của `Integer.valueOf` bảo đảm luôn cache -128..127, nên cùng một object. Unboxing `null` gọi `intValue()` trên `null` → `NullPointerException`.
- **B sai:** Constructor `Integer(int)` bị đánh dấu deprecated (for removal) nhưng vẫn biên dịch và chạy trong Java 21 (chỉ có cảnh báo).
- **C sai:** `10` được boxing thành `Integer`; `Long.equals` trả về `false` khi kiểu khác nhau.
- **E sai:** `'9'` là chữ số (digit), không phải chữ cái.
- *Kiểm chứng:* `examples/questions/ch01/Q01_13/` — each option proven true/false by a program (`python3 tools/book.py questions ch01`).

#### Câu 01-14 — Đáp án: **A** (Dễ · objective 1.3)

- **Vì sao đúng:** `substring(3, 6)` lấy chỉ số 3, 4, 5 → `"gra"` (chỉ số bắt đầu từ 0, `end` không lấy). `indexOf('m')` trả về vị trí **đầu tiên** là 6. Ký tự cuối (`length() - 1` = 10) là `'g'`.
- **B sai:** `substring(3, 6)` không lấy chỉ số 6, nên không có `m`.
- **C sai:** `indexOf` trả về lần xuất hiện đầu tiên (6), không phải lần cuối (7).
- **D sai:** Chỉ số bắt đầu từ 0: chỉ số 3 là `g`, không phải `o`.
- *Kiểm chứng:* `examples/questions/ch01/Q01_14/` — output confirmed (`python3 tools/book.py questions ch01`).

#### Câu 01-15 — Đáp án: **A, C** (Khó · objective 1.3)

- **Vì sao đúng:** A: `+` ưu tiên cao hơn `==`, nên so sánh `a == "hello"`; `"hel" + "lo"` là hằng số compile-time nên dùng chung object trong string pool → `true`. C: `intern()` trả về object trong pool, chính là `a` → `true`.
- **B sai:** `b` không phải `final`, nên `b + "lo"` được tạo lúc chạy thành object mới → `false`.
- **D sai:** `new String(...)` luôn tạo object mới → `false`.
- **E sai:** `StringBuilder` không override `equals`, nên so sánh tham chiếu của hai object khác nhau → `false`.
- *Kiểm chứng:* `examples/questions/ch01/Q01_15/` — variants: AC satisfy output (`python3 tools/book.py questions ch01`).

#### Câu 01-16 — Đáp án: **C** (Vừa · objective 1.4)

- **Vì sao đúng:** `plus(TemporalAmount)` nhận cả `Period` lẫn `Duration` nên biên dịch được. Nhưng `Duration` cộng theo đơn vị giây, mà `LocalDate` không có phần giờ → ném `UnsupportedTemporalTypeException: Unsupported unit: Seconds`.
- **A sai:** Muốn cộng 2 ngày cho `LocalDate` phải dùng `plusDays(2)` hoặc `Period.ofDays(2)`.
- **B sai:** `Duration` là một `TemporalAmount`, nên lời gọi `plus` hợp lệ về kiểu.
- **D sai:** Chương trình không in gì vì exception xảy ra trước `println`.
- *Kiểm chứng:* `examples/questions/ch01/Q01_16/` — output confirmed (`python3 tools/book.py questions ch01`).

#### Câu 01-17 — Đáp án: **A** (Khó · objective 1.2)

- **Vì sao đúng:** `c += 2` → `'C'`. `i = 'C' + 1 = 68`. `c++` → `'D'`. Khi in: `c + " "` là nối chuỗi `"D "`, rồi `68`, rồi `(char) 68 = 'D'`, rồi `(c + 1)` trong ngoặc được tính trước theo kiểu `int` = 69.
- **B sai:** `(c + 1)` là phép cộng `char + int` → `int` 69, không phải ký tự `E`.
- **C sai:** `c` chỉ tăng một lần bằng `c++` sau khi đã là `'C'`, nên là `'D'`.
- **D sai:** `(char) i` in ký tự `D`, còn `(c + 1)` in số 69.
- *Kiểm chứng:* `examples/questions/ch01/Q01_17/` — output confirmed (`python3 tools/book.py questions ch01`).

#### Câu 01-18 — Đáp án: **A, C** (Vừa · objective 1.4)

- **Vì sao đúng:** A: `LocalTime` không có đơn vị ngày nên cộng `Period` ngày ném `UnsupportedTemporalTypeException`. C: nếu mốc thứ hai sớm hơn mốc thứ nhất, `Duration.between` trả về giá trị âm (ví dụ `PT-1H`).
- **B sai:** `Instant` chỉ là số giây từ epoch (UTC), không có method `getYear()` → lỗi biên dịch.
- **D sai:** `Period.between` chỉ nhận hai `LocalDate` → truyền `LocalDateTime` là lỗi biên dịch.
- **E sai:** Tháng 13 không hợp lệ → `DateTimeException`; `of` không tự "tràn" sang năm sau.
- *Kiểm chứng:* `examples/questions/ch01/Q01_18/` — each option proven true/false by a program (`python3 tools/book.py questions ch01`).

#### Câu 01-19 — Đáp án: **D** (Dễ · objective 1.1)

- **Vì sao đúng:** Field (static hoặc instance) luôn có giá trị mặc định: `boolean` → `false`, `double` → `0.0`, object → `null`. Chỉ biến **cục bộ** mới phải gán trước khi dùng.
- **A sai:** `double` mặc định là `0.0`, và khi in ra có phần `.0`.
- **B sai:** Primitive không bao giờ là `null`.
- **C sai:** Quy tắc "phải gán trước khi dùng" chỉ áp dụng cho biến cục bộ, không cho field.
- *Kiểm chứng:* `examples/questions/ch01/Q01_19/` — output confirmed (`python3 tools/book.py questions ch01`).

#### Câu 01-20 — Đáp án: **C** (Khó · objective 1.1)

- **Vì sao đúng:** L2: literal `int` lớn nhất là 2 147 483 647; 2 147 483 648 không có hậu tố `L` → "integer number too large". L6: `_` không được đứng ngay sau tiền tố `0x`. Các dòng khác hợp lệ: `_` nằm giữa hai chữ số (L4 có `1_0` và `0_1`), `1e3f` là `float` hợp lệ.
- **A sai:** L6 cũng lỗi: `_` phải nằm giữa hai chữ số, không được sát `0x`.
- **B sai:** L4 hợp lệ: mỗi `_` đều nằm giữa hai chữ số.
- **D sai:** L4 hợp lệ, còn L2 thì lỗi (literal int quá lớn).
- **E sai:** L4 hợp lệ (xem B).
- *Kiểm chứng:* `examples/questions/ch01/Q01_20/` — compile error confirmed at ['L2', 'L6'] (`python3 tools/book.py questions ch01`).
<!-- /ANSWERS -->

## Đọc thêm (link chính thức — bị chặn trong sandbox nên mình chưa mở được)

- JLS §4.2 Primitive Types, §5.1 Conversions, §5.6 Numeric Promotion, §15 Expressions:
  https://docs.oracle.com/javase/specs/jls/se21/html/jls-5.html
- Javadoc `java.lang.String`: https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/String.html
- Javadoc gói `java.time`: https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/time/package-summary.html

## Nguồn tham khảo (Sources)

Các link dưới đây mình đã mở (mã nguồn JDK 21 chứa Javadoc gốc), ngày 2026-09-28:

- `Integer.java` (Javadoc của `valueOf` và `IntegerCache`): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/lang/Integer.java
- `String.java`: https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/lang/String.java
- `Math.java` (`round`, `floorMod`, `addExact`): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/lang/Math.java
- `ZonedDateTime.java` (Javadoc về gap/overlap): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/time/ZonedDateTime.java
- `Period.java`: https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/time/Period.java
