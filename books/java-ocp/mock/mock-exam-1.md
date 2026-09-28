# Đề thi thử số 1 — 1Z0-830 (Java SE 21)

**Thời gian: 120 phút · 50 câu · Đậu: ≥ 34 câu đúng (68%).** Làm như thi thật: không IDE, không tra cứu, bấm giờ.
Câu "chọn N đáp án" chỉ tính điểm khi chọn đúng đủ N đáp án. Mọi câu hỏi đều tự viết và đã được biên dịch/chạy
bằng JDK 21.0.10 để xác nhận đáp án (code: `examples/questions/mock1/`).

Đáp án và giải thích: [mock-exam-1-answers.md](mock-exam-1-answers.md)

### Câu M1-01

Chương trình sau in ra gì?

```java
class A {
    void m(Object o) { System.out.print("AO "); }
    void m(String s) { System.out.print("AS "); }
}

class B extends A {
    @Override void m(Object o) { System.out.print("BO "); }
}

public class Mix {
    public static void main(String[] args) {
        A a = new B();
        Object o = "x";
        a.m(o);
        a.m("x");
        a.m(null);
    }
}
```

- **A.** `BO BO BO`
- **B.** `AO AS AS`
- **C.** `BO AS BO`
- **D.** `BO AS AS`

### Câu M1-02

Chương trình sau in ra gì?

```java
public class Expr {
    public static void main(String[] args) {
        int x = 10;
        long y = x++ + ++x * 2L;
        double z = y / 4;
        System.out.println(x + " " + y + " " + z);
    }
}
```

- **A.** `12 34 8.0`
- **B.** `12 34 8.5`
- **C.** `11 34 8.0`
- **D.** `12 32 8.0`

### Câu M1-03

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.stream.*;

public class Chars {
    public static void main(String[] args) {
        String r = Stream.of("delta", "alpha", "charlie", "bravo")
                .filter(s -> s.length() == 5)
                .map(s -> s.charAt(0))
                .sorted(Comparator.reverseOrder())
                .map(String::valueOf)
                .collect(Collectors.joining());
        System.out.println(r);
    }
}
```

- **A.** `dab`
- **B.** `abd`
- **C.** `dba`
- **D.** `dbac`

### Câu M1-04

Chương trình sau in ra gì?

```java
public class Shapes {
    sealed interface Shape permits Circle, Rect { }
    record Circle(double r) implements Shape { }
    record Rect(double w, double h) implements Shape { }

    static String kind(Shape s) {
        return switch (s) {
            case Circle c when c.r() > 10 -> "big circle";
            case Circle c -> "circle";
            case Rect(double w, double h) when w == h -> "square";
            case Rect r -> "rect";
        };
    }

    public static void main(String[] args) {
        System.out.println(kind(new Circle(5)) + ", " + kind(new Rect(2, 2)) + ", "
                + kind(new Circle(11)) + ", " + kind(new Rect(1, 3)));
    }
}
```

- **A.** `circle, rect, big circle, rect`
- **B.** `circle, square, big circle, rect`
- **C.** Không biên dịch được: switch thiếu `default`
- **D.** `circle, square, circle, rect`

### Câu M1-05

Chương trình sau in ra gì?

```java
public class Order {
    static int s = print("s1");
    int i = print("i1");
    static { print("sb"); }
    { print("ib"); }
    Order() { print("c"); }

    static int print(String t) {
        System.out.print(t + " ");
        return 0;
    }

    public static void main(String[] args) {
        print("main");
        new Order();
        new Order();
    }
}
```

- **A.** `main s1 sb i1 ib c i1 ib c`
- **B.** `s1 sb main i1 ib c`
- **C.** `s1 sb main ib i1 c ib i1 c`
- **D.** `s1 sb main i1 ib c i1 ib c`

### Câu M1-06

Chương trình sau in ra gì?

```java
import java.util.*;

public class Group {
    public static void main(String[] args) {
        Map<String, List<Integer>> m = new TreeMap<>();
        for (String w : "b1 a2 b3 c4 a5".split(" "))
            m.computeIfAbsent(w.substring(0, 1), k -> new ArrayList<>()).add(Integer.parseInt(w.substring(1)));
        System.out.println(m + " " + m.getOrDefault("z", List.of()).size());
    }
}
```

- **A.** `{a=[2, 5], b=[1, 3], c=[4]} 0`
- **B.** `{b=[1, 3], a=[2, 5], c=[4]} 0`
- **C.** `{a=[5], b=[3], c=[4]} 0`
- **D.** `{a=[2, 5], b=[1, 3], c=[4]} null`

### Câu M1-07

Chương trình sau in ra gì?

```java
public class Fin {
    static String test(int n) {
        StringBuilder sb = new StringBuilder();
        try {
            sb.append("t");
            if (n == 0) throw new IllegalStateException();
            sb.append("u");
            return sb.append("r").toString();
        } catch (IllegalStateException e) {
            sb.append("c");
            return sb.toString();
        } finally {
            sb.append("f");
        }
    }

    public static void main(String[] args) {
        System.out.println(test(1) + " " + test(0));
    }
}
```

- **A.** `turf tcf`
- **B.** `turf tc`
- **C.** `tur tc`
- **D.** `tu tc`

### Câu M1-08

Những dòng nào gây lỗi biên dịch?

```java
public class Conflict {
    interface Walk { default String go() { return "walk"; } }
    interface Run { default String go() { return "run"; } }
    interface Fly { String go(); }

    static class A implements Walk, Run { }                                                   // L1
    static class B implements Walk, Run { public String go() { return Walk.super.go(); } }   // L2
    static abstract class C implements Walk, Fly { }                                          // L3
    static class D implements Fly { public String go() { return "d"; } }                      // L4
    static class E implements Walk { public String go() { return "e" + Walk.super.go(); } }  // L5

    public static void main(String[] args) { }
}
```

- **A.** Chỉ L1
- **B.** L1 và L3
- **C.** L1, L3 và L5
- **D.** L3 và L5
- **E.** L1 và L2

### Câu M1-09

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.concurrent.*;

public class Exec {
    public static void main(String[] args) throws Exception {
        ExecutorService ex = Executors.newFixedThreadPool(2);
        Future<String> f1 = ex.submit(() -> "A");
        Future<?> f2 = ex.submit(() -> { });
        List<Future<Integer>> fs = ex.invokeAll(List.of(() -> 1, () -> 2));
        ex.shutdown();
        System.out.println(f1.get() + f2.get() + fs.get(1).get() + ex.isShutdown());
    }
}
```

- **A.** `A2true`
- **B.** `Anull1true`
- **C.** `Anull2false`
- **D.** `Anull2true`

### Câu M1-10

Chương trình sau in ra gì?

```java
public class Sb {
    public static void main(String[] args) {
        String s = "Java";
        StringBuilder sb = new StringBuilder(s);
        s.concat("21");
        sb.append(21).insert(0, s.toLowerCase()).reverse();
        System.out.println(s + " " + sb + " " + sb.length());
    }
}
```

- **A.** `Java 12avaJavaj 10`
- **B.** `Java21 12avaJavaj 10`
- **C.** `Java 12avaJava 9`
- **D.** `Java javaJava21 10`

### Câu M1-11

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.stream.*;

public class Oldest {
    record P(String name, String city, int age) { }

    public static void main(String[] args) {
        List<P> ps = List.of(new P("An", "HN", 30), new P("Binh", "HCM", 25), new P("Chi", "HN", 22),
                new P("Dung", "HCM", 40), new P("Em", "DN", 35));
        Map<String, Optional<P>> oldest = ps.stream().collect(Collectors.groupingBy(
                P::city, TreeMap::new, Collectors.maxBy(Comparator.comparingInt(P::age))));
        oldest.forEach((k, v) -> System.out.print(k + "=" + v.map(P::name).orElse("-") + " "));
    }
}
```

- **A.** `HN=An HCM=Dung DN=Em`
- **B.** `DN=Em HCM=Binh HN=Chi`
- **C.** `DN=Em HCM=Dung HN=An`
- **D.** `DN=Optional[Em] HCM=Optional[Dung] HN=Optional[An]`

### Câu M1-12

Chèn đoạn nào vào chỗ `// INSERT CODE HERE` thì chương trình biên dịch được? **(Chọn 2 đáp án.)**

```java
public class Scope {
    int field = 1;

    void m() {
        // INSERT CODE HERE
    }

    public static void main(String[] args) { }
}
```

- **A.** `var list = java.util.List.of(1, 2); for (var i : list) System.out.print(i);`
- **B.** `var x = 1; x = "one";`
- **C.** `int field = field + 1;`
- **D.** `final var y = 3; int z = y * 2;`
- **E.** `var arr[] = new int[3];`

### Câu M1-13

Chương trình sau in ra gì?

```java
import java.nio.file.*;

public class Paths1 {
    public static void main(String[] args) {
        Path base = Path.of("/app/config");
        Path p = base.resolve("../logs/./app.log").normalize();
        System.out.println(p + " " + p.getNameCount() + " " + base.relativize(p) + " " + p.startsWith("/app"));
    }
}
```

- **A.** `/app/config/../logs/app.log 5 ../logs/app.log true`
- **B.** `/app/logs/app.log 3 ../logs/app.log true`
- **C.** `/app/logs/app.log 3 logs/app.log true`
- **D.** `/app/logs/app.log 2 ../logs/app.log false`

### Câu M1-14

Chương trình sau in ra gì?

```java
public class Loop {
    public static void main(String[] args) {
        int sum = 0;
        for (int i = 0; i < 10; i++) {
            if (i % 3 == 0) continue;
            if (i > 7) break;
            sum += i;
        }
        System.out.println(sum);
    }
}
```

- **A.** `27`
- **B.** `12`
- **C.** `25`
- **D.** `19`

### Câu M1-15

Kết quả của chương trình là gì?

```java
import java.util.*;

public class SubList {
    public static void main(String[] args) {
        List<Integer> base = new ArrayList<>(List.of(1, 2, 3, 4, 5));
        List<Integer> sub = base.subList(1, 4);
        sub.remove(Integer.valueOf(3));
        sub.add(9);
        base.set(0, 0);
        System.out.println(base + " " + sub);
    }
}
```

- **A.** In ra `[0, 2, 4, 9, 5] [2, 4, 9]`
- **B.** In ra `[0, 2, 3, 4, 5] [2, 4, 9]`
- **C.** In ra `[0, 2, 4, 5, 9] [2, 4, 9]`
- **D.** Ném `ConcurrentModificationException`

### Câu M1-16

Chương trình sau in ra gì?

```java
public class Outer {
    private int x = 1;

    class Inner {
        private int x = 2;
        int sum(int x) { return x + this.x + Outer.this.x; }
    }

    static class Nested {
        int get() { return new Outer().x; }
    }

    public static void main(String[] args) {
        Outer o = new Outer();
        o.x = 10;
        Outer.Inner in = o.new Inner();
        System.out.println(in.sum(100) + " " + new Nested().get());
    }
}
```

- **A.** `103 1`
- **B.** `112 10`
- **C.** `112 1`
- **D.** `103 10`

### Câu M1-17

Module `com.app` có `requires static com.opt;`. Cả hai module được biên dịch, nhưng khi chạy chỉ đưa `com.app` lên module path. Điều gì xảy ra?

`src/com.opt/module-info.java`

```java
module com.opt { exports com.opt; }
```

`src/com.opt/com/opt/Extra.java`

```java
package com.opt;
public class Extra { public static String hi() { return "extra"; } }
```

`src/com.app/module-info.java`

```java
module com.app {
    requires static com.opt;
}
```

`src/com.app/com/app/Main.java`

```java
package com.app;
public class Main {
    public static void main(String[] args) {
        boolean present = ModuleLayer.boot().findModule("com.opt").isPresent();
        System.out.println(present ? com.opt.Extra.hi() : "optional absent");
    }
}
```

- **A.** Không biên dịch được
- **B.** JVM không khởi động: `FindException` vì thiếu `com.opt`
- **C.** Ném `NoClassDefFoundError` ngay khi khởi động
- **D.** Chạy bình thường và in ra `optional absent`

### Câu M1-18

Chương trình sau in ra gì?

```java
import java.time.*;
import java.time.temporal.ChronoUnit;

public class Dates {
    public static void main(String[] args) {
        LocalDate d = LocalDate.of(2024, 1, 31);
        Period p = Period.ofMonths(1).plusDays(1);
        System.out.println(d.plus(p) + " " + d.plusDays(1).plusMonths(1) + " "
                + ChronoUnit.MONTHS.between(d, d.plus(p)));
    }
}
```

- **A.** `2024-03-02 2024-03-01 1`
- **B.** `2024-03-01 2024-03-01 2`
- **C.** `2024-02-29 2024-03-01 1`
- **D.** `2024-03-01 2024-03-01 1`

### Câu M1-19

Đoạn code nào, chèn vào chỗ `// INSERT CODE HERE`, in ra `[2, 4, 6]`? **(Chọn 3 đáp án.)**

```java
import java.util.*;
import java.util.stream.*;

public class Evens {
    public static void main(String[] args) {
        // INSERT CODE HERE
    }
}
```

- **A.** `System.out.println(IntStream.rangeClosed(1, 3).map(i -> i * 2).boxed().toList());`
- **B.** `System.out.println(Stream.iterate(2, i -> i <= 6, i -> i + 2).toList());`
- **C.** `System.out.println(IntStream.range(1, 3).map(i -> i * 2).boxed().toList());`
- **D.** `System.out.println(Stream.of(1, 2, 3).map(i -> i * 2).collect(Collectors.toList()));`
- **E.** `System.out.println(IntStream.of(1, 2, 3).map(i -> i * 2).toList());`

### Câu M1-20

Những dòng nào gây lỗi biên dịch?

```java
public class Hier {
    sealed interface Vehicle permits Car, Bike, Truck { }
    record Car(int seats) implements Vehicle { }                // L1
    static final class Bike implements Vehicle { }             // L2
    static non-sealed class Truck implements Vehicle { }        // L3
    static class BigTruck extends Truck { }                     // L4
    record Boat() extends Car { }                               // L5
    static class Scooter extends Bike { }                       // L6

    public static void main(String[] args) { }
}
```

- **A.** L5 và L6
- **B.** Chỉ L5
- **C.** L4 và L6
- **D.** L3, L5 và L6
- **E.** Chỉ L6

### Câu M1-21

Chương trình sau in ra gì?

```java
public class Twr {
    static class R implements AutoCloseable {
        final String n;
        R(String n) { this.n = n; }
        public void close() {
            System.out.print("close" + n + " ");
            throw new RuntimeException("c" + n);
        }
    }

    public static void main(String[] args) {
        try (R a = new R("A"); R b = new R("B")) {
            throw new IllegalStateException("body");
        } catch (Exception e) {
            System.out.print(e.getMessage() + " " + e.getSuppressed().length + " " + e.getSuppressed()[0].getMessage());
        }
    }
}
```

- **A.** `closeA closeB body 2 cA`
- **B.** `closeB closeA cA 1 body`
- **C.** `closeB closeA body 2 cB`
- **D.** `closeB closeA body 1 cB`

### Câu M1-22

Chương trình sau in ra gì?

```java
import java.text.NumberFormat;
import java.util.Locale;

public class Pct {
    public static void main(String[] args) {
        NumberFormat f = NumberFormat.getPercentInstance(Locale.US);
        f.setMinimumFractionDigits(1);
        NumberFormat c = NumberFormat.getCurrencyInstance(Locale.US);
        System.out.println(f.format(0.4567) + " " + c.format(0.125) + " " + c.format(0.135));
    }
}
```

- **A.** `45.67% $0.13 $0.14`
- **B.** `45.7% $0.12 $0.14`
- **C.** `45.7% $0.13 $0.13`
- **D.** `46% $0.12 $0.14`

### Câu M1-23

Chương trình sau in ra gì?

```java
public class Over {
    static String f(long a, long b) { return "LL"; }
    static String f(Integer... a) { return "I..."; }
    static String f(Object a, Object b) { return "OO"; }

    public static void main(String[] args) {
        System.out.println(f(1, 2) + " " + f(1) + " " + f(1L, 2) + " " + f("a", 1));
    }
}
```

- **A.** `OO I... LL OO`
- **B.** `LL I... OO OO`
- **C.** `I... I... LL OO`
- **D.** `LL I... LL OO`

### Câu M1-24

Điều gì đúng về output của chương trình?

```java
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

public class Count {
    public static void main(String[] args) {
        AtomicInteger ai = new AtomicInteger();
        try (var ex = Executors.newFixedThreadPool(4)) {
            for (int i = 0; i < 1000; i++) ex.submit(ai::incrementAndGet);
        }
        System.out.println(ai.get() + " " + ai.getAndSet(0) + " " + ai.get());
    }
}
```

- **A.** Luôn in `1000 1000 0`
- **B.** In một số ≤ 1000, thay đổi mỗi lần chạy
- **C.** Luôn in `1000 0 0`
- **D.** In `0 0 0` vì chưa đợi các task chạy xong

### Câu M1-25

Những dòng nào gây lỗi biên dịch?

```java
public class Sw {
    enum Level { LOW, MID, HIGH }

    static int a(Level l) { return switch (l) { case LOW -> 1; case MID -> 2; case HIGH -> 3; }; }   // L1
    static int b(Level l) { return switch (l) { case LOW -> 1; case MID -> 2; }; }                   // L2
    static int c(String s) { return switch (s) { case "a": yield 1; default: yield 0; }; }          // L3
    static int d(int n) { return switch (n) { case 1 -> 1; case 1 -> 2; default -> 0; }; }          // L4
    static int e(Object o) { return switch (o) { case String t -> 1; default -> 0; }; }             // L5

    public static void main(String[] args) { }
}
```

- **A.** Chỉ L2
- **B.** L4 và L5
- **C.** L2 và L4
- **D.** L2, L4 và L5
- **E.** L3 và L4

### Câu M1-26

Chương trình sau in ra gì?

```java
import java.util.*;

public class Dq {
    public static void main(String[] args) {
        Deque<String> d = new ArrayDeque<>(List.of("b", "c"));
        d.offerFirst("a");
        d.push("z");
        d.offerLast("d");
        System.out.println(d.pollLast() + d.pop() + d.peekFirst() + d.size());
    }
}
```

- **A.** `zda3`
- **B.** `dza3`
- **C.** `dza4`
- **D.** `daz3`

### Câu M1-27

Chương trình sau in ra gì?

```java
import java.util.Optional;

public class Opt {
    public static void main(String[] args) {
        Optional<String> o = Optional.of("  ");
        String r = o.map(String::strip).filter(s -> !s.isEmpty()).map(String::toUpperCase).orElseGet(() -> "EMPTY");
        System.out.println(r + " " + Optional.ofNullable(null).isPresent() + " "
                + Optional.of("x").or(() -> Optional.of("y")).get());
    }
}
```

- **A.** `EMPTY true y`
- **B.** `EMPTY false y`
- **C.** `  false x`
- **D.** `EMPTY false x`

### Câu M1-28

Chương trình sau in ra gì?

```java
public class Ops {
    enum Op {
        PLUS("+") { int apply(int a, int b) { return a + b; } },
        TIMES("*") { int apply(int a, int b) { return a * b; } };

        final String sym;
        Op(String s) { sym = s; }
        abstract int apply(int a, int b);
    }

    public static void main(String[] args) {
        for (Op op : Op.values()) System.out.print(op + op.sym + op.apply(3, 4) + op.ordinal() + " ");
    }
}
```

- **A.** `PLUS+70 TIMES*121`
- **B.** `PLUS+71 TIMES*122`
- **C.** `+70 *121`
- **D.** `PLUS+7 TIMES*12`

### Câu M1-29

Chèn dòng nào vào chỗ `// INSERT CODE HERE` thì chương trình biên dịch được? **(Chọn 2 đáp án.)**

```java
public class Lits {
    public static void main(String[] args) {
        // INSERT CODE HERE
    }
}
```

- **A.** `Integer i = 10L;`
- **B.** `long l = 10;`
- **C.** `Double d = 5;`
- **D.** `char c = 'a' + 1;`
- **E.** `short s = 40000;`

### Câu M1-30

Chương trình sau in ra gì?

```java
import java.io.*;
import java.nio.file.*;
import java.util.List;

public class Pw {
    public static void main(String[] args) throws IOException {
        try (PrintWriter pw = new PrintWriter(Files.newBufferedWriter(Path.of("o.txt")))) {
            pw.print("a");
            pw.println("b");
            pw.printf("%d-%s%n", 1, "c");
            pw.print("d");
        }
        List<String> lines = Files.readAllLines(Path.of("o.txt"));
        System.out.println(lines.size() + " " + lines);
    }
}
```

- **A.** `4 [a, b, 1-c, d]`
- **B.** `2 [ab, 1-c]`
- **C.** `3 [ab, 1-c, d]`
- **D.** `3 [ab, 1-c, d, ]`

### Câu M1-31

Những dòng nào gây lỗi biên dịch?

```java
import java.io.*;

public class Catch {
    static void io() throws IOException { }

    public static void main(String[] args) {
        try { io(); } catch (FileNotFoundException | IOException e) { }         // L1
        try { io(); } catch (IOException | RuntimeException e) { }             // L2
        try { io(); } catch (Exception e) { } catch (IOException e) { }        // L3
        try { io(); } catch (IOException e) { throw new RuntimeException(e); } // L4
    }
}
```

- **A.** Chỉ L1
- **B.** L1 và L3
- **C.** L2 và L3
- **D.** Chỉ L3
- **E.** L1, L3 và L4

### Câu M1-32

Chương trình sau in ra gì?

```java
public class Nums {
    public static void main(String[] args) {
        Object[] items = {1, "two", 3.0, 'c', 4L};
        int n = 0;
        for (Object o : items)
            if (o instanceof Number num && num.intValue() > 1) n += num.intValue();
        System.out.println(n);
    }
}
```

- **A.** `8`
- **B.** `10`
- **C.** `107`
- **D.** `7`

### Câu M1-33

Điều gì đúng về output của chương trình?

```java
import java.util.*;
import java.util.concurrent.*;

public class VFutures {
    public static void main(String[] args) throws Exception {
        List<Future<String>> fs = new ArrayList<>();
        try (var ex = Executors.newVirtualThreadPerTaskExecutor()) {
            for (String s : List.of("x", "y", "z"))
                fs.add(ex.submit(() -> {
                    Thread.sleep(s.equals("x") ? 100 : 10);
                    return s.toUpperCase();
                }));
        }
        StringBuilder sb = new StringBuilder();
        for (Future<String> f : fs) sb.append(f.get()).append(f.isDone() ? "+" : "-");
        System.out.println(sb);
    }
}
```

- **A.** Luôn in `X+Y+Z+`
- **B.** Luôn in `Y+Z+X+`
- **C.** Thứ tự chữ cái không xác định
- **D.** Không biên dịch được vì `s` không effectively final

### Câu M1-34

Chương trình sau in ra gì?

```java
public class Div {
    public static void main(String[] args) {
        double d = -7.5;
        System.out.println(Math.round(d) + " " + (int) d + " " + Math.floorDiv(-7, 2) + " "
                + (-7 / 2) + " " + (-7 % 2) + " " + Math.floorMod(-7, 2));
    }
}
```

- **A.** `-8 -7 -4 -3 -1 1`
- **B.** `-7 -8 -4 -4 -1 1`
- **C.** `-7 -7 -4 -3 -1 1`
- **D.** `-7 -7 -3 -3 -1 -1`

### Câu M1-35

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.stream.*;

public class Concat {
    public static void main(String[] args) {
        List<String> a = List.of("x,y", "z");
        List<String> b = List.of("y,w");
        String r = Stream.concat(a.stream(), b.stream())
                .flatMap(s -> Arrays.stream(s.split(",")))
                .distinct().sorted().reduce("", String::concat);
        System.out.println(r);
    }
}
```

- **A.** `xyzw`
- **B.** `wxyz`
- **C.** `wxyyz`
- **D.** `xyzyw`

### Câu M1-36

Những dòng nào gây lỗi biên dịch?

```java
public class Ctor {
    static class Base { Base(int x) { } }
    static class A extends Base { A() { super(1); } }          // L1
    static class B extends Base { B() { } }                    // L2
    static class C extends Base { C(int x) { super(x); } }     // L3
    static class D extends Base { }                            // L4
    static class E { final int v; E() { } }                    // L5

    public static void main(String[] args) { }
}
```

- **A.** L2 và L4
- **B.** L2 và L5
- **C.** L4 và L5
- **D.** L2, L4 và L5
- **E.** Chỉ L2

### Câu M1-37

File `commons-text-1.10.0.jar` không có `module-info.class`, nhưng MANIFEST có `Automatic-Module-Name: org.apache.commons.text`. Module khác phải `requires` tên nào?

`lib/org/apache/commons/text/Words.java`

```java
package org.apache.commons.text;
public class Words { }
```

`manifest.txt`

```text
Automatic-Module-Name: org.apache.commons.text
```

- **A.** `org.apache.commons.text`
- **B.** `commons.text`
- **C.** `commons-text`
- **D.** `commons.text.1.10.0`

### Câu M1-38

Chương trình sau in ra gì?

```java
import java.util.*;

public class Nulls {
    public static void main(String[] args) {
        List<String> l = new ArrayList<>(Arrays.asList("pear", null, "Fig", "apple"));
        l.sort(Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER));
        System.out.print(l + " ");
        l.sort(Comparator.nullsFirst(Comparator.<String>naturalOrder().reversed()));
        System.out.println(l);
    }
}
```

- **A.** `[apple, Fig, pear, null] [null, pear, Fig, apple]`
- **B.** `[Fig, apple, pear, null] [null, pear, apple, Fig]`
- **C.** `[apple, Fig, pear, null] [null, pear, apple, Fig]`
- **D.** Ném `NullPointerException`

### Câu M1-39

Chương trình sau in ra gì?

```java
public class Chain {
    @FunctionalInterface
    interface Calc {
        int calc(int x);
        default Calc then(Calc next) { return x -> next.calc(calc(x)); }
        static Calc id() { return x -> x; }
    }

    public static void main(String[] args) {
        Calc inc = x -> x + 1;
        Calc dbl = x -> x * 2;
        System.out.println(inc.then(dbl).calc(5) + " " + dbl.then(inc).calc(5) + " " + Calc.id().then(inc).calc(0));
    }
}
```

- **A.** `11 12 1`
- **B.** `12 11 1`
- **C.** `12 11 0`
- **D.** `12 12 1`

### Câu M1-40

Chương trình sau in ra gì?

```java
public class Labeled {
    public static void main(String[] args) {
        int count = 0;
        outer:
        do {
            for (int i = 0; i < 5; i++) {
                count++;
                if (count % 4 == 0) continue outer;
                if (count > 9) break outer;
            }
        } while (count < 20);
        System.out.println(count);
    }
}
```

- **A.** `12`
- **B.** `20`
- **C.** `9`
- **D.** `10`

### Câu M1-41

Bundle: `App.properties` (`hi=Hi`, `bye=Bye`), `App_de.properties` (`hi=Hallo`), `App_fr.properties` (`hi=Salut`, `bye=Au revoir`). Locale mặc định là `fr_FR`. Chương trình in ra gì?

`App.properties`

```text
hi=Hi
bye=Bye
```

`App_de.properties`

```text
hi=Hallo
```

`App_fr.properties`

```text
hi=Salut
bye=Au revoir
```

`Main.java`

```java
import java.util.*;
public class Main {
    public static void main(String[] args) {
        Locale.setDefault(Locale.FRANCE);
        ResourceBundle rb = ResourceBundle.getBundle("App", Locale.of("de", "CH"));
        System.out.println(rb.getString("hi") + " " + rb.getString("bye"));
    }
}
```

- **A.** `Hallo Bye`
- **B.** `Hallo Au revoir`
- **C.** `Salut Au revoir`
- **D.** Ném `MissingResourceException`

### Câu M1-42

Chương trình sau in ra gì?

```java
import java.util.*;

public class Views {
    public static void main(String[] args) {
        final List<String> names = new ArrayList<>(List.of("a"));
        List<String> view = Collections.unmodifiableList(names);
        names.add("b");
        record Team(List<String> members) {
            Team { members = List.copyOf(members); }
        }
        Team t = new Team(names);
        names.add("c");
        System.out.println(view.size() + " " + t.members().size() + " " + names.size());
    }
}
```

- **A.** `2 2 3`
- **B.** `3 3 3`
- **C.** `3 2 3`
- **D.** `1 2 3`

### Câu M1-43

Ở múi giờ Europe/Paris, ngày 2024-10-27 lúc 03:00 đồng hồ lùi về 02:00. Chương trình sau in ra gì?

```java
import java.time.*;
import java.time.temporal.ChronoUnit;

public class FallBack {
    public static void main(String[] args) {
        ZoneId z = ZoneId.of("Europe/Paris");
        ZonedDateTime a = ZonedDateTime.of(2024, 10, 27, 1, 30, 0, 0, z);
        ZonedDateTime b = a.plusHours(2);
        System.out.println(b.toLocalTime() + " " + Duration.between(a, b).toMinutes() + " "
                + ChronoUnit.HOURS.between(a.toLocalDateTime(), b.toLocalDateTime()));
    }
}
```

- **A.** `03:30 120 2`
- **B.** `02:30 120 1`
- **C.** `02:30 60 1`
- **D.** `03:30 120 1`

### Câu M1-44

Những dòng nào gây lỗi biên dịch?

```java
import java.util.function.*;

public class Fi {
    public static void main(String[] args) {
        Supplier<String> a = String::new;                              // L1
        Function<String, Integer> b = Integer::parseInt;               // L2
        BiFunction<String, Integer, Character> c = String::charAt;     // L3
        Predicate<String> d = String::isEmpty;                         // L4
        UnaryOperator<String> e = s -> s.length();                     // L5
        Consumer<String> f = s -> s.length();                          // L6
        Runnable g = () -> { return 1; };                              // L7
    }
}
```

- **A.** Chỉ L5
- **B.** L3, L5 và L7
- **C.** L6 và L7
- **D.** L5 và L7
- **E.** L5, L6 và L7

### Câu M1-45

Điều gì đúng về output của chương trình?

```java
import java.util.*;
import java.util.stream.*;

public class Par {
    public static void main(String[] args) {
        List<Integer> nums = IntStream.rangeClosed(1, 100).boxed().toList();
        int s1 = nums.parallelStream().mapToInt(i -> i).sum();
        List<Integer> quarter = nums.parallelStream().filter(i -> i % 25 == 0).toList();
        long c = nums.parallelStream().unordered().filter(i -> i > 90).count();
        System.out.println(s1 + " " + quarter + " " + c);
    }
}
```

- **A.** Luôn in `5050 [25, 50, 75, 100] 10`
- **B.** Tổng luôn là 5050 nhưng thứ tự trong list có thể thay đổi
- **C.** Luôn in `5050 [25, 50, 75, 100] 9`
- **D.** Tổng thay đổi mỗi lần chạy vì chạy song song

### Câu M1-46

Chương trình sau in ra gì?

```java
import java.io.*;

public class Ser2 {
    static class Base implements Serializable { int b = 1; }

    static class Sub extends Base {
        int s = 2;
        transient int t = 3;
        static int st = 4;
        Sub() { b = 10; s = 20; t = 30; }
    }

    public static void main(String[] args) throws Exception {
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        try (var out = new ObjectOutputStream(bytes)) { out.writeObject(new Sub()); }
        Sub.st = 40;
        try (var in = new ObjectInputStream(new ByteArrayInputStream(bytes.toByteArray()))) {
            Sub x = (Sub) in.readObject();
            System.out.println(x.b + " " + x.s + " " + x.t + " " + Sub.st);
        }
    }
}
```

- **A.** `10 20 30 4`
- **B.** `1 2 3 40`
- **C.** `10 20 0 40`
- **D.** `10 20 0 4`

### Câu M1-47

Module `com.api` export interface `com.api.Tax`; module `com.impl` có `provides com.api.Tax with com.impl.VatTax;` (rate 10). Điền nội dung `module-info.java` nào cho `com.app` (thay `// INSERT CODE HERE`) để chương trình in ra `rate=10`? **(Chọn 2 đáp án.)**

`src/com.app/com/app/Main.java`

```java
package com.app;
import java.util.ServiceLoader;
public class Main {
    public static void main(String[] args) {
        ServiceLoader.load(com.api.Tax.class).findFirst()
                .ifPresent(t -> System.out.println("rate=" + t.rate()));
    }
}
```

- **A.** `module com.app { requires com.api; uses com.api.Tax; }`
- **B.** `module com.app { requires com.api; }`
- **C.** `module com.app { requires com.api; requires com.impl; uses com.api.Tax; }`
- **D.** `module com.app { uses com.api.Tax; }`
- **E.** `module com.app { requires com.api; provides com.api.Tax; }`

### Câu M1-48

Chương trình sau in ra gì?

```java
public class Chain {
    static class AppEx extends Exception {
        AppEx(String m, Throwable c) { super(m, c); }
    }

    static void load() throws AppEx {
        try {
            Integer.parseInt("x");
        } catch (NumberFormatException e) {
            throw new AppEx("load failed", e);
        } finally {
            System.out.print("F ");
        }
    }

    public static void main(String[] args) {
        try {
            load();
        } catch (AppEx e) {
            System.out.print(e.getMessage() + " <- " + e.getCause().getClass().getSimpleName());
        }
    }
}
```

- **A.** `load failed <- NumberFormatException F`
- **B.** `F load failed <- NumberFormatException`
- **C.** `F load failed <- AppEx`
- **D.** `F For input string: "x" <- NumberFormatException`

### Câu M1-49

Chương trình sau in ra gì?

```java
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

public class Fmt {
    public static void main(String[] args) {
        LocalDateTime t = LocalDateTime.of(2024, 7, 4, 9, 5);
        System.out.println(t.format(DateTimeFormatter.ofPattern("EEE, MMM d yyyy 'at' h:mm a", Locale.US)));
    }
}
```

- **A.** `Thu, Jul 04 2024 at 09:05 AM`
- **B.** `Thursday, July 4 2024 at 9:05 AM`
- **C.** `Thu, Jul 4 2024 'at' 9:05 AM`
- **D.** `Thu, Jul 4 2024 at 9:05 AM`

### Câu M1-50

Chương trình sau in ra gì?

```java
import java.util.*;

public class Eq {
    record Pt(int x, int y) { }

    static class Pix {
        int x;
        Pix(int x) { this.x = x; }
        @Override public boolean equals(Object o) { return o instanceof Pix p && p.x == x; }
    }

    public static void main(String[] args) {
        Set<Object> set = new HashSet<>();
        set.add(new Pt(1, 2));
        set.add(new Pt(1, 2));
        set.add(new Pix(5));
        set.add(new Pix(5));
        System.out.println(set.size() + " " + new Pix(5).equals(new Pix(5)) + " " + new Pt(1, 2).equals(new Pt(1, 2)));
    }
}
```

- **A.** `3 true true`
- **B.** `2 true true`
- **C.** `4 false true`
- **D.** `3 false true`

## Nguồn tham khảo (Sources)

Câu hỏi tự viết; đáp án kiểm chứng bằng OpenJDK 21.0.10 (`examples/questions/mock1/`). Thông tin kỳ thi: DECISION.md (**UNVERIFIED**).
