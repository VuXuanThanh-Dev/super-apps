# Chương 6 — Lambda và Stream (Working with Streams and Lambda expressions)

## Mục tiêu

- 6.1 Dùng stream object và stream primitive, cùng biểu thức lambda cài đặt functional interface, để **tạo, lọc,
  biến đổi, xử lý và sắp xếp** dữ liệu.
- 6.2 **Phân rã** (decomposition: `flatMap`), **nối** (concatenation: `concat`), **rút gọn** (reduction: `reduce`,
  `count`, `sum`…), **gom nhóm** (grouping) và **chia hai** (partitioning) trên stream tuần tự và song song.

## Giải thích đơn giản

**Lambda** là một hàm không tên, viết gọn: `x -> x * 2`. Trong Java, lambda luôn "đóng vai" một **functional
interface** (interface có đúng một method abstract), ví dụ `Function<Integer, Integer>`.

**Stream** là một dây chuyền xử lý dữ liệu:

```text
nguồn (source)  →  0..n thao tác trung gian (intermediate)  →  1 thao tác kết thúc (terminal)
List.stream()      filter / map / sorted / distinct / limit       toList / collect / reduce / forEach / count
```

Ba đặc điểm cần nhớ:

1. **Lười (lazy):** thao tác trung gian chỉ chạy khi có terminal operation.
2. **Từng phần tử một:** mỗi phần tử đi hết dây chuyền rồi phần tử sau mới vào (trừ `sorted` phải gom hết).
3. **Dùng một lần:** sau terminal operation, stream đóng; dùng lại → `IllegalStateException`.

Stream **không** thay đổi collection nguồn.

## Ví dụ

Code trong `examples/ch06/`. Chạy lại: `python3 tools/book.py examples ch06`. Output thật, JDK 21.0.10.

### 1. Cú pháp lambda và method reference

<!-- EX:Ex01_LambdaSyntax -->
`examples/ch06/Ex01_LambdaSyntax.java`

```java
// objective: 6.1, 3.6
// Cú pháp lambda và 4 loại method reference.
import java.util.*;
import java.util.function.*;

public class Ex01_LambdaSyntax {
    static boolean isShort(String s) { return s.length() < 4; }

    public static void main(String[] args) {
        Predicate<String> p1 = s -> s.isEmpty();                  // 1 tham số: bỏ được ()
        Predicate<String> p2 = (String s) -> s.isEmpty();         // ghi kiểu rõ
        Predicate<String> p3 = (var s) -> { return s.isEmpty(); }; // var + khối lệnh cần return
        BiFunction<Integer, Integer, Integer> add = (a, b) -> a + b;
        Supplier<List<String>> maker = () -> new ArrayList<>();
        System.out.println(p1.test("") + " " + p2.test("x") + " " + p3.test("") + " " + add.apply(2, 3) + " " + maker.get());

        Predicate<String> r1 = Ex01_LambdaSyntax::isShort;        // static method
        String prefix = "Mr. ";
        Function<String, String> r2 = prefix::concat;             // method của một object cụ thể
        Function<String, Integer> r3 = String::length;            // method instance, object là tham số đầu
        Supplier<StringBuilder> r4 = StringBuilder::new;          // constructor
        Function<Integer, int[]> r5 = int[]::new;                 // tạo mảng
        System.out.println(r1.test("abc") + " " + r2.apply("Nobin") + " " + r3.apply("lambda")
                + " " + r4.get().append("sb") + " " + r5.apply(3).length);

        int base = 10;                                            // effectively final
        IntUnaryOperator plusBase = x -> x + base;
        // base++;                                                // nếu có dòng này → lambda trên lỗi biên dịch
        System.out.println(plusBase.applyAsInt(5));
    }
}
```

Output thật (JDK 21.0.10):

```text
true false true 5 []
true Mr. Nobin 6 sb 3
15
```
<!-- /EX -->

### 2. Functional interface có sẵn

<!-- EX:Ex02_FunctionalInterfaces -->
`examples/ch06/Ex02_FunctionalInterfaces.java`

```java
// objective: 6.1, 3.6
// Các functional interface có sẵn trong java.util.function và cách kết hợp chúng.
import java.util.function.*;

public class Ex02_FunctionalInterfaces {
    public static void main(String[] args) {
        Supplier<String> sup = () -> "hi";
        Consumer<String> con = s -> System.out.print("[" + s + "]");
        BiConsumer<String, Integer> bi = (k, v) -> System.out.print(k + "=" + v + " ");
        con.andThen(s -> System.out.println(" again " + s)).accept(sup.get());
        bi.accept("a", 1);
        System.out.println();

        Predicate<Integer> even = n -> n % 2 == 0;
        Predicate<Integer> big = n -> n > 10;
        System.out.println(even.and(big).test(12) + " " + even.or(big).test(3) + " " + even.negate().test(3)
                + " " + Predicate.not(even).test(4) + " " + Predicate.isEqual("x").test("x"));

        Function<Integer, Integer> times2 = x -> x * 2;
        Function<Integer, Integer> plus3 = x -> x + 3;
        System.out.println(times2.andThen(plus3).apply(5) + " " + times2.compose(plus3).apply(5)
                + " " + Function.<Integer>identity().apply(7));

        UnaryOperator<String> upper = String::toUpperCase;
        BinaryOperator<Integer> max = BinaryOperator.maxBy(Integer::compare);
        System.out.println(upper.apply("java") + " " + max.apply(4, 9));

        IntPredicate odd = i -> i % 2 != 0;                 // primitive: tránh boxing
        ToIntFunction<String> len = String::length;
        IntFunction<String> stars = n -> "*".repeat(n);
        DoubleUnaryOperator half = d -> d / 2;
        IntBinaryOperator mul = (a, b) -> a * b;
        BooleanSupplier yes = () -> true;
        System.out.println(odd.test(3) + " " + len.applyAsInt("abcd") + " " + stars.apply(3) + " "
                + half.applyAsDouble(5) + " " + mul.applyAsInt(6, 7) + " " + yes.getAsBoolean());
    }
}
```

Output thật (JDK 21.0.10):

```text
[hi] again hi
a=1
true false true false true
13 16 7
JAVA 9
true 4 *** 2.5 42 true
```
<!-- /EX -->

### 3. Tính lười của stream

<!-- EX:Ex03_Laziness -->
`examples/ch06/Ex03_Laziness.java`

```java
// objective: 6.1
// Stream "lười" (lazy): không có terminal operation thì không chạy gì; phần tử đi qua pipeline TỪNG CÁI MỘT.
import java.util.List;
import java.util.stream.Stream;

public class Ex03_Laziness {
    public static void main(String[] args) {
        Stream<String> s = Stream.of("a", "bb", "ccc")
                .peek(x -> System.out.println("peek " + x))
                .filter(x -> x.length() > 1);
        System.out.println("chưa có terminal → chưa in peek");
        System.out.println(s.toList());

        List<String> result = Stream.of("one", "two", "three", "four")
                .filter(x -> { System.out.println("filter " + x); return x.length() == 3; })
                .map(x -> { System.out.println("map " + x); return x.toUpperCase(); })
                .limit(1)                                    // đủ 1 phần tử thì dừng luôn
                .toList();
        System.out.println(result);

        Stream<Integer> once = Stream.of(1, 2);
        once.count();
        try {
            once.count();                                     // stream chỉ dùng được một lần
        } catch (IllegalStateException e) {
            System.out.println("IllegalStateException: " + e.getMessage());
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
chưa có terminal → chưa in peek
peek a
peek bb
peek ccc
[bb, ccc]
filter one
map one
[ONE]
IllegalStateException: stream has already been operated upon or closed
```
<!-- /EX -->

### 4. filter, map, sorted, distinct, limit, skip

<!-- EX:Ex04_FilterMapSort -->
`examples/ch06/Ex04_FilterMapSort.java`

```java
// objective: 6.1
// Tạo, lọc, biến đổi, sắp xếp dữ liệu với stream.
import java.util.*;
import java.util.stream.*;

public class Ex04_FilterMapSort {
    record Emp(String name, String dept, int salary) { }

    public static void main(String[] args) {
        List<Emp> emps = List.of(
                new Emp("An", "IT", 3000), new Emp("Binh", "HR", 2000),
                new Emp("Chi", "IT", 4000), new Emp("Dung", "Sales", 2500), new Emp("Em", "IT", 3000));

        System.out.println(emps.stream()
                .filter(e -> e.dept().equals("IT"))
                .sorted(Comparator.comparingInt(Emp::salary).reversed().thenComparing(Emp::name))
                .map(Emp::name)
                .collect(Collectors.joining(", ", "[", "]")));

        System.out.println(Stream.of(5, 3, 5, 1, 3, 9).distinct().sorted().skip(1).limit(2).toList());
        System.out.println(Stream.of("b", "a", "c").sorted(Comparator.reverseOrder()).toList());
        System.out.println(Stream.iterate(1, x -> x * 2).limit(6).toList());
        System.out.println(Stream.iterate(1, x -> x < 50, x -> x * 3).toList());   // iterate có điều kiện dừng
        System.out.println(Stream.generate(() -> "x").limit(3).collect(Collectors.joining()));
        System.out.println(Arrays.stream(new int[]{3, 1, 2}).map(x -> x * 10).boxed().toList());
        System.out.println(Stream.ofNullable(null).count() + " " + Stream.empty().findFirst());
    }
}
```

Output thật (JDK 21.0.10):

```text
[Chi, An, Em]
[3, 5]
[c, b, a]
[1, 2, 4, 8, 16, 32]
[1, 3, 9, 27]
xxx
[30, 10, 20]
0 Optional.empty
```
<!-- /EX -->

### 5. flatMap và concat

<!-- EX:Ex05_FlatMapConcat -->
`examples/ch06/Ex05_FlatMapConcat.java`

```java
// objective: 6.2
// Phân rã (decomposition) bằng flatMap, nối (concatenation) bằng Stream.concat.
import java.util.*;
import java.util.stream.*;

public class Ex05_FlatMapConcat {
    public static void main(String[] args) {
        List<List<Integer>> nested = List.of(List.of(1, 2), List.of(3), List.of());
        System.out.println(nested.stream().flatMap(List::stream).map(x -> x * x).toList());

        List<String> lines = List.of("to be", "or not", "to be");
        System.out.println(lines.stream().flatMap(l -> Arrays.stream(l.split(" "))).distinct().toList());

        Stream<String> a = Stream.of("x", "y");
        Stream<String> b = Stream.of("z");
        System.out.println(Stream.concat(a, b).toList());

        System.out.println(IntStream.concat(IntStream.range(0, 2), IntStream.of(9)).boxed().toList());
        System.out.println(Stream.of("ab", "cde").flatMapToInt(String::chars).mapToObj(c -> (char) c).toList());

        List<Object> expanded = Stream.of(1, 2, 3)
                .<Object>mapMulti((n, sink) -> { if (n != 2) { sink.accept(n); sink.accept(-n); } })
                .toList();
        System.out.println(expanded);
    }
}
```

Output thật (JDK 21.0.10):

```text
[1, 4, 9]
[to, be, or, not]
[x, y, z]
[0, 1, 9]
[a, b, c, d, e]
[1, -1, 3, -3]
```
<!-- /EX -->

### 6. Reduction

<!-- EX:Ex06_Reduction -->
`examples/ch06/Ex06_Reduction.java`

```java
// objective: 6.2
// Rút gọn (reduction): reduce, count, min, max, sum, average.
import java.util.*;
import java.util.stream.*;

public class Ex06_Reduction {
    public static void main(String[] args) {
        List<Integer> nums = List.of(4, 8, 15, 16, 23, 42);
        int sum1 = nums.stream().reduce(0, Integer::sum);                 // identity + accumulator
        Optional<Integer> sum2 = nums.stream().reduce(Integer::sum);       // không identity → Optional
        int totalLen = Stream.of("ab", "cde").reduce(0, (acc, s) -> acc + s.length(), Integer::sum);  // 3 tham số
        System.out.println(sum1 + " " + sum2 + " " + totalLen);

        System.out.println(nums.stream().count() + " " + nums.stream().max(Integer::compare).get()
                + " " + nums.stream().min(Comparator.naturalOrder()).orElse(-1));
        System.out.println(nums.stream().mapToInt(Integer::intValue).sum() + " "
                + nums.stream().mapToInt(i -> i).average().getAsDouble());
        System.out.println(Stream.<Integer>empty().reduce(Integer::sum) + " "
                + Stream.<Integer>empty().reduce(100, Integer::sum) + " "
                + IntStream.empty().average() + " " + IntStream.empty().sum());
        String joined = Stream.of("a", "b", "c").reduce("", (x, y) -> x + y);
        System.out.println(joined);
    }
}
```

Output thật (JDK 21.0.10):

```text
108 Optional[108] 5
6 42 4
108 18.0
Optional.empty 100 OptionalDouble.empty 0
abc
```
<!-- /EX -->

### 7. Optional

<!-- EX:Ex07_Optional -->
`examples/ch06/Ex07_Optional.java`

```java
// objective: 6.1
// Optional: chứa 0 hoặc 1 giá trị; tránh null.
import java.util.Optional;

public class Ex07_Optional {
    static String expensive() {
        System.out.print("(expensive called) ");
        return "fallback";
    }

    public static void main(String[] args) {
        Optional<String> some = Optional.of("java");
        Optional<String> none = Optional.empty();
        Optional<String> maybe = Optional.ofNullable(null);
        System.out.println(some + " " + none + " " + maybe.isPresent() + " " + none.isEmpty());

        System.out.println(some.orElse(expensive()));                 // orElse LUÔN tính tham số
        System.out.println(some.orElseGet(Ex07_Optional::expensive)); // orElseGet chỉ gọi khi rỗng
        System.out.println(some.map(String::length).filter(n -> n > 3).orElse(0));
        some.ifPresentOrElse(v -> System.out.println("có " + v), () -> System.out.println("rỗng"));
        none.ifPresentOrElse(v -> System.out.println("có " + v), () -> System.out.println("rỗng"));
        System.out.println(some.flatMap(v -> Optional.of(v + "!")).get() + " " + none.or(() -> Optional.of("B")).get());
        try {
            none.get();
        } catch (java.util.NoSuchElementException e) {
            System.out.println("NoSuchElementException: " + e.getMessage());
        }
        try {
            Optional.of(null);
        } catch (NullPointerException e) {
            System.out.println("Optional.of(null) → NPE");
        }
        try {
            none.orElseThrow();
        } catch (java.util.NoSuchElementException e) {
            System.out.println("orElseThrow() → NoSuchElementException");
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
Optional[java] Optional.empty false true
(expensive called) java
java
4
có java
rỗng
java! B
NoSuchElementException: No value present
Optional.of(null) → NPE
orElseThrow() → NoSuchElementException
```
<!-- /EX -->

### 8. Stream primitive

<!-- EX:Ex08_PrimitiveStreams -->
`examples/ch06/Ex08_PrimitiveStreams.java`

```java
// objective: 6.1
// IntStream, LongStream, DoubleStream: range, sum, average, summaryStatistics, boxed, mapToObj.
import java.util.*;
import java.util.stream.*;

public class Ex08_PrimitiveStreams {
    public static void main(String[] args) {
        System.out.println(IntStream.range(1, 5).boxed().toList() + " " + IntStream.rangeClosed(1, 5).sum());
        IntSummaryStatistics st = IntStream.of(4, 9, 2).summaryStatistics();
        System.out.println(st.getMin() + " " + st.getMax() + " " + st.getAverage() + " " + st.getSum() + " " + st.getCount());
        OptionalDouble avg = IntStream.of(1, 2).average();
        OptionalInt max = IntStream.empty().max();
        System.out.println(avg + " " + avg.getAsDouble() + " " + max + " " + max.orElse(-1));
        System.out.println(DoubleStream.of(1.5, 2.5).map(d -> d * 2).sum() + " " + LongStream.rangeClosed(1, 20).reduce(1, (a, b) -> a * b));
        List<String> labels = IntStream.range(0, 3).mapToObj(i -> "#" + i).toList();
        System.out.println(labels + " " + Stream.of("a", "bb").mapToInt(String::length).max().getAsInt());
        double[] ds = Stream.of(1, 2).mapToDouble(Integer::doubleValue).toArray();
        System.out.println(Arrays.toString(ds) + " " + IntStream.of(3, 4).asLongStream().sum() + " " + IntStream.of(1, 2).mapToLong(i -> i * 10L).sum());
    }
}
```

Output thật (JDK 21.0.10):

```text
[1, 2, 3, 4] 15
2 9 5.0 15 3
OptionalDouble[1.5] 1.5 OptionalInt.empty -1
8.0 2432902008176640000
[#0, #1, #2] 2
[1.0, 2.0] 7 30
```
<!-- /EX -->

### 9. Collectors: groupingBy, partitioningBy, toMap

<!-- EX:Ex09_Collectors -->
`examples/ch06/Ex09_Collectors.java`

```java
// objective: 6.2
// Collectors: toList, joining, toMap, groupingBy (gom nhóm), partitioningBy (chia hai), counting, mapping...
import java.util.*;
import java.util.stream.*;

public class Ex09_Collectors {
    record Emp(String name, String dept, int salary) { }

    public static void main(String[] args) {
        List<Emp> emps = List.of(new Emp("An", "IT", 3000), new Emp("Binh", "HR", 2000),
                new Emp("Chi", "IT", 4000), new Emp("Dung", "Sales", 2500), new Emp("Em", "HR", 2200));

        Map<String, List<String>> byDept = emps.stream().collect(
                Collectors.groupingBy(Emp::dept, TreeMap::new, Collectors.mapping(Emp::name, Collectors.toList())));
        System.out.println(byDept);

        Map<String, Long> count = emps.stream().collect(Collectors.groupingBy(Emp::dept, TreeMap::new, Collectors.counting()));
        Map<String, Double> avg = emps.stream().collect(Collectors.groupingBy(Emp::dept, TreeMap::new, Collectors.averagingInt(Emp::salary)));
        System.out.println(count + " " + avg);

        Map<Boolean, List<String>> rich = emps.stream().collect(
                Collectors.partitioningBy(e -> e.salary() >= 3000, Collectors.mapping(Emp::name, Collectors.toList())));
        System.out.println(rich);
        System.out.println(Stream.of("x").collect(Collectors.partitioningBy(s -> s.isEmpty())));   // luôn có cả false và true

        Map<String, Integer> nameToSalary = emps.stream().collect(Collectors.toMap(Emp::name, Emp::salary));
        System.out.println(new TreeMap<>(nameToSalary));
        Map<String, Integer> maxByDept = emps.stream().collect(
                Collectors.toMap(Emp::dept, Emp::salary, Integer::max, TreeMap::new));
        System.out.println(maxByDept);
        try {
            emps.stream().collect(Collectors.toMap(Emp::dept, Emp::name));     // key trùng, không có merge
        } catch (IllegalStateException e) {
            System.out.println("IllegalStateException: " + e.getMessage());
        }

        System.out.println(emps.stream().map(Emp::name).collect(Collectors.joining("|")) + " "
                + emps.stream().collect(Collectors.summingInt(Emp::salary)) + " "
                + emps.stream().collect(Collectors.teeing(Collectors.counting(), Collectors.summingInt(Emp::salary),
                        (n, total) -> total / n)));
        Optional<Emp> top = emps.stream().collect(Collectors.maxBy(Comparator.comparingInt(Emp::salary)));
        System.out.println(top.map(Emp::name).orElse("-") + " "
                + emps.stream().map(Emp::dept).collect(Collectors.toCollection(TreeSet::new)));
    }
}
```

Output thật (JDK 21.0.10):

```text
{HR=[Binh, Em], IT=[An, Chi], Sales=[Dung]}
{HR=2, IT=2, Sales=1} {HR=2100.0, IT=3500.0, Sales=2500.0}
{false=[Binh, Dung, Em], true=[An, Chi]}
{false=[x], true=[]}
{An=3000, Binh=2000, Chi=4000, Dung=2500, Em=2200}
{HR=2200, IT=4000, Sales=2500}
IllegalStateException: Duplicate key IT (attempted merging values An and Chi)
An|Binh|Chi|Dung|Em 13700 2740
Chi [HR, IT, Sales]
```
<!-- /EX -->

### 10. Short-circuit, takeWhile, dropWhile

<!-- EX:Ex10_ShortCircuit -->
`examples/ch06/Ex10_ShortCircuit.java`

```java
// objective: 6.1
// Terminal operation "ngắn mạch" (short-circuit): anyMatch, allMatch, noneMatch, findFirst; takeWhile, dropWhile.
import java.util.stream.*;

public class Ex10_ShortCircuit {
    public static void main(String[] args) {
        System.out.println(Stream.of(1, 2, 3).anyMatch(x -> x > 2) + " " + Stream.of(1, 2, 3).allMatch(x -> x > 2)
                + " " + Stream.of(1, 2, 3).noneMatch(x -> x > 5));
        System.out.println("empty: any=" + Stream.empty().anyMatch(x -> true) + " all=" + Stream.empty().allMatch(x -> false)
                + " none=" + Stream.empty().noneMatch(x -> true));

        boolean found = Stream.iterate(1, x -> x + 1)                  // stream vô hạn
                .peek(x -> System.out.print(x + " "))
                .anyMatch(x -> x % 7 == 0);                             // dừng ở phần tử đầu tiên thoả
        System.out.println("→ " + found);

        System.out.println(Stream.of(1, 3, 5, 6, 7, 9).takeWhile(x -> x % 2 == 1).toList() + " "
                + Stream.of(1, 3, 5, 6, 7, 9).dropWhile(x -> x % 2 == 1).toList());
        System.out.println(Stream.of("a", "b", "c").findFirst().get() + " "
                + IntStream.iterate(10, x -> x - 3).filter(x -> x < 0).findFirst().getAsInt());
    }
}
```

Output thật (JDK 21.0.10):

```text
true false true
empty: any=false all=true none=true
1 2 3 4 5 6 7 → true
[1, 3, 5] [6, 7, 9]
a -2
```
<!-- /EX -->

### 11. Parallel stream và reduce

Kết quả dòng `par reduce10` và `par minus` là output thật trên máy kiểm tra (4 CPU); nó **phụ thuộc cách stream
được chia nhỏ**, nên không được coi là giá trị bảo đảm. Bài học: identity phải là phần tử trung hoà thật và hàm phải
có tính kết hợp.

<!-- EX:Ex11_ParallelReduce -->
`examples/ch06/Ex11_ParallelReduce.java`

```java
// objective: 6.2, 8.3
// Parallel stream: kết quả reduce đúng chỉ khi identity đúng nghĩa và hàm có tính kết hợp (associative).
import java.util.List;
import java.util.stream.IntStream;

public class Ex11_ParallelReduce {
    public static void main(String[] args) {
        List<Integer> nums = List.of(1, 2, 3, 4);
        System.out.println("seq sum      = " + nums.stream().reduce(0, Integer::sum));
        System.out.println("par sum      = " + nums.parallelStream().reduce(0, Integer::sum));
        System.out.println("seq reduce10 = " + nums.stream().reduce(10, Integer::sum));
        // 10 không phải identity của phép cộng → song song cộng 10 ở MỖI phần nhỏ (kết quả phụ thuộc cách chia)
        System.out.println("par reduce10 = " + nums.parallelStream().reduce(10, Integer::sum));
        // Phép trừ không kết hợp → song song cho kết quả khác tuần tự
        System.out.println("seq minus    = " + IntStream.rangeClosed(1, 4).reduce(0, (a, b) -> a - b));
        System.out.println("par minus    = " + IntStream.rangeClosed(1, 4).parallel().reduce(0, (a, b) -> a - b));
        System.out.println("isParallel   = " + nums.parallelStream().isParallel() + " / "
                + nums.stream().parallel().sequential().isParallel());
        // forEachOrdered giữ thứ tự nguồn kể cả khi song song
        StringBuilder sb = new StringBuilder();
        nums.parallelStream().map(x -> x * 10).forEachOrdered(x -> sb.append(x).append(' '));
        System.out.println("forEachOrdered: " + sb.toString().trim());
        System.out.println("findFirst trên parallel vẫn là phần tử đầu: " + nums.parallelStream().findFirst().get());
    }
}
```

Output thật (JDK 21.0.10):

```text
seq sum      = 10
par sum      = 10
seq reduce10 = 20
par reduce10 = 50
seq minus    = -10
par minus    = 0
isParallel   = true / false
forEachOrdered: 10 20 30 40
findFirst trên parallel vẫn là phần tử đầu: 1
```
<!-- /EX -->

### 12. Lỗi lambda hay gặp

<!-- EX:Ex12_LambdaErrors -->
`examples/ch06/Ex12_LambdaErrors.java`

```java
// objective: 6.1, 3.6
// expect: compile-error
// Lỗi lambda hay gặp: tham số trùng tên biến cục bộ; khối lệnh thiếu return.
import java.util.function.*;

public class Ex12_LambdaErrors {
    public static void main(String[] args) {
        String s = "x";
        Predicate<String> p = s -> s.isEmpty();
        Function<Integer, Integer> f = x -> { int y = x * 2; };
    }
}
```

Output thật của `javac` (JDK 21.0.10) — cố ý không biên dịch được:

```text
Ex12_LambdaErrors.java:9: error: variable s is already defined in method main(String[])
        Predicate<String> p = s -> s.isEmpty();
                              ^
Ex12_LambdaErrors.java:10: error: incompatible types: bad return type in lambda expression
        Function<Integer, Integer> f = x -> { int y = x * 2; };
                                       ^
    missing return value
2 errors
```
<!-- /EX -->

### 13. Effectively final

<!-- EX:Ex13_EffectivelyFinal -->
`examples/ch06/Ex13_EffectivelyFinal.java`

```java
// objective: 6.1, 3.6
// expect: compile-error
// Lambda chỉ dùng được biến cục bộ final hoặc effectively final (không bị gán lại ở bất kỳ đâu).
public class Ex13_EffectivelyFinal {
    public static void main(String[] args) {
        int count = 0;
        Runnable r = () -> System.out.println(count);
        count++;                       // gán lại SAU lambda vẫn làm count mất tính effectively final
        int[] box = {0};
        Runnable ok = () -> box[0]++;  // OK: tham chiếu box không đổi, chỉ nội dung mảng đổi
    }
}
```

Output thật của `javac` (JDK 21.0.10) — cố ý không biên dịch được:

```text
Ex13_EffectivelyFinal.java:7: error: local variables referenced from a lambda expression must be final or effectively final
        Runnable r = () -> System.out.println(count);
                                              ^
1 error
```
<!-- /EX -->

## Đi sâu

### Cú pháp lambda

| Dạng | Ví dụ |
|---|---|
| Không tham số | `() -> 42` |
| Một tham số, không kiểu | `x -> x + 1` (bỏ được ngoặc) |
| Có kiểu hoặc `var` | `(String s) -> s.length()`, `(var s) -> s.length()` — phải có ngoặc; không trộn kiểu/`var`/không kiểu |
| Khối lệnh | `(a, b) -> { int c = a + b; return c; }` — cần `return` nếu có giá trị, và dấu `;` |

Lambda dùng được: tham số của nó, field (không giới hạn), biến cục bộ **final hoặc effectively final**.
Tham số lambda không được trùng tên biến cục bộ đang trong phạm vi.

### Method reference (4 loại)

| Loại | Cú pháp | Lambda tương đương |
|---|---|---|
| Static method | `Integer::parseInt` | `s -> Integer.parseInt(s)` |
| Method của object cụ thể | `System.out::println`, `prefix::concat` | `x -> System.out.println(x)` |
| Method instance, object là tham số đầu | `String::length`, `String::equals` | `s -> s.length()`, `(a, b) -> a.equals(b)` |
| Constructor | `ArrayList::new`, `int[]::new` | `() -> new ArrayList<>()`, `n -> new int[n]` |

### Functional interface trong `java.util.function`

| Interface | Method | Ý nghĩa |
|---|---|---|
| `Supplier<T>` | `T get()` | Tạo giá trị |
| `Consumer<T>` / `BiConsumer<T,U>` | `void accept(T)` / `(T, U)` | Dùng giá trị, không trả về |
| `Predicate<T>` / `BiPredicate<T,U>` | `boolean test(T)` | Điều kiện; `and`, `or`, `negate`, `Predicate.not` |
| `Function<T,R>` / `BiFunction<T,U,R>` | `R apply(T)` | Biến đổi; `andThen`, `compose`, `identity` |
| `UnaryOperator<T>` | `T apply(T)` | `Function<T,T>` |
| `BinaryOperator<T>` | `T apply(T, T)` | `BiFunction<T,T,T>`; `minBy`, `maxBy` |

Phiên bản primitive (tránh boxing): `IntPredicate`, `IntFunction<R>`, `ToIntFunction<T>`, `IntUnaryOperator`,
`IntBinaryOperator`, `IntSupplier` (`getAsInt`), `IntConsumer`, `BooleanSupplier` (`getAsBoolean`), `ObjIntConsumer<T>`,
tương tự cho `Long`, `Double`.

### Thao tác trung gian (intermediate)

`filter`, `map`, `mapToInt`/`mapToObj`/…, `flatMap`, `mapMulti`, `distinct`, `sorted()` / `sorted(cmp)`, `peek`,
`limit`, `skip`, `takeWhile`, `dropWhile`, `boxed`, `parallel`, `sequential`, `unordered`.

### Thao tác kết thúc (terminal)

| Method | Trả về | Ghi chú |
|---|---|---|
| `forEach`, `forEachOrdered` | `void` | `forEach` trên parallel không giữ thứ tự |
| `toList()` (Java 16+) | `List<T>` bất biến | Khác `collect(Collectors.toList())` (không bảo đảm bất biến) |
| `collect(collector)` | tuỳ | |
| `reduce(identity, op)` | `T` | |
| `reduce(op)` | `Optional<T>` | |
| `reduce(identity, accumulator, combiner)` | `U` | Đổi kiểu kết quả |
| `count()` | `long` | |
| `min(cmp)`, `max(cmp)` | `Optional<T>` | Trên primitive stream: `OptionalInt`… không cần comparator |
| `findFirst()`, `findAny()` | `Optional<T>` | Short-circuit |
| `anyMatch`, `allMatch`, `noneMatch` | `boolean` | Short-circuit; stream rỗng: `false`, `true`, `true` |
| `toArray()` | `Object[]` | `toArray(String[]::new)` |

### Stream primitive

- Tạo: `IntStream.range(a, b)` (không gồm b), `rangeClosed(a, b)`, `IntStream.of(...)`, `Arrays.stream(int[])`,
  `"abc".chars()`.
- Có sẵn: `sum()` (trả về `int`/`long`/`double`), `average()` (**luôn** `OptionalDouble`), `max()`/`min()`
  (`OptionalInt`…), `summaryStatistics()`.
- Chuyển đổi: `boxed()`, `mapToObj`, `mapToLong`, `asDoubleStream`; từ object: `mapToInt(ToIntFunction)`.

### Optional

`Optional.of(v)` (v không được `null`), `ofNullable(v)`, `empty()`. Dùng: `isPresent`, `isEmpty`, `get` /
`orElseThrow()` (rỗng → `NoSuchElementException`), `orElse(v)` (**luôn** tính v), `orElseGet(supplier)`,
`orElseThrow(supplier)`, `map`, `flatMap`, `filter`, `ifPresent`, `ifPresentOrElse`, `or`.

### Collectors hay ra đề

| Collector | Kết quả |
|---|---|
| `toList()`, `toSet()`, `toCollection(TreeSet::new)` | Collection |
| `joining()`, `joining(", ")`, `joining(", ", "[", "]")` | `String` |
| `toMap(keyFn, valueFn)` | Trùng key → `IllegalStateException` |
| `toMap(keyFn, valueFn, merge)`, `toMap(..., merge, TreeMap::new)` | Có hàm merge, chọn loại map |
| `groupingBy(classifier)` | `Map<K, List<T>>` (HashMap) |
| `groupingBy(classifier, downstream)` | ví dụ `counting()` → `Map<K, Long>` |
| `groupingBy(classifier, mapFactory, downstream)` | ví dụ `TreeMap::new` |
| `partitioningBy(predicate[, downstream])` | `Map<Boolean, ...>` luôn có **cả** `false` và `true` |
| `counting()`, `summingInt`, `averagingInt` (→ `Double`), `minBy`, `maxBy` (→ `Optional`) | |
| `mapping(fn, downstream)`, `filtering`, `flatMapping` | Collector phụ |
| `teeing(c1, c2, merger)` | Kết hợp hai collector |

### Parallel stream

- Tạo: `collection.parallelStream()` hoặc `stream.parallel()`. `isParallel()` kiểm tra; lệnh gọi cuối cùng
  (`parallel`/`sequential`) quyết định cả pipeline.
- `reduce` song song đúng khi: identity là phần tử trung hoà (`0` cho `+`, `1` cho `*`, `""` cho nối chuỗi), accumulator
  **kết hợp (associative)** và **không trạng thái (stateless)**.
- Với nguồn có thứ tự: `findFirst`, `limit`, `skip`, `forEachOrdered`, `collect(toList())` giữ thứ tự gặp; `findAny`,
  `forEach` thì không.
- Tránh lambda có tác dụng phụ (ghi vào list chung không đồng bộ) — xem chương 8.

## Lỗi và bẫy thường gặp (Exam traps)

1. Không có terminal operation → không có gì chạy (kể cả `peek`).
2. Dùng lại stream → `IllegalStateException`.
3. `orElse(f())` luôn gọi `f()`.
4. `Optional.of(null)` → NPE; `get()` trên rỗng → `NoSuchElementException`.
5. `average()` trả `OptionalDouble`; `sum()` của `IntStream` trả `int`; `count()` trả `long`.
6. `range(1, 4)` không gồm 4.
7. `toMap` trùng key không có merge → `IllegalStateException`.
8. `partitioningBy` luôn có hai khoá, kể cả nhóm rỗng.
9. `allMatch` trên stream rỗng → `true`.
10. `takeWhile` dừng ở phần tử sai đầu tiên, khác `filter`.
11. Lambda dùng biến cục bộ bị gán lại (ở bất kỳ đâu) → lỗi.
12. Method reference có `()` → lỗi.
13. `reduce(10, Integer::sum)` song song có thể khác tuần tự.
14. `sorted()` trên object không `Comparable` → `ClassCastException` lúc chạy.

## Góc nhìn từ TypeScript

| TypeScript | Java | Ghi chú |
|---|---|---|
| `arr.filter(...).map(...)` chạy ngay, tạo mảng trung gian | `list.stream().filter(...).map(...)` lười, không tạo list trung gian | Cần terminal operation như `toList()` |
| `arr.reduce((a, b) => a + b, 0)` | `stream.reduce(0, Integer::sum)` | Thứ tự tham số khác nhau |
| `arr.flatMap(x => x.items)` | `stream.flatMap(x -> x.items().stream())` | Java cần trả về một `Stream` |
| `arr.some`, `arr.every` | `anyMatch`, `allMatch` | |
| `arr.find(...)` trả `undefined` nếu không thấy | `filter(...).findFirst()` trả `Optional` | |
| Arrow function `(x) => x * 2` | Lambda `x -> x * 2` | Dấu `->` thay vì `=>` |
| Closure bắt được mọi biến, kể cả `let` bị gán lại | Chỉ biến effectively final | |
| `Object.groupBy(arr, fn)` (ES2024) | `Collectors.groupingBy(fn)` | |
| Mảng dùng lại nhiều lần | Stream chỉ dùng một lần | |

## Tóm tắt

- Lambda = cài đặt functional interface; biến cục bộ phải effectively final.
- 4 loại method reference; biết interface nào có method gì (`get`, `accept`, `test`, `apply`).
- Stream: nguồn → intermediate (lười) → một terminal; dùng một lần.
- Reduction: `reduce` (3 dạng), `count`, `sum`, `average` (`OptionalDouble`), `min`/`max` (`Optional`).
- Collectors: `groupingBy` (+ downstream + map factory), `partitioningBy`, `toMap` (merge), `joining`.
- Parallel: identity đúng + hàm kết hợp; thứ tự chỉ được giữ với các thao tác "ordered".

## Bài tập (có lời giải)

Mọi đáp án đã được `tools/book.py` biên dịch và chạy để xác nhận (code: `examples/questions/ch06/`).

### Câu hỏi

<!-- QUESTIONS:ch06 -->
#### Câu 06-01 · Dễ · objective 6.1

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.stream.*;

public class Basic {
    public static void main(String[] args) {
        List<String> r = Stream.of("pear", "fig", "apple", "kiwi")
                .filter(s -> s.length() > 3)
                .map(String::toUpperCase)
                .sorted()
                .toList();
        System.out.println(r);
    }
}
```

- **A.** `[PEAR, APPLE, KIWI]`
- **B.** `[APPLE, FIG, KIWI, PEAR]`
- **C.** `[APPLE, KIWI, PEAR]`
- **D.** `[apple, kiwi, pear]`

#### Câu 06-02 · Vừa · objective 6.1

Chương trình sau in ra gì?

```java
import java.util.stream.*;

public class Lazy {
    public static void main(String[] args) {
        Stream.of(1, 2, 3, 4, 5)
                .peek(x -> System.out.print("p" + x + " "))
                .filter(x -> x % 2 == 0)
                .limit(1)
                .forEach(x -> System.out.print("f" + x + " "));
    }
}
```

- **A.** `p1 p2 p3 p4 p5 f2`
- **B.** `p1 p2 f2`
- **C.** `p1 p2 f2 p3 p4 f4`
- **D.** `f2`

#### Câu 06-03 · Vừa · objective 6.2

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.stream.*;

public class Reduce {
    public static void main(String[] args) {
        int a = Stream.of(1, 2, 3).reduce(10, Integer::sum);
        Optional<Integer> b = Stream.<Integer>empty().reduce(Integer::sum);
        int c = Stream.of("a", "bb", "ccc").reduce(0, (acc, s) -> acc + s.length(), Integer::sum);
        System.out.println(a + " " + b + " " + c);
    }
}
```

- **A.** `6 0 6`
- **B.** `16 null 6`
- **C.** `16 Optional[0] 6`
- **D.** `16 Optional.empty 6`

#### Câu 06-04 · Khó · objective 6.2

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.stream.*;

public class Groups {
    record Item(String cat, int price) { }

    public static void main(String[] args) {
        Map<Boolean, Map<String, Long>> m = Stream.of(
                new Item("a", 5), new Item("b", 20), new Item("a", 30), new Item("c", 1))
            .collect(Collectors.partitioningBy(i -> i.price() > 10,
                    Collectors.groupingBy(Item::cat, TreeMap::new, Collectors.counting())));
        System.out.println(m);
    }
}
```

- **A.** `{true={a=1, b=1}, false={a=1, c=1}}`
- **B.** `{false={a=1, c=1}, true={a=1, b=1}}`
- **C.** `{false={a=2, c=1}, true={b=1}}`
- **D.** `{false={a=1, c=1}, true={a=1, b=1}, null={}}`

#### Câu 06-05 · Vừa · objective 6.1

Chương trình sau in ra gì?

```java
import java.util.*;

public class Opt {
    static String load() {
        System.out.print("load ");
        return "db";
    }

    public static void main(String[] args) {
        Optional<String> o = Optional.of("cache");
        String a = o.orElse(load());
        String b = o.orElseGet(() -> load());
        String c = Optional.<String>empty().map(String::toUpperCase).orElseGet(() -> "none");
        System.out.println(a + " " + b + " " + c);
    }
}
```

- **A.** `cache cache none`
- **B.** `load load cache cache none`
- **C.** `load cache cache none`
- **D.** `load cache db NONE`

#### Câu 06-06 · Vừa · objective 6.1, 3.6

Chèn dòng nào vào chỗ `// INSERT CODE HERE` thì chương trình biên dịch được? **(Chọn 3 đáp án.)**

```java
import java.util.function.*;

public class Syntax {
    public static void main(String[] args) {
        // INSERT CODE HERE
    }
}
```

- **A.** `Function<String, Integer> f = s -> s.length();`
- **B.** `BiFunction<String, String, Boolean> b = (x, y) -> { x.equals(y); };`
- **C.** `Supplier<String> s = () -> "hi";`
- **D.** `Predicate<String> p = (var x, y) -> true;`
- **E.** `Consumer<String> c = (String x) -> System.out.println(x);`
- **F.** `Runnable r = x -> {};`

#### Câu 06-07 · Vừa · objective 6.2

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.stream.*;

public class Flat {
    public static void main(String[] args) {
        List<List<String>> data = List.of(List.of("a", "b"), List.of("b", "c"), List.of());
        long n = data.stream().flatMap(List::stream).distinct().count();
        String s = data.stream().map(List::size).map(String::valueOf)
                .collect(Collectors.joining("-", "<", ">"));
        System.out.println(n + " " + s);
    }
}
```

- **A.** `3 <2-2-0>`
- **B.** `4 <2-2-0>`
- **C.** `3 <2-2>`
- **D.** `3 2-2-0`

#### Câu 06-08 · Vừa · objective 6.1

Hai phát biểu nào đúng? **(Chọn 2 đáp án.)**

- **A.** Một stream có thể dùng lại sau khi đã chạy terminal operation.
- **B.** `allMatch` trên stream rỗng trả về `true`.
- **C.** `peek` là một terminal operation.
- **D.** `IntStream.average()` trả về `OptionalDouble`.
- **E.** `Collectors.toMap` tự bỏ qua các key bị trùng.

#### Câu 06-09 · Khó · objective 6.2, 8.3

Điều gì đúng về kết quả của chương trình?

```java
import java.util.*;
import java.util.stream.*;

public class Par {
    public static void main(String[] args) {
        List<Integer> r = IntStream.rangeClosed(1, 10).parallel()
                .filter(i -> i % 3 == 0).boxed().collect(Collectors.toList());
        int first = IntStream.rangeClosed(1, 10).parallel().filter(i -> i > 4).findFirst().getAsInt();
        System.out.println(r + " " + first);
    }
}
```

- **A.** Luôn in `[3, 6, 9] 5`
- **B.** In `[3, 6, 9]` và một số bất kỳ lớn hơn 4
- **C.** Thứ tự trong list không xác định, còn số luôn là 5
- **D.** Không biên dịch được

#### Câu 06-10 · Vừa · objective 6.1

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.stream.*;

public class Prim {
    public static void main(String[] args) {
        IntSummaryStatistics s = IntStream.of(3, 8, 1).summaryStatistics();
        double avg = IntStream.rangeClosed(1, 4).average().orElse(0);
        System.out.println(s.getMax() + " " + s.getAverage() + " " + avg + " " + IntStream.range(1, 4).sum());
    }
}
```

- **A.** `8 4 2.5 10`
- **B.** `8 4.0 2.5 10`
- **C.** `8 4.0 2.0 6`
- **D.** `8 4.0 2.5 6`

#### Câu 06-11 · Vừa · objective 6.1, 3.6

Những dòng nào gây lỗi biên dịch?

```java
import java.util.function.*;

public class Capture {
    int field = 0;

    void run() {
        int local = 1;
        int other = 2;
        Supplier<Integer> a = () -> field++;          // L1
        Supplier<Integer> b = () -> local + 1;        // L2
        Supplier<Integer> c = () -> other++;          // L3
        IntUnaryOperator d = local -> local * 2;      // L4
    }

    public static void main(String[] args) { }
}
```

- **A.** Chỉ L3
- **B.** L1 và L3
- **C.** L3 và L4
- **D.** L1, L3 và L4
- **E.** Chỉ L4

#### Câu 06-12 · Khó · objective 6.2

Kết quả của chương trình là gì?

```java
import java.util.*;
import java.util.stream.*;

public class ToMap {
    public static void main(String[] args) {
        Map<Integer, String> m = Stream.of("aa", "b", "cc", "ddd", "e")
                .collect(Collectors.toMap(String::length, s -> s, (x, y) -> x + y, TreeMap::new));
        System.out.println(m);
    }
}
```

- **A.** In ra `{1=e, 2=cc, 3=ddd}`
- **B.** In ra `{1=b, 2=aa, 3=ddd}`
- **C.** In ra `{1=be, 2=aacc, 3=ddd}`
- **D.** Ném `IllegalStateException` vì trùng key

#### Câu 06-13 · Vừa · objective 6.1

Chương trình sau in ra gì?

```java
import java.util.function.*;

public class Compose {
    public static void main(String[] args) {
        Function<Integer, Integer> inc = x -> x + 1;
        Function<Integer, Integer> dbl = x -> x * 2;
        System.out.println(inc.andThen(dbl).apply(3) + " " + inc.compose(dbl).apply(3) + " "
                + dbl.andThen(dbl).compose(inc).apply(1));
    }
}
```

- **A.** `7 8 8`
- **B.** `8 7 6`
- **C.** `8 8 8`
- **D.** `8 7 8`

#### Câu 06-14 · Dễ · objective 6.1

Chương trình sau in ra gì?

```java
import java.util.stream.*;

public class While {
    public static void main(String[] args) {
        System.out.println(Stream.of(2, 4, 5, 6).takeWhile(x -> x % 2 == 0).toList() + " "
                + Stream.of(2, 4, 5, 6).dropWhile(x -> x % 2 == 0).toList());
    }
}
```

- **A.** `[2, 4] [5, 6]`
- **B.** `[2, 4, 6] [5]`
- **C.** `[2, 4] [5]`
- **D.** `[5, 6] [2, 4]`

#### Câu 06-15 · Khó · objective 6.2

Đoạn code nào, chèn vào chỗ `// INSERT CODE HERE`, in ra đúng `{false=[1, 3], true=[2, 4]}`? **(Chọn 2 đáp án.)**

```java
import java.util.*;
import java.util.stream.*;

public class Part {
    public static void main(String[] args) {
        List<Integer> nums = List.of(1, 2, 3, 4);
        // INSERT CODE HERE
    }
}
```

- **A.** `System.out.println(nums.stream().collect(Collectors.partitioningBy(n -> n % 2 == 0)));`
- **B.** `System.out.println(nums.stream().collect(Collectors.partitioningBy(n -> n % 2 == 1)));`
- **C.** `Map<Boolean, List<Integer>> m = nums.stream().collect(Collectors.groupingBy(n -> n % 2 == 0, TreeMap::new, Collectors.toList())); System.out.println(m);`
- **D.** `System.out.println(nums.stream().collect(Collectors.partitioningBy(n -> n % 2 == 0, Collectors.counting())));`
- **E.** `System.out.println(nums.stream().filter(n -> n % 2 == 0).toList());`

#### Câu 06-16 · Vừa · objective 6.1

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.stream.*;

public class Sort {
    public static void main(String[] args) {
        List<Integer> r = Stream.of("10", "9", "100").sorted().map(Integer::parseInt).toList();
        List<Integer> s = Stream.of("10", "9", "100").map(Integer::parseInt)
                .sorted(Comparator.reverseOrder()).toList();
        System.out.println(r + " " + s);
    }
}
```

- **A.** `[9, 10, 100] [100, 10, 9]`
- **B.** `[10, 100, 9] [100, 10, 9]`
- **C.** `[10, 100, 9] [9, 100, 10]`
- **D.** `[10, 9, 100] [100, 10, 9]`

#### Câu 06-17 · Vừa · objective 6.1, 3.6

Dòng nào gây lỗi biên dịch?

```java
import java.util.function.*;

public class Refs {
    static int twice(int x) { return 2 * x; }

    public static void main(String[] args) {
        Function<String, Integer> a = String::length;           // L1
        Supplier<String> b = String::new;                       // L2
        IntUnaryOperator c = Refs::twice;                       // L3
        Function<String, String> d = String::toUpperCase();     // L4
        BiFunction<String, String, Boolean> e = String::equals; // L5
    }
}
```

- **A.** L2
- **B.** L4
- **C.** L2 và L4
- **D.** L4 và L5
- **E.** Không dòng nào

#### Câu 06-18 · Khó · objective 6.1

Hai phát biểu nào đúng về `Optional`? **(Chọn 2 đáp án.)**

- **A.** `Optional.ofNullable(null).isPresent()` trả về `false`.
- **B.** `Optional.of(null)` trả về một Optional rỗng.
- **C.** `orElse(x)` chỉ tính biểu thức `x` khi Optional rỗng.
- **D.** `Optional.empty().map(f)` không gọi hàm `f`.
- **E.** `get()` trên Optional rỗng trả về `null`.

#### Câu 06-19 · Vừa · objective 6.2

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.stream.*;

public class Join {
    public static void main(String[] args) {
        Map<Integer, String> m = Stream.of("sun", "moon", "sky", "star")
                .collect(Collectors.groupingBy(String::length, TreeMap::new, Collectors.joining("+")));
        System.out.println(m);
    }
}
```

- **A.** `{3=sun+sky, 4=moon+star}`
- **B.** `{3=[sun, sky], 4=[moon, star]}`
- **C.** `{4=moon+star, 3=sun+sky}`
- **D.** `{3=sky+sun, 4=moon+star}`

#### Câu 06-20 · Dễ · objective 6.1

Kết quả của chương trình là gì?

```java
import java.util.*;

public class Empty {
    public static void main(String[] args) {
        List<String> empty = List.of();
        System.out.println(empty.stream().count() + " "
                + empty.stream().allMatch(s -> s.length() > 5) + " "
                + empty.stream().anyMatch(s -> true));
    }
}
```

- **A.** In ra `0 false false`
- **B.** In ra `0 true true`
- **C.** Ném `NoSuchElementException`
- **D.** In ra `0 true false`
<!-- /QUESTIONS -->

### Lời giải

<!-- ANSWERS:ch06 -->
#### Câu 06-01 — Đáp án: **C**

- **Vì sao đúng:** `filter` bỏ `fig` (độ dài 3, không > 3). `map` đổi sang chữ hoa. `sorted()` sắp xếp theo thứ tự tự nhiên.
- **A sai:** `sorted()` sắp xếp lại theo bảng chữ cái, không giữ thứ tự ban đầu.
- **B sai:** `fig` có độ dài 3, bị `filter(s -> s.length() > 3)` loại.
- **D sai:** `map(String::toUpperCase)` đã đổi sang chữ hoa.
- *Kiểm chứng:* `examples/questions/ch06/Q06_01/` — output confirmed (`python3 tools/book.py questions ch06`).

#### Câu 06-02 — Đáp án: **B**

- **Vì sao đúng:** Stream xử lý **từng phần tử** đi hết pipeline (không phải từng bước cho cả danh sách). 1 qua `peek` rồi bị `filter` loại; 2 qua `peek`, qua `filter`, tới `forEach`. `limit(1)` đã đủ nên stream dừng, 3, 4, 5 không được xử lý.
- **A sai:** Stream không chạy `peek` cho tất cả trước; `limit` làm dừng sớm (short-circuit).
- **C sai:** `limit(1)` chỉ cho một phần tử đi qua.
- **D sai:** `peek` vẫn chạy cho các phần tử đã được kéo qua pipeline (1 và 2).
- *Kiểm chứng:* `examples/questions/ch06/Q06_02/` — output confirmed (`python3 tools/book.py questions ch06`).

#### Câu 06-03 — Đáp án: **D**

- **Vì sao đúng:** `reduce(10, sum)` bắt đầu từ 10 (tuần tự) → 16. `reduce(accumulator)` không có identity trả về `Optional`; stream rỗng → `Optional.empty`. Dạng 3 tham số (identity, accumulator, combiner) cho phép đổi kiểu: cộng độ dài → 6.
- **A sai:** Giá trị khởi đầu 10 được cộng vào; và dạng không identity trả về `Optional`.
- **B sai:** `reduce` không bao giờ trả về `null`; nó trả về `Optional.empty`.
- **C sai:** Không có phần tử thì không có giá trị nào, nên là `Optional.empty`, không phải 0.
- *Kiểm chứng:* `examples/questions/ch06/Q06_03/` — output confirmed (`python3 tools/book.py questions ch06`).

#### Câu 06-04 — Đáp án: **B**

- **Vì sao đúng:** `partitioningBy` chia thành hai nhóm `false` và `true` (in `false` trước). Trong mỗi nhóm, `groupingBy` đếm theo `cat` vào `TreeMap`. Giá ≤ 10: a(5), c(1). Giá > 10: b(20), a(30).
- **A sai:** Map của `partitioningBy` in khoá `false` trước `true`.
- **C sai:** `a` có một món giá 5 (nhóm false) và một món giá 30 (nhóm true), nên mỗi nhóm chỉ đếm 1.
- **D sai:** `partitioningBy` chỉ có đúng hai khoá: `false` và `true`.
- *Kiểm chứng:* `examples/questions/ch06/Q06_04/` — output confirmed (`python3 tools/book.py questions ch06`).

#### Câu 06-05 — Đáp án: **C**

- **Vì sao đúng:** Tham số của `orElse` là một biểu thức bình thường, nên `load()` **luôn** được gọi (in `load `), dù Optional có giá trị. `orElseGet` nhận `Supplier`, chỉ gọi khi rỗng → không in. `map` trên Optional rỗng vẫn rỗng → `"none"`.
- **A sai:** `orElse(load())` luôn tính `load()` trước khi gọi `orElse`.
- **B sai:** `orElseGet` chỉ gọi supplier khi Optional rỗng; ở đây có giá trị.
- **D sai:** Optional có giá trị `cache`, nên `b` là `cache`; và `c` là `"none"` do supplier trả về (không đi qua `map`).
- *Kiểm chứng:* `examples/questions/ch06/Q06_05/` — output confirmed (`python3 tools/book.py questions ch06`).

#### Câu 06-06 — Đáp án: **A, C, E**

- **Vì sao đúng:** A: một tham số, bỏ ngoặc và kiểu. C: không tham số dùng `()`. E: tham số có kiểu rõ ràng phải đặt trong ngoặc.
- **B sai:** Khối `{ }` trả về giá trị phải có `return`: `{ return x.equals(y); }`.
- **D sai:** `Predicate` chỉ có một tham số; hơn nữa không được trộn `var` với tham số không có kiểu.
- **F sai:** `Runnable.run()` không có tham số.
- *Kiểm chứng:* `examples/questions/ch06/Q06_06/` — variants: ACE satisfy compiles (`python3 tools/book.py questions ch06`).

#### Câu 06-07 — Đáp án: **A**

- **Vì sao đúng:** `flatMap` "làm phẳng" các list con thành một stream: a, b, b, c → `distinct` còn 3. `joining(delimiter, prefix, suffix)` nối kích thước các list (2, 2, 0) với `-` và bọc bởi `<` `>`.
- **B sai:** `distinct()` loại `b` trùng.
- **C sai:** List rỗng vẫn là một phần tử của stream ngoài, kích thước 0.
- **D sai:** `joining` với 3 tham số thêm prefix `<` và suffix `>`.
- *Kiểm chứng:* `examples/questions/ch06/Q06_07/` — output confirmed (`python3 tools/book.py questions ch06`).

#### Câu 06-08 — Đáp án: **B, D**

- **Vì sao đúng:** B: "mọi phần tử đều thoả" là đúng một cách hiển nhiên khi không có phần tử nào (vacuous truth). D: `average()` của primitive stream trả về `OptionalDouble` (có thể rỗng).
- **A sai:** Stream chỉ dùng được một lần; lần thứ hai ném `IllegalStateException`.
- **C sai:** `peek` là intermediate operation; không có terminal thì nó không chạy (không in 1, 2).
- **E sai:** Key trùng mà không có hàm merge → `IllegalStateException: Duplicate key`.
- *Kiểm chứng:* `examples/questions/ch06/Q06_08/` — each option proven true/false by a program (`python3 tools/book.py questions ch06`).

#### Câu 06-09 — Đáp án: **A**

- **Vì sao đúng:** `IntStream.rangeClosed` là nguồn **có thứ tự (ordered)**. Với stream có thứ tự, `collect(toList())` giữ đúng thứ tự gặp (encounter order) và `findFirst()` luôn trả về phần tử **đầu tiên** thoả điều kiện, kể cả khi chạy song song.
- **B sai:** Đó là hành vi của `findAny()`, không phải `findFirst()`.
- **C sai:** `collect` trên stream có thứ tự giữ thứ tự gặp, kể cả song song.
- **D sai:** Code hợp lệ: `boxed()` đổi `IntStream` thành `Stream<Integer>` trước khi `collect`.
- *Kiểm chứng:* `examples/questions/ch06/Q06_09/` — output confirmed (`python3 tools/book.py questions ch06`).

#### Câu 06-10 — Đáp án: **D**

- **Vì sao đúng:** `getAverage()` trả về `double`: (3 + 8 + 1) / 3 = 4.0. `rangeClosed(1, 4)` = 1..4, trung bình 2.5. `range(1, 4)` **không gồm** 4: 1 + 2 + 3 = 6.
- **A sai:** `getAverage()` là `double` nên in `4.0`; `range(1, 4)` không gồm 4.
- **B sai:** `range` loại trừ đầu cuối: tổng là 6.
- **C sai:** `average()` tính bằng số thực: 10 / 4 = 2.5.
- *Kiểm chứng:* `examples/questions/ch06/Q06_10/` — output confirmed (`python3 tools/book.py questions ch06`).

#### Câu 06-11 — Đáp án: **C**

- **Vì sao đúng:** Lambda chỉ dùng được biến **cục bộ** final hoặc effectively final; `other++` sửa biến cục bộ → L3 lỗi. Tham số lambda không được trùng tên với biến cục bộ đang trong phạm vi → L4 lỗi. L1 hợp lệ vì `field` là field (qua `this`), không bị giới hạn. L2 chỉ đọc `local`.
- **A sai:** L4 cũng lỗi: tham số `local` trùng tên biến cục bộ.
- **B sai:** Field của object không bị quy tắc effectively final.
- **D sai:** L1 hợp lệ (xem B).
- **E sai:** L3 cũng lỗi: sửa biến cục bộ trong lambda.
- *Kiểm chứng:* `examples/questions/ch06/Q06_11/` — compile error confirmed at ['L3', 'L4'] (`python3 tools/book.py questions ch06`).

#### Câu 06-12 — Đáp án: **C**

- **Vì sao đúng:** `toMap` với 4 tham số: key mapper, value mapper, **hàm merge** khi trùng key, và nhà máy tạo map (`TreeMap`). Trùng key thì nối chuỗi theo thứ tự gặp: độ dài 1 → `b` + `e`, độ dài 2 → `aa` + `cc`.
- **A sai:** Hàm merge `(x, y) -> x + y` giữ cả hai giá trị, không chỉ giá trị sau.
- **B sai:** Hàm merge nối cả hai, không chỉ giữ giá trị đầu.
- **D sai:** Có hàm merge nên key trùng không gây exception.
- *Kiểm chứng:* `examples/questions/ch06/Q06_12/` — output confirmed (`python3 tools/book.py questions ch06`).

#### Câu 06-13 — Đáp án: **D**

- **Vì sao đúng:** `f.andThen(g)` = chạy f rồi g: (3 + 1) * 2 = 8. `f.compose(g)` = chạy g rồi f: 3 * 2 + 1 = 7. `dbl.andThen(dbl).compose(inc)`: inc trước (1 → 2), rồi dbl, dbl (2 → 4 → 8).
- **A sai:** Nhầm `andThen` và `compose`: `andThen` chạy hàm hiện tại **trước**.
- **B sai:** `compose(inc)` chạy `inc` trước: 1 + 1 = 2, rồi nhân đôi hai lần → 8.
- **C sai:** `inc.compose(dbl)` nhân trước rồi cộng: 7.
- *Kiểm chứng:* `examples/questions/ch06/Q06_13/` — output confirmed (`python3 tools/book.py questions ch06`).

#### Câu 06-14 — Đáp án: **A**

- **Vì sao đúng:** `takeWhile` lấy phần tử **cho tới khi** điều kiện sai lần đầu (dừng ở 5). `dropWhile` bỏ phần tử cho tới khi điều kiện sai lần đầu, rồi giữ **tất cả** phần còn lại (5, 6), kể cả 6 là số chẵn.
- **B sai:** `takeWhile` không phải `filter`: nó dừng hẳn ở phần tử đầu tiên không thoả.
- **C sai:** `dropWhile` giữ toàn bộ phần còn lại sau phần tử đầu tiên không thoả, gồm cả 6.
- **D sai:** Thứ tự in là kết quả `takeWhile` trước, `dropWhile` sau.
- *Kiểm chứng:* `examples/questions/ch06/Q06_14/` — output confirmed (`python3 tools/book.py questions ch06`).

#### Câu 06-15 — Đáp án: **A, C**

- **Vì sao đúng:** A: `partitioningBy` theo "là số chẵn" → false = [1, 3], true = [2, 4]. C: `groupingBy` với khoá `Boolean` vào `TreeMap` (thứ tự tự nhiên của `Boolean`: `false` < `true`) cho cùng kết quả.
- **B sai:** Điều kiện "là số lẻ" đảo ngược hai nhóm: `{false=[2, 4], true=[1, 3]}`.
- **D sai:** Collector phụ `counting()` đếm số phần tử: `{false=2, true=2}`.
- **E sai:** `filter` chỉ giữ số chẵn: `[2, 4]`.
- *Kiểm chứng:* `examples/questions/ch06/Q06_15/` — variants: AC satisfy output (`python3 tools/book.py questions ch06`).

#### Câu 06-16 — Đáp án: **B**

- **Vì sao đúng:** Stream đầu sắp xếp **chuỗi** (theo từng ký tự: "10" < "100" < "9") rồi mới đổi sang số. Stream thứ hai đổi sang số trước rồi sắp xếp giảm dần theo giá trị số.
- **A sai:** `sorted()` chạy trên `String` trước `map`, nên so sánh theo chữ, không theo số.
- **C sai:** Stream thứ hai sắp xếp **số** giảm dần: 100, 10, 9.
- **D sai:** "100" < "9" theo thứ tự chuỗi vì '1' < '9'.
- *Kiểm chứng:* `examples/questions/ch06/Q06_16/` — output confirmed (`python3 tools/book.py questions ch06`).

#### Câu 06-17 — Đáp án: **B**

- **Vì sao đúng:** Method reference **không** có dấu ngoặc `()`: phải viết `String::toUpperCase`. Các dòng khác hợp lệ: L2 dùng constructor không tham số của `String`; L5: object đầu tiên là "người nhận" (receiver), tham số thứ hai truyền vào `equals`.
- **A sai:** `String::new` khớp `Supplier<String>` qua constructor `String()`.
- **C sai:** L2 hợp lệ (xem A).
- **D sai:** `String::equals` khớp `BiFunction<String, String, Boolean>`: `(x, y) -> x.equals(y)`.
- **E sai:** L4 có dấu `()` sau tên method → lỗi cú pháp.
- *Kiểm chứng:* `examples/questions/ch06/Q06_17/` — compile error confirmed at ['L4'] (`python3 tools/book.py questions ch06`).

#### Câu 06-18 — Đáp án: **A, D**

- **Vì sao đúng:** A: `ofNullable(null)` tạo Optional rỗng. D: `map` trên Optional rỗng trả về Optional rỗng mà không gọi hàm.
- **B sai:** `Optional.of(null)` ném `NullPointerException`; muốn chấp nhận `null` phải dùng `ofNullable`.
- **C sai:** Tham số của `orElse` luôn được tính trước khi gọi method (dùng `orElseGet` để trì hoãn).
- **E sai:** `get()` trên Optional rỗng ném `NoSuchElementException`.
- *Kiểm chứng:* `examples/questions/ch06/Q06_18/` — each option proven true/false by a program (`python3 tools/book.py questions ch06`).

#### Câu 06-19 — Đáp án: **A**

- **Vì sao đúng:** Gom nhóm theo độ dài vào `TreeMap` (khoá tăng dần). Collector phụ `joining("+")` nối các phần tử của từng nhóm theo thứ tự gặp.
- **B sai:** Collector phụ là `joining`, không phải `toList`.
- **C sai:** `TreeMap` sắp xếp khoá tăng dần: 3 trước 4.
- **D sai:** `joining` giữ thứ tự gặp: `sun` trước `sky`.
- *Kiểm chứng:* `examples/questions/ch06/Q06_19/` — output confirmed (`python3 tools/book.py questions ch06`).

#### Câu 06-20 — Đáp án: **D**

- **Vì sao đúng:** Stream rỗng: `count()` = 0; `allMatch` = `true` (không có phần tử nào vi phạm); `anyMatch` = `false` (không có phần tử nào thoả).
- **A sai:** `allMatch` trên stream rỗng là `true`.
- **B sai:** `anyMatch` cần ít nhất một phần tử thoả; stream rỗng → `false`.
- **C sai:** Các method này không ném exception với stream rỗng.
- *Kiểm chứng:* `examples/questions/ch06/Q06_20/` — output confirmed (`python3 tools/book.py questions ch06`).
<!-- /ANSWERS -->

## Đọc thêm (link chính thức — bị chặn trong sandbox nên mình chưa mở được)

- Javadoc gói `java.util.stream`: https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/stream/package-summary.html
- JLS §15.27 Lambda Expressions, §15.13 Method Reference Expressions: https://docs.oracle.com/javase/specs/jls/se21/html/jls-15.html

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:

- `package-info.java` của `java.util.stream` (giải thích laziness, stateless, associativity, ordering): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/util/stream/package-info.java
- `Collectors.java`: https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/util/stream/Collectors.java
- `Optional.java`: https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/util/Optional.java
