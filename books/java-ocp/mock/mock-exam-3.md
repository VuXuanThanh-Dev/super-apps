# Đề thi thử số 3 — 1Z0-830 (Java SE 21)

**Thời gian: 120 phút · 50 câu · Đậu: ≥ 34 câu đúng (68%).** Làm như thi thật: không IDE, không tra cứu, bấm giờ.
Câu "chọn N đáp án" chỉ tính điểm khi chọn đúng đủ N đáp án. Khi đề không nói gì khác, locale mặc định là `en_US`.
Mọi câu hỏi đều tự viết và đã được biên dịch/chạy bằng JDK 21.0.10 để xác nhận đáp án (code: `examples/questions/mock3/`).

Đáp án và giải thích: [mock-exam-3-answers.md](mock-exam-3-answers.md)

### Câu M3-01

Chương trình sau in ra gì?

```java
import java.util.stream.*;

public class Powers {
    public static void main(String[] args) {
        String s = IntStream.iterate(1, i -> i * 3).takeWhile(i -> i < 100)
                .mapToObj(Integer::toString).collect(Collectors.joining(","));
        System.out.println(s + " " + IntStream.of(4, 8, 2).map(i -> i / 2).max().getAsInt());
    }
}
```

- **A.** `1,3,9,27 4`
- **B.** `1,3,9,27,81,243 4`
- **C.** `1,3,9,27,81 4`
- **D.** `1,3,9,27,81 8`

### Câu M3-02

Chương trình sau in ra gì?

```java
public class Chars {
    public static void main(String[] args) {
        char c = 'x';
        int i = c;
        System.out.println(i + " " + Character.isLetter(c) + " " + Character.getNumericValue('7') + " "
                + Integer.toBinaryString(5) + " " + Integer.parseInt("-0012"));
    }
}
```

- **A.** `120 true 7 101 -12`
- **B.** `x true 7 101 -12`
- **C.** `120 true 55 101 -12`
- **D.** `120 true 7 5 -12`

### Câu M3-03

Những dòng nào gây lỗi biên dịch?

```java
public class Ctx {
    int count;
    static int total;

    static void s() { total++; }
    void i() { count++; total++; s(); }                    // L1
    static void t() { count++; }                           // L2
    static void u() { i(); }                               // L3
    static void v() { new Ctx().i(); this.total = 1; }     // L4

    public static void main(String[] args) { s(); }        // L5
}
```

- **A.** Chỉ L2
- **B.** L2 và L3
- **C.** L3 và L4
- **D.** L2, L3 và L4
- **E.** Chỉ L4

### Câu M3-04

Chương trình sau in ra gì?

```java
import java.util.*;

public class Ends {
    public static void main(String[] args) {
        Deque<Integer> d = new ArrayDeque<>();
        for (int i = 1; i <= 4; i++) {
            if (i % 2 == 0) d.addFirst(i); else d.addLast(i);
        }
        StringBuilder sb = new StringBuilder();
        d.descendingIterator().forEachRemaining(sb::append);
        System.out.println(d + " " + sb + " " + d.removeLast() + " " + d.peekFirst());
    }
}
```

- **A.** `[1, 2, 3, 4] 4321 4 1`
- **B.** `[4, 2, 1, 3] 3124 3 4`
- **C.** `[4, 2, 1, 3] 4213 3 4`
- **D.** `[4, 2, 1, 3] 3124 4 2`

### Câu M3-05

Chương trình sau in ra gì?

```java
public class Converge {
    public static void main(String[] args) {
        int i = 0, j = 10, steps = 0;
        while (i++ < j--) {
            if (i == j) continue;
            steps++;
        }
        System.out.println(i + " " + j + " " + steps);
    }
}
```

- **A.** `5 5 4`
- **B.** `6 4 5`
- **C.** `6 4 4`
- **D.** `5 5 5`

### Câu M3-06

Chương trình sau in ra gì?

```java
class Animal {
    Animal self() { return this; }
    static String type() { return "animal"; }
    String name() { return "a"; }
}

class Cat extends Animal {
    @Override Cat self() { return this; }
    static String type() { return "cat"; }
    @Override String name() { return "c" + super.name(); }
}

public class Covariant {
    public static void main(String[] args) {
        Animal a = new Cat();
        System.out.println(a.self().name() + " " + a.self().getClass().getSimpleName() + " "
                + a.type() + " " + ((Cat) a).type());
    }
}
```

- **A.** `ca Cat animal cat`
- **B.** `ca Animal animal cat`
- **C.** `ca Cat cat cat`
- **D.** `a Cat animal cat`

### Câu M3-07

Chương trình sau in ra gì?

```java
public class Nest {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder();
        try {
            try {
                sb.append(1);
                throw new Exception("e1");
            } catch (Exception e) {
                sb.append(2);
                throw new RuntimeException("e2", e);
            } finally {
                sb.append(3);
            }
        } catch (RuntimeException e) {
            sb.append(4).append(e.getCause().getMessage());
        } finally {
            sb.append(5);
        }
        System.out.println(sb);
    }
}
```

- **A.** `12345e1`
- **B.** `124e15`
- **C.** `1234e25`
- **D.** `1234e15`

### Câu M3-08

Chương trình sau in ra gì?

```java
import java.util.stream.*;

public class Combiner {
    public static void main(String[] args) {
        int total = Stream.of("a", "bb", "ccc").reduce(0,
                (acc, s) -> acc + s.length(),
                (x, y) -> { System.out.print("combine "); return x + y; });
        System.out.println(total);
    }
}
```

- **A.** `combine combine 6`
- **B.** `6`
- **C.** `combine 6`
- **D.** Không biên dịch được: `reduce` không có dạng 3 tham số

### Câu M3-09

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.concurrent.*;

public class AnyOf {
    public static void main(String[] args) throws Exception {
        ExecutorService ex = Executors.newFixedThreadPool(3);
        List<Callable<String>> tasks = List.of(
                () -> { throw new IllegalStateException(); },
                () -> "ok",
                () -> { throw new IllegalArgumentException(); });
        String r = ex.invokeAny(tasks);
        ex.shutdown();
        System.out.println(r + " " + ex.awaitTermination(1, TimeUnit.SECONDS));
    }
}
```

- **A.** Ném `ExecutionException`
- **B.** `null true`
- **C.** `ok true`
- **D.** `ok false`

### Câu M3-10

Chương trình sau in ra gì?

```java
import java.time.*;
import java.time.temporal.ChronoUnit;

public class NewYear {
    public static void main(String[] args) {
        LocalDateTime t = LocalDateTime.of(2024, 12, 31, 23, 59, 45);
        LocalDateTime u = t.plusSeconds(20).truncatedTo(ChronoUnit.MINUTES);
        System.out.println(u + " " + u.getDayOfWeek() + " " + u.getDayOfYear() + " " + t.toLocalDate().isLeapYear());
    }
}
```

- **A.** `2025-01-01T00:00 WEDNESDAY 1 true`
- **B.** `2025-01-01T00:00:05 WEDNESDAY 1 true`
- **C.** `2024-12-31T23:59 TUESDAY 366 true`
- **D.** `2025-01-01T00:00 THURSDAY 1 false`

### Câu M3-11

Những dòng nào gây lỗi biên dịch?

```java
public class Blocks {
    public static void main(String[] args) {
        int x = 1;
        { int y = 2; x += y; }
        for (int i = 0; i < 2; i++) { int z = i; }
        int y = 3;                                     // L1
        int z = 4;                                     // L2
        for (int x2 = 0, y2 = 1; x2 < 1; x2++) { }     // L3
        int i = x;                                     // L4
        { int x = 5; }                                 // L5
    }
}
```

- **A.** L1 và L2
- **B.** L1, L2 và L5
- **C.** L4 và L5
- **D.** Chỉ L5
- **E.** Không dòng nào

### Câu M3-12

Chương trình sau in ra gì?

```java
import java.io.*;
import java.util.*;

public class Graph {
    static class Node implements Serializable {
        String n;
        Node next;
        Node(String n) { this.n = n; }
    }

    public static void main(String[] args) throws Exception {
        Node a = new Node("a"), b = new Node("b");
        a.next = b;
        b.next = a;
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        try (var out = new ObjectOutputStream(bytes)) { out.writeObject(new ArrayList<>(List.of(a, b))); }
        try (var in = new ObjectInputStream(new ByteArrayInputStream(bytes.toByteArray()))) {
            @SuppressWarnings("unchecked")
            List<Node> r = (List<Node>) in.readObject();
            System.out.println((r.get(0).next == r.get(1)) + " " + (r.get(1).next == r.get(0)) + " " + (r.get(0) == a));
        }
    }
}
```

- **A.** `false false false`
- **B.** `true true false`
- **C.** `true true true`
- **D.** `StackOverflowError`

### Câu M3-13

Chương trình sau in ra gì?

```java
public class Ternary {
    public static void main(String[] args) {
        int a = 5;
        Object o1 = true ? a : "x";
        Object o2 = true ? 1 : 2.0;
        Object o3 = false ? 'A' : 66;
        System.out.println(o1.getClass().getSimpleName() + " " + o2 + " " + o3);
    }
}
```

- **A.** `Integer 1 B`
- **B.** `Integer 1.0 66`
- **C.** `Integer 1.0 B`
- **D.** `Object 1 66`

### Câu M3-14

Chương trình sau in ra gì?

```java
import java.util.*;

public class MutableKey {
    public static void main(String[] args) {
        List<String> key = new ArrayList<>(List.of("a"));
        Map<List<String>, Integer> m = new HashMap<>();
        m.put(key, 1);
        key.add("b");
        System.out.println(m.get(key) + " " + m.containsKey(List.of("a")) + " " + m.size());
    }
}
```

- **A.** `null false 1`
- **B.** `1 false 1`
- **C.** `1 true 1`
- **D.** `null true 1`

### Câu M3-15

Đoạn code nào, chèn vào chỗ `// INSERT CODE HERE`, biên dịch và in ra `[A, B, C]`? **(Chọn 3 đáp án.)**

```java
import java.util.*;
import java.util.stream.*;

public class Upper {
    public static void main(String[] args) {
        List<String> in = List.of("a,b", "c");
        // INSERT CODE HERE
    }
}
```

- **A.** `System.out.println(in.stream().flatMap(s -> Arrays.stream(s.split(","))).map(String::toUpperCase).toList());`
- **B.** `System.out.println(in.stream().map(s -> s.split(",")).map(String::toUpperCase).toList());`
- **C.** `System.out.println(in.stream().<String>mapMulti((s, sink) -> { for (String p : s.split(",")) sink.accept(p.toUpperCase()); }).toList());`
- **D.** `System.out.println(String.join(",", in).toUpperCase().chars().filter(Character::isLetter).mapToObj(c -> String.valueOf((char) c)).toList());`
- **E.** `System.out.println(in.stream().map(String::toUpperCase).toList());`

### Câu M3-16

Những dòng nào gây lỗi biên dịch?

```java
public class Enums {
    enum Color { RED, GREEN; Color() { } }                                       // L1
    enum Size { S, M; public Size() { } }                                        // L2
    enum Level { LOW(1), HIGH(2); final int v; Level(int v) { this.v = v; } }    // L3
    enum Mode { ON { void f() { } }, OFF; abstract void f(); }                   // L4
    enum Pet { int legs; DOG, CAT; }                                             // L5

    public static void main(String[] args) { }
}
```

- **A.** L2 và L5
- **B.** L2, L4 và L5
- **C.** L4 và L5
- **D.** L1, L2 và L5
- **E.** Chỉ L2

### Câu M3-17

Lớp `com.x.Main` (không có `module-info`) dùng `java.sql.Types`. Nó được đóng gói vào `app.jar` và chạy bằng `java -cp app.jar com.x.Main`. Điều gì xảy ra?

`src/com/x/Main.java`

```java
package com.x;
public class Main {
    public static void main(String[] args) { System.out.println(java.sql.Types.VARCHAR); }
}
```

- **A.** Chạy bình thường, in ra `12`
- **B.** Ném `NoClassDefFoundError: java/sql/Types`
- **C.** Phải thêm `--add-modules java.sql` mới chạy được
- **D.** Lỗi vì JAR không có `module-info.class`

### Câu M3-18

Chương trình sau in ra gì?

```java
public class Lights {
    enum Light { RED, YELLOW, GREEN }

    static int wait(Light l) {
        int w = 0;
        switch (l) {
            case RED: w += 30;
            case YELLOW: w += 5; break;
            case GREEN: w += 0;
            default: w -= 1;
        }
        return w;
    }

    public static void main(String[] args) {
        System.out.println(wait(Light.RED) + " " + wait(Light.YELLOW) + " " + wait(Light.GREEN));
    }
}
```

- **A.** `30 5 0`
- **B.** `35 5 0`
- **C.** `35 35 -1`
- **D.** `35 5 -1`

### Câu M3-19

Chương trình sau in ra gì?

```java
public class Transform {
    interface Transformer<T, R> {
        R apply(T t);
        default <V> Transformer<T, V> andThen(Transformer<R, V> next) { return t -> next.apply(apply(t)); }
    }

    public static void main(String[] args) {
        Transformer<String, Integer> len = String::length;
        Transformer<String, String> desc = len.andThen(n -> n > 3 ? "long" : "short");
        System.out.println(desc.apply("java") + " " + desc.apply("go") + " "
                + len.andThen(Integer::toBinaryString).apply("abcde"));
    }
}
```

- **A.** `short short 101`
- **B.** `long short 101`
- **C.** `long short 5`
- **D.** `long long 101`

### Câu M3-20

Chèn dòng nào vào chỗ `// INSERT CODE HERE` thì chương trình biên dịch được? **(Chọn 3 đáp án.)**

```java
import java.io.*;
import java.util.concurrent.Callable;

public class Lam {
    public static void main(String[] args) throws Exception {
        // INSERT CODE HERE
    }
}
```

- **A.** `Callable<String> c = () -> { throw new IOException(); };`
- **B.** `Runnable r = () -> { throw new IOException(); };`
- **C.** `Runnable r = () -> { throw new UncheckedIOException(new IOException()); };`
- **D.** `Runnable r = () -> { try { throw new IOException(); } catch (IOException e) { } };`
- **E.** `java.util.function.Supplier<String> s = () -> { throw new Exception(); };`

### Câu M3-21

Chương trình sau in ra gì?

```java
import java.util.*;

public class Utils {
    public static void main(String[] args) {
        List<String> l = new ArrayList<>(Collections.nCopies(2, "x"));
        l.addAll(List.of("y", "x", "z"));
        Collections.sort(l, Comparator.reverseOrder());
        System.out.println(l + " " + Collections.frequency(l, "x") + " " + Collections.max(l) + " " + l.lastIndexOf("x"));
    }
}
```

- **A.** `[x, x, x, y, z] 3 z 2`
- **B.** `[z, y, x, x, x] 3 x 4`
- **C.** `[z, y, x, x, x] 3 z 4`
- **D.** `[z, y, x, x, x] 2 z 4`

### Câu M3-22

Chương trình sau in ra gì?

```java
public class Sb2 {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("abcdef");
        sb.setCharAt(0, 'A');
        sb.replace(1, 3, "-");
        sb.deleteCharAt(sb.length() - 1).append(sb.length());
        System.out.println(sb + " " + "ab".compareTo("abc") + " " + "b".compareTo("a") + " "
                + String.valueOf(new char[]{'h', 'i'}).repeat(2));
    }
}
```

- **A.** `A-de4 -1 1 hihi`
- **B.** `A-de5 -1 1 hihi`
- **C.** `A-def4 -1 1 hihi`
- **D.** `A-de4 -99 1 hihi`

### Câu M3-23

Chương trình sau in ra gì?

```java
public class Factory {
    private static int created = 0;

    static class Part { Part() { created++; } }

    class Tool { Part p = new Part(); }

    public static void main(String[] args) {
        Factory f = new Factory();
        Tool t1 = f.new Tool();
        Tool t2 = f.new Tool();
        Part extra = new Part();
        t1 = t2;
        System.out.println(created + " " + (t1.p == t2.p));
    }
}
```

- **A.** `2 true`
- **B.** `3 false`
- **C.** `1 true`
- **D.** `3 true`

### Câu M3-24

Hai phát biểu nào đúng? **(Chọn 2 đáp án.)**

- **A.** Một thread có thể vào lại khối `synchronized` trên cùng object mà nó đang giữ khoá.
- **B.** Method `static synchronized` và method instance `synchronized` của cùng một lớp dùng chung một khoá.
- **C.** Gọi `wait()` bên ngoài khối `synchronized` trên object đó ném `IllegalMonitorStateException`.
- **D.** `ReentrantLock.lock()` ném exception nếu khoá đang bị thread khác giữ.
- **E.** `AtomicInteger.compareAndSet(expect, update)` luôn đặt giá trị mới.

### Câu M3-25

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.stream.*;

public class NullKey {
    public static void main(String[] args) {
        List<String> l = Arrays.asList("a", null, "b");
        try {
            l.stream().collect(Collectors.groupingBy(s -> s == null ? null : s.length()));
            System.out.print("ok ");
        } catch (NullPointerException e) {
            System.out.print("NPE ");
        }
        System.out.println(l.stream().filter(Objects::nonNull).collect(Collectors.partitioningBy(s -> s.equals("a"))));
    }
}
```

- **A.** `ok {false=[b], true=[a]}`
- **B.** `NPE {true=[a], false=[b]}`
- **C.** `NPE {false=[b], true=[a]}`
- **D.** `ok {false=[null, b], true=[a]}`

### Câu M3-26

Chương trình sau in ra gì?

```java
import java.io.*;
import java.nio.file.*;
import java.util.List;
import java.util.stream.Collectors;

public class Rest {
    public static void main(String[] args) throws IOException {
        Files.write(Path.of("in.txt"), List.of("alpha", "beta", "gamma"));
        try (BufferedReader r = Files.newBufferedReader(Path.of("in.txt"))) {
            r.readLine();
            String rest = r.lines().map(s -> s.substring(0, 1)).collect(Collectors.joining());
            System.out.println(rest + " " + r.readLine());
        }
    }
}
```

- **A.** `bg null`
- **B.** `abg null`
- **C.** `bg gamma`
- **D.** `abg gamma`

### Câu M3-27

Chương trình sau in ra gì?

```java
import java.text.*;
import java.util.Locale;

public class Neg {
    public static void main(String[] args) throws ParseException {
        DecimalFormat df = new DecimalFormat("#,##0.00;(#,##0.00)", DecimalFormatSymbols.getInstance(Locale.US));
        System.out.println(df.format(-1234.567) + " " + df.format(0.5) + " " + df.parse("(12.50)"));
    }
}
```

- **A.** `-1,234.57 0.50 12.5`
- **B.** `(1,234.56) .50 -12.5`
- **C.** `(1,234.57) 0.5 -12.5`
- **D.** `(1,234.57) 0.50 -12.5`

### Câu M3-28

Kết quả của chương trình là gì?

```java
public class GenericPattern {
    record Box<T>(T value) { }

    public static void main(String[] args) {
        Object o = new Box<>("hi");
        String r;
        if (o instanceof Box<?>(String s) && s.length() == 2) r = "string box " + s;
        else if (o instanceof Box<?> b) r = "box " + b.value();
        else r = "other";
        System.out.println(r);
    }
}
```

- **A.** `box hi`
- **B.** `string box hi`
- **C.** `other`
- **D.** Không biên dịch được

### Câu M3-29

Điền nội dung `module-info.java` nào cho module provider `com.p` (thay `// INSERT CODE HERE`) để consumer `com.app` (có `uses com.api.Svc`) tìm thấy ít nhất một provider (in ra `found`)? **(Chọn 2 đáp án.)**

`src/com.app/module-info.java`

```java
module com.app { requires com.api; uses com.api.Svc; }
```

- **A.** `module com.p { requires com.api; provides com.api.Svc with com.p.Impl; }`
- **B.** `module com.p { requires com.api; provides com.api.Svc with com.p.Impl, com.p.Impl2; }`
- **C.** `module com.p { provides com.api.Svc with com.p.Impl; }`
- **D.** `module com.p { requires com.api; exports com.p; provides com.p.Impl with com.api.Svc; }`
- **E.** `module com.p { requires com.api; uses com.api.Svc; }`

### Câu M3-30

Chương trình sau in ra gì?

```java
import java.time.*;

public class Zones {
    public static void main(String[] args) {
        ZonedDateTime hcm = ZonedDateTime.of(LocalDateTime.of(2024, 6, 1, 1, 0), ZoneId.of("Asia/Ho_Chi_Minh"));
        ZonedDateTime la = hcm.withZoneSameInstant(ZoneId.of("America/Los_Angeles"));
        System.out.println(la.toLocalDateTime() + " " + la.getOffset() + " " + hcm.toInstant().equals(la.toInstant())
                + " " + hcm.isEqual(la) + " " + hcm.equals(la));
    }
}
```

- **A.** `2024-06-01T11:00 -07:00 true true true`
- **B.** `2024-05-31T11:00 -08:00 true true false`
- **C.** `2024-05-31T11:00 -07:00 true true false`
- **D.** `2024-05-31T11:00 -07:00 true false false`

### Câu M3-31

Chương trình sau in ra gì?

```java
public class Pick {
    static String f(Object o) { return "Object"; }
    static String f(Number n) { return "Number"; }
    static String f(Integer i) { return "Integer"; }

    public static void main(String[] args) {
        short s = 1;
        System.out.println(f(5) + " " + f(5L) + " " + f(s) + " " + f("s") + " " + f(null));
    }
}
```

- **A.** `Integer Number Number Object Integer`
- **B.** `Number Number Number Object Integer`
- **C.** `Integer Number Object Object Integer`
- **D.** `Integer Number Number Object Object`

### Câu M3-32

Điều gì đúng về output của chương trình?

```java
public class Joins {
    public static void main(String[] args) throws InterruptedException {
        StringBuffer sb = new StringBuffer();
        Thread a = new Thread(() -> sb.append("a"));
        Thread b = new Thread(() -> {
            try { a.join(); } catch (InterruptedException e) { }
            sb.append("b");
        });
        a.start();
        b.start();
        b.join();
        sb.append("m");
        System.out.println(sb + " " + a.isAlive() + " " + b.isDaemon());
    }
}
```

- **A.** Luôn in `bam false false`
- **B.** Luôn in `abm true false`
- **C.** Thứ tự chữ cái thay đổi mỗi lần chạy
- **D.** Luôn in `abm false false`

### Câu M3-33

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.stream.*;

public class ArrStream {
    public static void main(String[] args) {
        int[] nums = {3, 1, 2};
        System.out.println(Stream.of(nums).count() + " " + Arrays.stream(nums).count() + " "
                + Stream.of(3, 1, 2).count() + " " + IntStream.of(nums).sorted().boxed().toList());
    }
}
```

- **A.** `3 3 3 [1, 2, 3]`
- **B.** `1 3 3 [1, 2, 3]`
- **C.** `1 3 3 [3, 1, 2]`
- **D.** `1 1 3 [1, 2, 3]`

### Câu M3-34

Chương trình sau in ra gì?

```java
import java.util.Arrays;

public class Tags {
    record Tag(String[] values) {
        Tag { values = values.clone(); }
        static Tag of(String... v) { return new Tag(v); }
    }

    public static void main(String[] args) {
        String[] src = {"a", "b"};
        Tag t1 = Tag.of(src), t2 = Tag.of(src);
        src[0] = "z";
        System.out.println(t1.values()[0] + " " + t1.equals(t2) + " " + Arrays.equals(t1.values(), t2.values()));
    }
}
```

- **A.** `a false true`
- **B.** `z false true`
- **C.** `a true true`
- **D.** `a false false`

### Câu M3-35

Chương trình sau in ra gì?

```java
public class DoLoop {
    public static void main(String[] args) {
        int n = 0, sum = 0;
        do {
            n++;
            if (n == 2) continue;
            if (n == 5) break;
            sum += n;
        } while (n < 10);
        System.out.println(n + " " + sum);
    }
}
```

- **A.** `10 8`
- **B.** `5 10`
- **C.** `5 8`
- **D.** `4 8`

### Câu M3-36

Hai phát biểu nào đúng về `Map`? **(Chọn 2 đáp án.)**

- **A.** `put(k, v)` trả về giá trị cũ của key (hoặc `null`).
- **B.** `getOrDefault(k, d)` thêm key `k` với giá trị `d` vào map nếu chưa có.
- **C.** `merge(k, v, f)` xoá key nếu hàm `f` trả về `null`.
- **D.** `TreeMap.firstKey()` trên map rỗng trả về `null`.
- **E.** `HashMap` cho phép nhiều key `null`.

### Câu M3-37

Chương trình sau in ra gì?

```java
public class OpenFail {
    static class R implements AutoCloseable {
        final String n;
        R(String n, boolean fail) {
            this.n = n;
            if (fail) throw new IllegalStateException("open " + n);
            System.out.print("open" + n + " ");
        }
        public void close() { System.out.print("close" + n + " "); }
    }

    public static void main(String[] args) {
        try (R a = new R("A", false); R b = new R("B", true)) {
            System.out.print("body ");
        } catch (IllegalStateException e) {
            System.out.print(e.getMessage());
        }
    }
}
```

- **A.** `openA open B`
- **B.** `openA body closeA open B`
- **C.** `openA closeA closeB open B`
- **D.** `openA closeA open B`

### Câu M3-38

Điền biểu thức nào vào chỗ `___` thì chương trình in ra `true`? **(Chọn 3 đáp án.)**

```java
public class Truth {
    public static void main(String[] args) {
        System.out.println(___);
    }
}
```

- **A.** `0.1 + 0.2 == 0.3`
- **B.** `10 / 4 * 4 == 8`
- **C.** `(int) 'a' == 97`
- **D.** `Math.min(-0.0, 0.0) == 0.0`
- **E.** `Integer.MAX_VALUE + 1 > Integer.MAX_VALUE`

### Câu M3-39

Những dòng nào gây lỗi biên dịch?

```java
public class Fis {
    @FunctionalInterface interface A { void run(); }                                     // L1
    @FunctionalInterface interface B { void run(); void stop(); }                        // L2
    @FunctionalInterface interface C extends A { }                                       // L3
    @FunctionalInterface interface D extends A { default void stop() { } }               // L4
    @FunctionalInterface interface E { boolean equals(Object o); }                       // L5

    public static void main(String[] args) { }
}
```

- **A.** Chỉ L2
- **B.** L2 và L5
- **C.** L2, L3 và L5
- **D.** L4 và L5
- **E.** Chỉ L5

### Câu M3-40

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.stream.*;

public class Skills {
    record Dev(String team, List<String> skills) { }

    public static void main(String[] args) {
        List<Dev> ds = List.of(new Dev("A", List.of("java", "sql")), new Dev("B", List.of("js")),
                new Dev("A", List.of("java", "go")));
        Map<String, Set<String>> skills = ds.stream().collect(Collectors.groupingBy(Dev::team, TreeMap::new,
                Collectors.flatMapping(d -> d.skills().stream(), Collectors.toCollection(TreeSet::new))));
        Map<String, Long> javaDevs = ds.stream().collect(Collectors.groupingBy(Dev::team, TreeMap::new,
                Collectors.filtering(d -> d.skills().contains("java"), Collectors.counting())));
        System.out.println(skills + " " + javaDevs);
    }
}
```

- **A.** `{A=[java, sql, java, go], B=[js]} {A=2, B=0}`
- **B.** `{A=[go, java, sql], B=[js]} {A=2}`
- **C.** `{A=[go, java, sql], B=[js]} {A=2, B=0}`
- **D.** `{A=[go, java, sql], B=[js]} {A=1, B=0}`

### Câu M3-41

Chương trình sau in ra gì?

```java
import java.io.IOException;
import java.nio.file.*;

public class Replace {
    public static void main(String[] args) throws IOException {
        Path a = Files.createFile(Path.of("a.txt"));
        Path b = Files.writeString(Path.of("b.txt"), "B");
        try {
            Files.createFile(a);
        } catch (FileAlreadyExistsException e) {
            System.out.print("exists ");
        }
        Files.move(b, a, StandardCopyOption.REPLACE_EXISTING);
        System.out.println(Files.readString(a) + " " + Files.exists(b) + " " + Files.size(a));
    }
}
```

- **A.** `exists B false 1`
- **B.** `B false 1`
- **C.** `exists B true 1`
- **D.** `exists  false 0`

### Câu M3-42

Chương trình sau in ra gì?

```java
import java.util.Locale;

public class Names {
    public static void main(String[] args) {
        Locale vi = Locale.of("vi", "VN");
        System.out.println(Locale.FRANCE.getDisplayCountry(vi) + " | " + vi.getDisplayLanguage(Locale.FRANCE)
                + " | " + Locale.of("vi").getDisplayName(Locale.US));
    }
}
```

- **A.** `France | Vietnamese | Vietnamese`
- **B.** `Pháp | vietnamien | Vietnamese (Vietnam)`
- **C.** `Pháp | Vietnamese | Vietnamese`
- **D.** `Pháp | vietnamien | Vietnamese`

### Câu M3-43

Những dòng nào gây lỗi biên dịch?

```java
public class Mods {
    abstract static class A { abstract void f(); }                  // L1
    abstract static class B { final abstract void f(); }            // L2
    abstract static class C { private abstract void f(); }          // L3
    abstract static class D { static void f() { } }                 // L4
    static final class E extends A { void f() { } }                 // L5
    abstract static class F { abstract static void f(); }           // L6

    public static void main(String[] args) { }
}
```

- **A.** L2 và L3
- **B.** L2, L3 và L5
- **C.** L2, L3 và L6
- **D.** L3 và L6
- **E.** Chỉ L6

### Câu M3-44

Điều gì đúng về output của chương trình?

```java
import java.util.*;
import java.util.concurrent.*;
import java.util.stream.*;

public class ChmMerge {
    public static void main(String[] args) {
        ConcurrentHashMap<Integer, Integer> m = new ConcurrentHashMap<>();
        IntStream.range(0, 1000).parallel().forEach(i -> m.merge(i % 3, 1, Integer::sum));
        System.out.println(new TreeMap<>(m) + " " + m.reduceValues(1, Integer::sum));
    }
}
```

- **A.** Giá trị thay đổi mỗi lần chạy
- **B.** Luôn in `{0=334, 1=333, 2=333} 1000`
- **C.** Luôn in `{0=333, 1=333, 2=334} 1000`
- **D.** Ném `ConcurrentModificationException`

### Câu M3-45

Chương trình sau in ra gì?

```java
public class Pool {
    public static void main(String[] args) {
        final String a = "Ja";
        String b = "Ja";
        String c = a + "va";
        String d = b + "va";
        String e = "Java";
        System.out.println((c == e) + " " + (d == e) + " " + (d.intern() == e) + " " + c.equals(d));
    }
}
```

- **A.** `true false true true`
- **B.** `false false true true`
- **C.** `true true true true`
- **D.** `true false false true`

### Câu M3-46

Những dòng nào gây lỗi biên dịch?

```java
import java.util.*;

public class Conv {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>(List.of("a"));
        String[] a1 = list.toArray(new String[0]);        // L1
        String[] a2 = list.toArray();                     // L2
        Object[] a3 = list.toArray();                     // L3
        String[] a4 = list.toArray(String[]::new);        // L4
        List<String> l2 = Arrays.asList(a1);              // L5
        int[] ints = {1, 2};
        List<Integer> l3 = Arrays.asList(ints);           // L6
    }
}
```

- **A.** Chỉ L2
- **B.** L2 và L4
- **C.** Chỉ L6
- **D.** L2 và L6
- **E.** L2, L4 và L6

### Câu M3-47

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.stream.*;

public class Opts {
    public static void main(String[] args) {
        List<Optional<String>> opts = List.of(Optional.of("a"), Optional.empty(), Optional.of("c"));
        String r = opts.stream().flatMap(Optional::stream).collect(Collectors.joining("+"));
        long empties = opts.stream().filter(Optional::isEmpty).count();
        System.out.println(r + " " + empties + " " + opts.get(1).map(String::length).orElse(-1));
    }
}
```

- **A.** `a++c 1 -1`
- **B.** `a+c 1 0`
- **C.** `a+c 1 -1`
- **D.** `a+Optional.empty+c 1 -1`

### Câu M3-48

Chương trình sau in ra gì?

```java
public class Leak {
    static final class Schedule {
        private final int[] days;
        Schedule(int[] days) { this.days = days; }
        int[] days() { return days.clone(); }
        int first() { return days[0]; }
    }

    public static void main(String[] args) {
        int[] input = {1, 2, 3};
        Schedule s = new Schedule(input);
        s.days()[0] = 99;
        input[1] = 42;
        System.out.println(s.first() + " " + s.days()[1]);
    }
}
```

- **A.** `99 42`
- **B.** `1 42`
- **C.** `1 2`
- **D.** `99 2`

### Câu M3-49

Module `com.v` đã được đóng gói vào `mods/x.jar` (JAR modular). Lệnh nào (thay cho `<LỆNH>`) in ra dòng đầu tiên bắt đầu bằng tên module `com.v` (tức là hiển thị mô tả module)? **(Chọn 3 đáp án.)**

- **A.** `jar --describe-module --file mods/x.jar`
- **B.** `jar -d -f mods/x.jar`
- **C.** `java -p mods --describe-module com.v`
- **D.** `jar --list --file mods/x.jar`
- **E.** `java --describe-module com.v`

### Câu M3-50

Kết quả của chương trình là gì?

```java
public class Cmds {
    sealed interface Cmd permits Move, Stop { }
    enum Move implements Cmd { LEFT, RIGHT }
    record Stop() implements Cmd { }

    static String run(Cmd c) {
        return switch (c) {
            case Move.LEFT -> "L";
            case Move.RIGHT -> "R";
            case Stop s -> "S";
        };
    }

    public static void main(String[] args) {
        System.out.println(run(Move.RIGHT) + run(new Stop()) + run(Move.LEFT));
    }
}
```

- **A.** Không biên dịch được: switch thiếu `default`
- **B.** Không biên dịch được: nhãn case của enum phải là tên không đầy đủ
- **C.** In ra `LSR`
- **D.** In ra `RSL`
