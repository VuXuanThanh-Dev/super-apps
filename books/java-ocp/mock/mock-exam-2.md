# Đề thi thử số 2 — 1Z0-830 (Java SE 21)

**Thời gian: 120 phút · 50 câu · Đậu: ≥ 34 câu đúng (68%).** Làm như thi thật: không IDE, không tra cứu, bấm giờ.
Câu "chọn N đáp án" chỉ tính điểm khi chọn đúng đủ N đáp án. Khi đề không nói gì khác, locale mặc định là `en_US`.
Mọi câu hỏi đều tự viết và đã được biên dịch/chạy bằng JDK 21.0.10 để xác nhận đáp án (code: `examples/questions/mock2/`).

Đáp án và giải thích: [mock-exam-2-answers.md](mock-exam-2-answers.md)

### Câu M2-01

Chương trình sau in ra gì?

```java
public class Boxes {
    public static void main(String[] args) {
        Integer a = 127;
        Integer b = 127;
        Long c = 127L;
        System.out.println((a == b) + " " + a.equals(c) + " " + (a.intValue() == c) + " " + c.equals(127L));
    }
}
```

- **A.** `true true true true`
- **B.** `true false true true`
- **C.** `true false false true`
- **D.** `false false true true`

### Câu M2-02

Chương trình sau in ra gì?

```java
public class Grades {
    static int score(char g) {
        return switch (g) {
            case 'A': case 'B':
                yield 3;
            case 'C':
                System.out.print("C! ");
            case 'D':
                yield 1;
            default:
                yield 0;
        };
    }

    public static void main(String[] args) {
        System.out.println(score('B') + score('C') + score('X'));
    }
}
```

- **A.** `4`
- **B.** `C! 3`
- **C.** `C! 5`
- **D.** `C! 4`

### Câu M2-03

Chương trình sau in ra gì?

```java
public class Temps {
    record Temp(double celsius) {
        Temp {
            if (celsius < -273.15) celsius = -273.15;
        }
        public double celsius() { return Math.round(celsius * 10) / 10.0; }
    }

    public static void main(String[] args) {
        Temp a = new Temp(21.456), b = new Temp(21.4), c = new Temp(-300);
        System.out.println(a.celsius() + " " + a.equals(b) + " " + c + " "
                + (a.hashCode() == new Temp(21.456).hashCode()));
    }
}
```

- **A.** `21.5 false Temp[celsius=-273.15] true`
- **B.** `21.5 true Temp[celsius=-273.15] true`
- **C.** `21.456 false Temp[celsius=-300.0] true`
- **D.** `21.5 false Temp[celsius=-273.2] true`

### Câu M2-04

Chương trình sau in ra gì?

```java
import java.util.*;

public class Nav {
    public static void main(String[] args) {
        TreeMap<Integer, String> m = new TreeMap<>(Map.of(10, "ten", 20, "twenty", 30, "thirty", 40, "forty"));
        System.out.println(m.floorKey(25) + " " + m.ceilingEntry(25) + " " + m.headMap(30).keySet() + " "
                + m.tailMap(30, false) + " " + m.descendingMap().firstKey());
    }
}
```

- **A.** `20 30=thirty [10, 20, 30] {40=forty} 40`
- **B.** `30 20=twenty [10, 20] {30=thirty, 40=forty} 10`
- **C.** `20 30=thirty [10, 20] {40=forty} 40`
- **D.** `20 30=thirty [10, 20] {30=thirty, 40=forty} 40`

### Câu M2-05

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.stream.*;

public class Merge {
    public static void main(String[] args) {
        Map<Character, Integer> m = Stream.of("kiwi", "apple", "avocado", "kale", "banana")
                .collect(Collectors.toMap(s -> s.charAt(0), String::length, Integer::sum, LinkedHashMap::new));
        System.out.println(m);
    }
}
```

- **A.** `{a=12, b=6, k=8}`
- **B.** `{k=8, a=12, b=6}`
- **C.** `{k=4, a=5, b=6}`
- **D.** `IllegalStateException: Duplicate key k`

### Câu M2-06

Những dòng nào gây lỗi biên dịch?

```java
public class Amb {
    static void f(String s) { }
    static void f(StringBuilder sb) { }
    static void g(Object o) { }
    static void g(String s) { }
    static void h(int... a) { }
    static void h(long... a) { }

    public static void main(String[] args) {
        f(null);             // L1
        g(null);             // L2
        h();                 // L3
        h(1);                // L4
        f((String) null);    // L5
    }
}
```

- **A.** L1 và L3
- **B.** L1, L3 và L4
- **C.** Chỉ L2
- **D.** Chỉ L1
- **E.** Không dòng nào

### Câu M2-07

Chương trình sau in ra gì?

```java
public class Block {
    public static void main(String[] args) {
        String t = """
            ab\tc
              d\
            e
            """;
        System.out.println(t.lines().count() + " " + t.length() + " "
                + t.indent(2).lines().findFirst().get().length() + " " + "  x ".strip().length());
    }
}
```

- **A.** `2 10 6 1`
- **B.** `3 11 6 1`
- **C.** `2 12 6 1`
- **D.** `2 10 4 1`

### Câu M2-08

Chương trình sau in ra gì?

```java
public class Ret {
    static int f() {
        int x = 1;
        try {
            x = 2;
            throw new RuntimeException("try");
        } catch (RuntimeException e) {
            x = 3;
            return x;
        } finally {
            x = 4;
            System.out.print("finally x=" + x + " ");
        }
    }

    public static void main(String[] args) {
        System.out.println("result=" + f());
    }
}
```

- **A.** `finally x=4 result=4`
- **B.** `result=3 finally x=4`
- **C.** `finally x=4 result=3`
- **D.** `finally x=3 result=3`

### Câu M2-09

Chương trình sau in ra gì?

```java
import java.io.IOException;
import java.util.concurrent.*;

public class States {
    public static void main(String[] args) throws Exception {
        ExecutorService ex = Executors.newSingleThreadExecutor();
        Future<Integer> f = ex.submit(() -> {
            if (true) throw new IOException("disk");
            return 1;
        });
        try {
            f.get();
        } catch (ExecutionException e) {
            System.out.print(e.getCause() instanceof IOException ? "IO " : "other ");
        }
        System.out.print(f.isDone() + " " + f.isCancelled() + " " + f.state());
        ex.shutdown();
    }
}
```

- **A.** `IO false false FAILED`
- **B.** `IO true false FAILED`
- **C.** `other true false FAILED`
- **D.** `IO true false SUCCESS`

### Câu M2-10

Chương trình sau in ra gì?

```java
public class Grid {
    public static void main(String[] args) {
        int[][] grid = {{1, 2}, {3, 4}, {5, 6}};
        int total = 0;
        for (var row : grid) {
            for (var v : row) {
                if (v == 4) break;
                total += v;
            }
        }
        System.out.println(total);
    }
}
```

- **A.** `6`
- **B.** `21`
- **C.** `11`
- **D.** `17`

### Câu M2-11

Chương trình sau in ra gì?

```java
class P {
    String name = "P";
    String who() { return "P.who:" + name; }
}

class C extends P {
    String name = "C";
    String who() { return "C.who:" + name + "/" + super.name + "/" + super.who(); }
}

public class Hide {
    public static void main(String[] args) {
        P p = new C();
        System.out.println(p.who() + " | " + p.name);
    }
}
```

- **A.** `C.who:C/P/P.who:P | P`
- **B.** `C.who:C/P/P.who:C | P`
- **C.** `C.who:C/P/P.who:P | C`
- **D.** `P.who:P | P`

### Câu M2-12

Những dòng nào gây lỗi biên dịch?

```java
public class Statics {
    interface Tool {
        static String id() { return "tool"; }
        default String name() { return id(); }
    }

    static class Hammer implements Tool { }

    public static void main(String[] args) {
        Hammer h = new Hammer();
        String a = Tool.id();          // L1
        String b = h.name();           // L2
        String c = Hammer.id();        // L3
        String d = h.id();             // L4
    }
}
```

- **A.** Chỉ L3
- **B.** Chỉ L4
- **C.** L3 và L4
- **D.** L2, L3 và L4
- **E.** Không dòng nào

### Câu M2-13

Chương trình sau in ra gì?

```java
import java.time.*;

public class Inst {
    public static void main(String[] args) {
        Instant start = Instant.parse("2024-02-28T22:00:00Z");
        Instant end = start.plus(Duration.ofHours(30));
        Duration d = Duration.between(start, end);
        System.out.println(end + " " + d + " " + d.toDaysPart() + " " + d.toHoursPart());
    }
}
```

- **A.** `2024-02-30T04:00:00Z PT30H 1 6`
- **B.** `2024-03-01T04:00:00Z PT30H 1 6`
- **C.** `2024-03-01T04:00:00Z P1DT6H 1 6`
- **D.** `2024-03-01T04:00:00Z PT30H 30 6`

### Câu M2-14

Chương trình sau in ra gì?

```java
import java.util.*;

public class Sets {
    public static void main(String[] args) {
        Set<String> s = new LinkedHashSet<>(List.of("d", "a", "c", "b"));
        s.removeIf(x -> x.compareTo("b") < 0);
        Set<String> other = new TreeSet<>(List.of("c", "d", "e"));
        s.retainAll(other);
        s.add("a");
        System.out.println(s + " " + other);
    }
}
```

- **A.** `[a, c, d] [c, d, e]`
- **B.** `[d, c, b, a] [c, d, e]`
- **C.** `[c, d, a] [c, d, e]`
- **D.** `[d, c, a] [c, d, e]`

### Câu M2-15

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.stream.*;

public class Barrier {
    public static void main(String[] args) {
        List<Integer> r = Stream.of(3, 1, 2)
                .peek(x -> System.out.print("a" + x + " "))
                .sorted()
                .peek(x -> System.out.print("b" + x + " "))
                .limit(2)
                .toList();
        System.out.println(r);
    }
}
```

- **A.** `a3 a1 a2 b1 b2 [1, 2]`
- **B.** `a3 b3 a1 b1 [3, 1]`
- **C.** `a3 a1 a2 b1 b2 b3 [1, 2]`
- **D.** `a1 a2 a3 b1 b2 [1, 2]`

### Câu M2-16

Chương trình sau in ra gì?

```java
public class Anon {
    interface Greeter { String greet(); }

    String name = "outer";

    Greeter make() {
        String name = "local";
        return new Greeter() {
            String name = "anon";
            public String greet() { return name + "," + this.name + "," + Anon.this.name; }
        };
    }

    public static void main(String[] args) {
        System.out.println(new Anon().make().greet());
    }
}
```

- **A.** `local,anon,outer`
- **B.** `anon,local,outer`
- **C.** `anon,anon,outer`
- **D.** `local,local,outer`

### Câu M2-17

Module `com.m` có `exports com.m.model;` và `opens com.m.model to com.fw;`. Hai module `com.fw` và `com.other` cùng `requires com.m` và dùng reflection đọc field `private` của `com.m.model.Secret`. Output của hai lệnh chạy là gì?

`src/com.m/module-info.java`

```java
module com.m {
    exports com.m.model;
    opens com.m.model to com.fw;
}
```

`src/com.m/com/m/model/Secret.java`

```java
package com.m.model;
public class Secret { private int code = 42; }
```

`src/com.fw/module-info.java`

```java
module com.fw { requires com.m; }
```

`src/com.fw/com/fw/Main.java`

```java
package com.fw;
public class Main {
    public static void main(String[] args) throws Exception {
        var f = com.m.model.Secret.class.getDeclaredField("code");
        try { f.setAccessible(true); System.out.println("com.fw: " + f.get(new com.m.model.Secret())); }
        catch (RuntimeException e) { System.out.println("com.fw: " + e.getClass().getSimpleName()); }
    }
}
```

`src/com.other/module-info.java`

```java
module com.other { requires com.m; }
```

`src/com.other/com/other/Main.java`

```java
package com.other;
public class Main {
    public static void main(String[] args) throws Exception {
        var f = com.m.model.Secret.class.getDeclaredField("code");
        try { f.setAccessible(true); System.out.println("com.other: " + f.get(new com.m.model.Secret())); }
        catch (RuntimeException e) { System.out.println("com.other: " + e.getClass().getSimpleName()); }
    }
}
```

- **A.** Cả hai in ra `42`
- **B.** `com.fw: 42` và `com.other: InaccessibleObjectException`
- **C.** Cả hai ném `InaccessibleObjectException`
- **D.** Lỗi biên dịch: không được vừa `exports` vừa `opens ... to`

### Câu M2-18

Chương trình sau in ra gì?

```java
public class Compound {
    public static void main(String[] args) {
        short s = 10;
        char c = 'A';
        byte b = 5;
        s *= 2.5;
        c += 1.9;
        b >>= 1;
        int i = 'a' + 'b';
        System.out.println(s + " " + c + " " + b + " " + i + " " + (char) (c + 1));
    }
}
```

- **A.** `25 C 2 195 D`
- **B.** `25 B 2 ab C`
- **C.** `25 B 2.5 195 C`
- **D.** `25 B 2 195 C`

### Câu M2-19

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.stream.*;

public class Orders {
    record Order(String id, double amount, boolean paid) { }

    public static void main(String[] args) {
        List<Order> os = List.of(new Order("a", 100, true), new Order("b", 50, false),
                new Order("c", 25, true), new Order("d", 75, false));
        Map<Boolean, Double> sums = os.stream().collect(
                Collectors.partitioningBy(Order::paid, Collectors.summingDouble(Order::amount)));
        String r = os.stream().collect(Collectors.teeing(Collectors.counting(),
                Collectors.averagingDouble(Order::amount), (n, avg) -> n + "@" + avg));
        System.out.println(sums + " " + r);
    }
}
```

- **A.** `{false=125.0, true=125.0} 4@62.5`
- **B.** `{true=125.0, false=125.0} 4@62.5`
- **C.** `{false=125.0, true=125.0} 4@250.0`
- **D.** `{false=2, true=2} 4@62.5`

### Câu M2-20

Chương trình sau in ra gì?

```java
public class Days {
    enum Day {
        MON, TUE, WED, THU, FRI, SAT, SUN;
        boolean weekend() { return switch (this) { case SAT, SUN -> true; default -> false; }; }
    }

    public static void main(String[] args) {
        Day d = Day.valueOf("FRI");
        System.out.println(d.weekend() + " " + Day.values()[d.ordinal() + 2] + " " + d.compareTo(Day.MON) + " "
                + Day.SUN.weekend());
    }
}
```

- **A.** `false SAT 4 true`
- **B.** `false SUN -4 true`
- **C.** `false SUN 4 true`
- **D.** `true SUN 4 true`

### Câu M2-21

Những dòng nào gây lỗi biên dịch?

```java
public class Res {
    static class R implements AutoCloseable { public void close() { } }

    public static void main(String[] args) throws Exception {
        R a = new R();
        try (a) { }                                 // L1
        R b = new R();
        b = new R();
        try (b) { }                                 // L2
        try (R c = new R()) { c = new R(); }        // L3
        final R d = new R();
        try (d; R e = new R()) { }                  // L4
    }
}
```

- **A.** Chỉ L2
- **B.** L2 và L3
- **C.** L1 và L2
- **D.** L2, L3 và L4
- **E.** Chỉ L3

### Câu M2-22

Chương trình sau in ra gì?

```java
import java.nio.file.*;

public class Sub {
    public static void main(String[] args) {
        Path p = Path.of("/usr/local/lib/java/tools.jar");
        System.out.println(p.subpath(1, 3) + " " + p.getName(p.getNameCount() - 2) + " " + p.getRoot() + " "
                + Path.of("a", "..", "b").normalize() + " " + p.getParent().getParent().getFileName());
    }
}
```

- **A.** `usr/local java / b lib`
- **B.** `local/lib/java java / b java`
- **C.** `local/lib tools.jar / b lib`
- **D.** `local/lib java / b lib`

### Câu M2-23

Kết quả của chương trình là gì?

```java
public class Casts {
    interface Swimmer { }
    static class Fish implements Swimmer { }
    static class Dog { }

    public static void main(String[] args) {
        Fish f = new Fish();
        Swimmer s1 = f;
        Dog d = null;
        Swimmer s2 = (Swimmer) d;
        System.out.print((s2 == null) + " ");
        Swimmer s3 = (Swimmer) new Dog();
        System.out.print("done");
    }
}
```

- **A.** In ra `true` rồi ném `ClassCastException`
- **B.** Không biên dịch được ở dòng `(Swimmer) new Dog()`
- **C.** In ra `true done`
- **D.** Ném `NullPointerException` ở dòng `(Swimmer) d`

### Câu M2-24

Chèn đoạn nào vào chỗ `// INSERT CODE HERE` thì chương trình biên dịch được? **(Chọn 2 đáp án.)**

```java
public class Pat {
    static void m(Object o) {
        // INSERT CODE HERE
    }

    public static void main(String[] args) { m("x"); }
}
```

- **A.** `if (o instanceof String s && s.length() > 0) System.out.print(s);`
- **B.** `if (o instanceof String s || s.length() > 0) System.out.print(s);`
- **C.** `if (!(o instanceof String s)) return; System.out.print(s.length());`
- **D.** `if (o instanceof String s) { } System.out.print(s);`
- **E.** `boolean b = o instanceof Integer i && i > 0; System.out.print(i);`

### Câu M2-25

Chương trình sau in ra gì?

```java
import java.util.*;

public class ArraysView {
    public static void main(String[] args) {
        Integer[] arr = {5, 3, 9, 1};
        Arrays.sort(arr, Comparator.reverseOrder());
        List<Integer> view = Arrays.asList(arr);
        view.set(0, 7);
        Collections.reverse(view);
        System.out.println(Arrays.toString(arr) + " " + Arrays.binarySearch(arr, 5) + " " + view.indexOf(7));
    }
}
```

- **A.** `[9, 5, 3, 1] 1 0`
- **B.** `[1, 3, 5, 7] 2 3`
- **C.** `[1, 3, 5, 7] 2 0`
- **D.** `[7, 5, 3, 1] 1 0`

### Câu M2-26

Chương trình sau in ra gì?

```java
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.locks.ReentrantLock;

public class Try {
    public static void main(String[] args) throws Exception {
        ReentrantLock lock = new ReentrantLock();
        CountDownLatch held = new CountDownLatch(1), release = new CountDownLatch(1);
        Thread t = new Thread(() -> {
            lock.lock();
            try {
                held.countDown();
                release.await();
            } catch (InterruptedException e) {
            } finally {
                lock.unlock();
            }
        });
        t.start();
        held.await();
        boolean first = lock.tryLock();
        release.countDown();
        t.join();
        boolean second = lock.tryLock();
        System.out.println(first + " " + second + " " + lock.isHeldByCurrentThread() + " " + lock.getHoldCount());
    }
}
```

- **A.** `true true true 2`
- **B.** `false false false 0`
- **C.** `false true false 1`
- **D.** `false true true 1`

### Câu M2-27

Chương trình sau in ra gì?

```java
public class Str {
    public static void main(String[] args) {
        String s = "Hello, World";
        System.out.println(s.indexOf('o') + " " + s.lastIndexOf("o") + " " + s.substring(7).toUpperCase() + " "
                + s.replace('l', 'L').charAt(3) + " " + s.contains("world"));
    }
}
```

- **A.** `4 8 WORLD L false`
- **B.** `4 8 WORLD l false`
- **C.** `4 7 WORLD L true`
- **D.** `5 9 WORLD L false`

### Câu M2-28

Đoạn code nào, chèn vào chỗ `// INSERT CODE HERE`, in ra `[fig, kiwi, apple, banana]`? **(Chọn 3 đáp án.)**

```java
import java.util.*;

public class Sorts {
    public static void main(String[] args) {
        List<String> words = List.of("apple", "fig", "kiwi", "banana");
        // INSERT CODE HERE
    }
}
```

- **A.** `System.out.println(words.stream().sorted(Comparator.comparing(String::length).thenComparing(Comparator.naturalOrder())).toList());`
- **B.** `System.out.println(words.stream().sorted(Comparator.comparingInt(String::length)).toList());`
- **C.** `System.out.println(words.stream().sorted().toList());`
- **D.** `System.out.println(words.stream().sorted((a, b) -> b.length() - a.length()).toList());`
- **E.** `System.out.println(words.stream().sorted(Comparator.comparing(String::length, Comparator.reverseOrder()).reversed()).toList());`

### Câu M2-29

Những dòng nào gây lỗi biên dịch?

```java
public class Imm {
    static final class Money {
        private final long cents;
        private final String cur;

        Money(long cents, String cur) { this.cents = cents; this.cur = cur; }
        Money add(long c) { cents += c; return this; }                // L1
        Money plus(long c) { return new Money(cents + c, cur); }      // L2
        void rename(String c) { this.cur = c; }                       // L3
        String cur() { return cur; }                                  // L4
    }

    public static void main(String[] args) { }
}
```

- **A.** Chỉ L1
- **B.** Chỉ L3
- **C.** L1 và L3
- **D.** L1, L2 và L3
- **E.** Không dòng nào

### Câu M2-30

Locale mặc định là `en_US`. Chương trình sau in ra gì?

```java
import java.text.MessageFormat;
import java.util.Locale;

public class Msg {
    public static void main(String[] args) {
        String a = MessageFormat.format("{0} of {1} ({2,number,percent})", 3, 4, 0.75);
        String b = new MessageFormat("{0,number,#.#}|{0,number,integer}", Locale.US).format(new Object[]{2.55});
        System.out.println(a + " " + b);
    }
}
```

- **A.** `3 of 4 (0.75) 2.6|3`
- **B.** `3 of 4 (75%) 2.5|3`
- **C.** `3 of 4 (75%) 2.6|2`
- **D.** `{0} of {1} (75%) 2.5|3`

### Câu M2-31

Những dòng nào gây lỗi biên dịch?

```java
import java.io.*;

public class Impl {
    interface Loader { String load() throws IOException; }

    static class A implements Loader { public String load() { return "a"; } }                                 // L1
    static class B implements Loader { public String load() throws FileNotFoundException { return "b"; } }    // L2
    static class C implements Loader { public String load() throws Exception { return "c"; } }                // L3
    static class D implements Loader { String load() { return "d"; } }                                        // L4

    public static void main(String[] args) { new A().load(); }                                                 // L5
}
```

- **A.** L3 và L4
- **B.** Chỉ L3
- **C.** L3, L4 và L5
- **D.** L4 và L5
- **E.** L2 và L3

### Câu M2-32

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.stream.*;

public class Product {
    public static void main(String[] args) {
        List<List<Integer>> ll = List.of(List.of(1, 2, 3), List.of(3, 4), List.of(4, 5, 1));
        int product = ll.stream().flatMap(List::stream).distinct().reduce(1, (a, b) -> a * b);
        long dup = ll.stream().flatMap(List::stream).count() - ll.stream().flatMap(List::stream).distinct().count();
        System.out.println(product + " " + dup);
    }
}
```

- **A.** `1440 3`
- **B.** `120 8`
- **C.** `120 5`
- **D.** `120 3`

### Câu M2-33

Chương trình sau in ra gì?

```java
import java.io.IOException;
import java.nio.file.*;
import java.util.stream.Stream;

public class Depth {
    public static void main(String[] args) throws IOException {
        Path root = Path.of("t");
        Files.createDirectories(root.resolve("b/d"));
        Files.writeString(root.resolve("a.txt"), "1");
        Files.writeString(root.resolve("b/c.txt"), "2");
        Files.writeString(root.resolve("b/d/e.txt"), "3");
        Files.writeString(root.resolve("b/d/f.log"), "4");
        try (Stream<Path> f = Files.find(root, 2, (p, a) -> a.isRegularFile());
             Stream<Path> w = Files.walk(root, 2)) {
            System.out.println(f.map(p -> p.getFileName().toString()).sorted().toList() + " " + w.count());
        }
    }
}
```

- **A.** `[a.txt, c.txt, e.txt, f.log] 7`
- **B.** `[a.txt] 3`
- **C.** `[a.txt, c.txt] 5`
- **D.** `[a.txt, c.txt] 4`

### Câu M2-34

Chương trình sau in ra gì?

```java
public class Counter {
    static int total;
    int mine;

    Counter() { total++; mine++; }

    static Counter make() { return new Counter(); }

    public static void main(String[] args) {
        Counter a = new Counter();
        Counter b = make();
        Counter c = b;
        c.mine += 5;
        System.out.println(Counter.total + " " + a.mine + " " + b.mine + " " + a.total);
    }
}
```

- **A.** `3 1 6 3`
- **B.** `2 1 6 2`
- **C.** `2 1 1 2`
- **D.** `2 6 6 2`

### Câu M2-35

Module `com.run` (lớp chính `com.run.Main` in `run!`) đã được biên dịch vào `out/com.run`. Lệnh `jar` nào (thay cho `<LỆNH>`) tạo ra `mods/run.jar` để lệnh `java -p mods -m com.run` (không ghi tên lớp) chạy được? **(Chọn 2 đáp án.)**

- **A.** `jar --create --file mods/run.jar --main-class com.run.Main -C out/com.run .`
- **B.** `jar -c -f mods/run.jar -e com.run.Main -C out/com.run .`
- **C.** `jar --create --file mods/run.jar -C out/com.run .`
- **D.** `jar -cvf mods/run.jar -C out/com.run .`
- **E.** `jar --create --file mods/run.jar --main-class com.run.Main out/com.run`

### Câu M2-36

Hai phát biểu nào đúng về parallel stream? **(Chọn 2 đáp án.)**

- **A.** `forEachOrdered` trên parallel stream của một `List` xử lý phần tử theo thứ tự của list.
- **B.** `collect(Collectors.toList())` trên parallel stream của `List` trả về list theo thứ tự ngẫu nhiên.
- **C.** `isParallel()` trả về `false` sau khi gọi `.parallel().sequential()`.
- **D.** `reduce(0, (a, b) -> a - b)` trên parallel stream luôn cho cùng kết quả với tuần tự.
- **E.** Gọi `parallelStream()` trên list tạo bởi `List.of(...)` ném `UnsupportedOperationException`.

### Câu M2-37

Chương trình sau in ra gì?

```java
import java.time.*;
import java.time.temporal.TemporalAdjusters;

public class Periods {
    public static void main(String[] args) {
        LocalDate a = LocalDate.of(2023, 11, 30), b = LocalDate.of(2025, 2, 28);
        Period p = Period.between(a, b);
        System.out.println(p + " " + p.toTotalMonths() + " " + a.with(TemporalAdjusters.lastDayOfMonth()) + " "
                + a.withMonth(2));
    }
}
```

- **A.** `P1Y2M29D 14 2023-11-30 2023-02-28`
- **B.** `P1Y3M-2D 15 2023-11-30 2023-02-28`
- **C.** `P1Y2M28D 14 2023-11-30 2023-02-28`
- **D.** `P1Y2M29D 14 2023-11-30 2023-03-02`

### Câu M2-38

Chương trình sau in ra gì?

```java
public class Wins {
    interface Named {
        String name();
        default String greet() { return prefix() + name(); }
        private String prefix() { return "Hi "; }
    }

    static class Base { public String greet() { return "Base greet"; } }

    static class Person extends Base implements Named { public String name() { return "An"; } }

    static class Robot implements Named {
        public String name() { return "R2"; }
        public String greet() { return Named.super.greet() + "!"; }
    }

    public static void main(String[] args) {
        System.out.println(new Person().greet() + " | " + new Robot().greet());
    }
}
```

- **A.** `Hi An | Hi R2!`
- **B.** `Không biên dịch được: Person kế thừa hai greet()`
- **C.** `Hi An | Hi R2`
- **D.** `Base greet | Hi R2!`

### Câu M2-39

Chương trình sau in ra gì?

```java
public class Prop {
    static void a() {
        try { b(); } finally { System.out.print("a "); }
    }

    static void b() {
        try {
            throw new IllegalArgumentException("x");
        } catch (IllegalStateException e) {
            System.out.print("b-catch ");
        } finally {
            System.out.print("b ");
        }
    }

    public static void main(String[] args) {
        try { a(); } catch (RuntimeException e) { System.out.print("main:" + e.getMessage()); }
    }
}
```

- **A.** `b-catch b a main:x`
- **B.** `a b main:x`
- **C.** `b a main:x`
- **D.** `b a`

### Câu M2-40

Những dòng nào gây lỗi biên dịch?

```java
import java.util.*;

public class Gen2 {
    static double total(List<? extends Number> l) { double t = 0; for (Number n : l) t += n.doubleValue(); return t; }
    static void addAll(List<? super Integer> l) { l.add(1); }

    public static void main(String[] args) {
        total(new ArrayList<Integer>());                   // L1
        total(List.of(1.5, 2));                            // L2
        addAll(new ArrayList<Number>());                   // L3
        addAll(new ArrayList<Double>());                   // L4
        List<? extends Number> x = List.of(1); x.add(2);   // L5
    }
}
```

- **A.** Chỉ L4
- **B.** L4 và L5
- **C.** L2 và L4
- **D.** L2, L4 và L5
- **E.** Chỉ L5

### Câu M2-41

Bundle: `Msg.properties` (`t=Root`), `Msg_en.properties` (`t=English`), `Msg_en_US.properties` (`t=American`). Locale mặc định là `fr_FR`. Chương trình in ra gì?

`Msg.properties`

```text
t=Root
```

`Msg_en.properties`

```text
t=English
```

`Msg_en_US.properties`

```text
t=American
```

`Main.java`

```java
import java.util.*;
public class Main {
    public static void main(String[] args) {
        Locale.setDefault(Locale.FRANCE);
        ResourceBundle rb = ResourceBundle.getBundle("Msg", Locale.UK);
        System.out.println(rb.getString("t") + " " + rb.getLocale());
    }
}
```

- **A.** `English en`
- **B.** `American en_US`
- **C.** `Root` (locale rỗng)
- **D.** Ném `MissingResourceException`

### Câu M2-42

Chèn nhóm case nào vào chỗ `// INSERT CODE HERE` thì chương trình biên dịch được? **(Chọn 2 đáp án.)**

```java
public class NullCase {
    static String t(Object o) {
        return switch (o) {
            // INSERT CODE HERE
        };
    }

    public static void main(String[] args) { System.out.println(t(null)); }
}
```

- **A.** `case null, default -> "N/D"; case Integer i -> "int";`
- **B.** `case Integer i when i < 0 -> "neg"; case Integer i -> "int"; case null, default -> "N/D";`
- **C.** `case null -> "N"; case Integer i -> "int"; default -> "D";`
- **D.** `case Integer i -> "int"; case Integer i when i < 0 -> "neg"; default -> "D";`
- **E.** `case Integer i -> "int"; case null -> "N";`

### Câu M2-43

Chương trình sau in ra gì?

```java
public class Template {
    abstract static class Report {
        final String title;
        Report(String t) {
            title = t;
            System.out.print(header() + " ");
        }
        abstract String body();
        String header() { return "[" + title + "]"; }
        final String render() { return header() + body(); }
    }

    static class Sales extends Report {
        int total = 5;
        Sales() { super("sales"); }
        String body() { return ":" + total; }
        @Override String header() { return "<" + title + ">"; }
    }

    public static void main(String[] args) {
        System.out.println(new Sales().render());
    }
}
```

- **A.** `[sales] <sales>:5`
- **B.** `<sales> <sales>:5`
- **C.** `<sales> <sales>:0`
- **D.** `<null> <sales>:5`

### Câu M2-44

Những dòng nào gây lỗi biên dịch?

```java
import java.util.*;
import java.util.stream.*;

public class Api {
    public static void main(String[] args) {
        List<String> l = List.of("a", "bb");
        int a = l.stream().mapToInt(String::length).sum();                  // L1
        double b = l.stream().mapToInt(String::length).average();           // L2
        long c = l.stream().count();                                        // L3
        int d = l.stream().map(String::length).max(Integer::compare);       // L4
        Optional<String> e = l.stream().findFirst();                        // L5
    }
}
```

- **A.** Chỉ L2
- **B.** Chỉ L4
- **C.** L2, L4 và L5
- **D.** L2 và L4
- **E.** L3 và L4

### Câu M2-45

Chương trình sau in ra gì?

```java
public class Stop {
    public static void main(String[] args) throws InterruptedException {
        Thread t = new Thread(() -> {
            while (!Thread.currentThread().isInterrupted()) {
                Thread.onSpinWait();
            }
            System.out.print("stopped ");
        });
        t.start();
        t.interrupt();
        t.join();
        System.out.println(t.getState());
    }
}
```

- **A.** `stopped TERMINATED`
- **B.** `TERMINATED`
- **C.** Chương trình chạy mãi không dừng
- **D.** `stopped RUNNABLE`

### Câu M2-46

File nguồn lưu bằng UTF-8. Chương trình sau in ra gì?

```java
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;

public class Count {
    public static void main(String[] args) throws IOException {
        Files.writeString(Path.of("u.txt"), "hé");
        try (InputStream in = new FileInputStream("u.txt");
             Reader r = new FileReader("u.txt", StandardCharsets.UTF_8)) {
            int bytes = 0, chars = 0;
            while (in.read() != -1) bytes++;
            while (r.read() != -1) chars++;
            System.out.println(bytes + " " + chars);
        }
    }
}
```

- **A.** `2 2`
- **B.** `3 3`
- **C.** `2 3`
- **D.** `3 2`

### Câu M2-47

Khai báo method nào, chèn vào chỗ `// INSERT CODE HERE`, biên dịch được? **(Chọn 2 đáp án.)**

```java
public class Varargs {
    // INSERT CODE HERE

    public static void main(String[] args) { }
}
```

- **A.** `static void m(int... a, String s) { }`
- **B.** `static void m(String s, int... a) { }`
- **C.** `static void m(int... a, int... b) { }`
- **D.** `static void m(int[]... a) { }`
- **E.** `static void m(int a...) { }`

### Câu M2-48

Chương trình sau in ra gì?

```java
import java.util.*;

public class Wrap {
    public static void main(String[] args) {
        List<Integer> l = new ArrayList<>(List.of(10, 20, 30));
        l.remove(Integer.valueOf(20));
        l.add(1, 99);
        int sum = 0;
        for (int x : l) sum += x;
        Integer big1 = 1000, big2 = 1000;
        System.out.println(l + " " + sum + " " + big1.equals(big2) + " " + (big1 == 1000));
    }
}
```

- **A.** `[10, 99, 30] 139 true false`
- **B.** `[99, 10, 30] 139 true true`
- **C.** `[10, 99, 30] 139 true true`
- **D.** `[10, 20, 99, 30] 159 true true`

### Câu M2-49

Lớp provider dưới đây không có constructor public không tham số và cũng không có method `public static provider()`. Điều gì xảy ra khi biên dịch các module?

`src/com.api/module-info.java`

```java
module com.api { exports com.api; }
```

`src/com.api/com/api/Codec.java`

```java
package com.api;
public interface Codec { String name(); }
```

`src/com.impl/module-info.java`

```java
module com.impl {
    requires com.api;
    provides com.api.Codec with com.impl.Gzip;
}
```

`src/com.impl/com/impl/Gzip.java`

```java
package com.impl;
public class Gzip implements com.api.Codec {
    private final int level;
    public Gzip(int level) { this.level = level; }
    public String name() { return "gzip" + level; }
}
```

- **A.** Biên dịch thành công; `ServiceLoader` tạo provider bằng `Gzip(0)`
- **B.** Biên dịch thành công nhưng lúc chạy `ServiceLoader` bỏ qua provider này
- **C.** Lỗi biên dịch: lớp cài đặt service không có constructor mặc định (public, không tham số)
- **D.** Biên dịch thành công nhưng ném `ServiceConfigurationError` khi module được nạp

### Câu M2-50

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.stream.*;

public class Words {
    public static void main(String[] args) {
        List<String> words = List.of("sun", "sea", "sky", "moon", "mars", "star");
        Map<Character, String> m = words.stream().collect(Collectors.groupingBy(w -> w.charAt(0), TreeMap::new,
                Collectors.mapping(String::toUpperCase, Collectors.joining("/"))));
        Map<Integer, Long> byLen = words.stream().collect(
                Collectors.groupingBy(String::length, TreeMap::new, Collectors.counting()));
        System.out.println(m + " " + byLen);
    }
}
```

- **A.** `{s=SUN/SEA/SKY/STAR, m=MOON/MARS} {3=3, 4=3}`
- **B.** `{m=MOON/MARS, s=SUN/SEA/SKY/STAR} {3=3, 4=3}`
- **C.** `{m=MOON/MARS, s=SUN/SEA/SKY/STAR} {3=4, 4=2}`
- **D.** `{m=[MOON, MARS], s=[SUN, SEA, SKY, STAR]} {3=3, 4=3}`

## Nguồn tham khảo (Sources)

Câu hỏi tự viết; đáp án kiểm chứng bằng OpenJDK 21.0.10 (`examples/questions/mock2/`). Thông tin kỳ thi: DECISION.md (**UNVERIFIED**).
