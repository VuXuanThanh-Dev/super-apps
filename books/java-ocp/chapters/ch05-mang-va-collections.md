# Chương 5 — Mảng và Collections (Working with Arrays and Collections)

## Mục tiêu

Objective 5.1: tạo mảng (array), `List`, `Set`, `Map`, `Deque`; thêm, xoá, sửa, lấy và sắp xếp phần tử.
Để làm tốt phần này bạn cũng cần **generics** (kiểu tham số hoá) và `Comparable`/`Comparator`.

## Giải thích đơn giản

- **Mảng** có kích thước **cố định**, chứa primitive hoặc object, truy cập bằng chỉ số `a[i]`.
- **Collections Framework** là các cấu trúc dữ liệu co giãn được, chỉ chứa **object** (primitive được autoboxing):
  - `List` — có thứ tự, cho phép trùng (như `Array` trong TypeScript).
  - `Set` — không trùng (như `Set` trong JS).
  - `Map` — cặp key → value (như `Map` trong JS). `Map` **không** kế thừa `Collection`.
  - `Deque` — hàng đợi hai đầu: dùng làm stack (LIFO) hoặc queue (FIFO).
- **Generics** `List<String>` cho compiler biết kiểu phần tử, để kiểm tra lúc biên dịch.

| Interface | Cài đặt hay gặp | Thứ tự | null? |
|---|---|---|---|
| `List` | `ArrayList`, `LinkedList` | Theo chỉ số | Có |
| `Set` | `HashSet` | Không bảo đảm | Một `null` |
| | `LinkedHashSet` | Thứ tự thêm vào | Một `null` |
| | `TreeSet` | Sắp xếp (tự nhiên hoặc Comparator) | Không (với thứ tự tự nhiên) |
| `Map` | `HashMap` | Không bảo đảm | Một key `null`, value `null` |
| | `LinkedHashMap` | Thứ tự thêm vào | Như trên |
| | `TreeMap` | Sắp xếp theo key | Key `null`: không |
| `Deque` | `ArrayDeque` | Hai đầu | **Không** |
| | `LinkedList` | Hai đầu | Có |

## Ví dụ

Code trong `examples/ch05/`. Chạy lại: `python3 tools/book.py examples ch05`. Output thật, JDK 21.0.10.

### 1. Mảng

<!-- EX:Ex01_Arrays -->
`examples/ch05/Ex01_Arrays.java`

```java
// objective: 5.1
// Khai báo, khởi tạo mảng; giá trị mặc định; mảng nhiều chiều (có thể "răng cưa" - jagged).
import java.util.Arrays;

public class Ex01_Arrays {
    public static void main(String[] args) {
        int[] a = new int[3];                  // mặc định 0
        int b[] = {5, 6, 7};                   // cú pháp C, vẫn hợp lệ
        String[] names = new String[2];        // mặc định null
        int[] c = new int[]{1, 2};             // không được ghi kích thước khi có {..}
        System.out.println(Arrays.toString(a) + " " + Arrays.toString(b) + " "
                + Arrays.toString(names) + " " + c.length);

        int[][] grid = new int[2][3];
        int[][] jagged = {{1}, {2, 3}, {4, 5, 6}};
        int[][] lazy = new int[2][];           // chiều thứ hai chưa tạo
        lazy[0] = new int[]{9};
        System.out.println(grid[1].length + " " + jagged[2][1] + " " + Arrays.deepToString(jagged)
                + " " + lazy[1]);

        int[] ids, other;                      // cả hai là int[]
        int[] x, y[];                          // x là int[], y là int[][]
        y = new int[1][1];
        System.out.println(y[0][0] + " " + a.getClass().getSimpleName() + " " + (b instanceof Object));
        try {
            System.out.println(b[3]);
        } catch (ArrayIndexOutOfBoundsException e) {
            System.out.println(e.getMessage());
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
[0, 0, 0] [5, 6, 7] [null, null] 2
3 5 [[1], [2, 3], [4, 5, 6]] null
0 int[] true
Index 3 out of bounds for length 3
```
<!-- /EX -->

### 2. Lớp tiện ích `Arrays`

<!-- EX:Ex02_ArraysUtil -->
`examples/ch05/Ex02_ArraysUtil.java`

```java
// objective: 5.1
// Lớp tiện ích Arrays: sort, binarySearch, fill, copyOf, equals, compare, mismatch, asList.
import java.util.Arrays;
import java.util.List;

public class Ex02_ArraysUtil {
    public static void main(String[] args) {
        int[] nums = {40, 10, 30, 20};
        Arrays.sort(nums);
        System.out.println(Arrays.toString(nums));
        System.out.println(Arrays.binarySearch(nums, 30) + " " + Arrays.binarySearch(nums, 25)
                + " " + Arrays.binarySearch(nums, 5));        // không thấy: -(vị trí chèn) - 1

        String[] words = {"banana", "Apple", "cherry", "apple"};
        Arrays.sort(words);                                   // chữ HOA đứng trước chữ thường (theo Unicode)
        System.out.println(Arrays.toString(words));

        int[] copy = Arrays.copyOf(nums, 6);
        int[] range = Arrays.copyOfRange(nums, 1, 3);
        int[] filled = new int[3];
        Arrays.fill(filled, 7);
        System.out.println(Arrays.toString(copy) + " " + Arrays.toString(range) + " " + Arrays.toString(filled));

        int[] p = {1, 2, 3}, q = {1, 2, 3}, r = {1, 2, 4};
        System.out.println((p == q) + " " + p.equals(q) + " " + Arrays.equals(p, q)
                + " " + Arrays.compare(p, r) + " " + Arrays.mismatch(p, r) + " " + Arrays.mismatch(p, q));

        String[] backing = {"x", "y"};
        List<String> view = Arrays.asList(backing);          // list cố định kích thước, "nhìn" vào mảng
        view.set(0, "CHANGED");
        System.out.println(backing[0]);
        try {
            view.add("z");
        } catch (UnsupportedOperationException e) {
            System.out.println("asList: không add/remove được");
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
[10, 20, 30, 40]
2 -3 -1
[Apple, apple, banana, cherry]
[10, 20, 30, 40, 0, 0] [20, 30] [7, 7, 7]
false false true -1 2 -1
CHANGED
asList: không add/remove được
```
<!-- /EX -->

### 3. List

<!-- EX:Ex03_Lists -->
`examples/ch05/Ex03_Lists.java`

```java
// objective: 5.1
// ArrayList: add, set, get, remove(int) vs remove(Object), indexOf, contains, subList.
import java.util.ArrayList;
import java.util.List;

public class Ex03_Lists {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>();
        list.add("a");
        list.add("c");
        list.add(1, "b");                          // chèn tại chỉ số 1
        System.out.println(list + " size=" + list.size());
        String old = list.set(2, "C");             // set trả về phần tử cũ
        System.out.println(old + " -> " + list + " " + list.get(0) + " " + list.indexOf("z"));
        list.remove("a");                          // remove(Object)
        list.remove(0);                            // remove(int index)
        System.out.println(list + " " + list.contains("C") + " " + list.isEmpty());

        List<Integer> nums = new ArrayList<>(List.of(10, 20, 30, 40));
        nums.remove(1);                            // xoá CHỈ SỐ 1 (giá trị 20)!
        nums.remove(Integer.valueOf(40));          // xoá GIÁ TRỊ 40
        System.out.println(nums);

        List<Integer> big = new ArrayList<>(List.of(1, 2, 3, 4, 5));
        List<Integer> sub = big.subList(1, 3);     // view [2, 3]
        sub.set(0, 99);
        System.out.println(sub + " " + big);
        try {
            list.get(5);
        } catch (IndexOutOfBoundsException e) {
            System.out.println(e.getMessage());
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
[a, b, c] size=3
c -> [a, b, C] a -1
[C] true false
[10, 30]
[99, 3] [1, 99, 3, 4, 5]
Index 5 out of bounds for length 1
```
<!-- /EX -->

### 4. Sửa list khi đang duyệt

<!-- EX:Ex04_ModifyWhileIterating -->
`examples/ch05/Ex04_ModifyWhileIterating.java`

```java
// objective: 5.1
// Sửa list khi đang duyệt bằng for-each → ConcurrentModificationException; dùng removeIf hoặc Iterator.
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class Ex04_ModifyWhileIterating {
    public static void main(String[] args) {
        List<String> names = new ArrayList<>(List.of("An", "Binh", "Chi", "Dung"));
        try {
            for (String n : names) {
                if (n.startsWith("B")) names.remove(n);
            }
        } catch (java.util.ConcurrentModificationException e) {
            System.out.println("ConcurrentModificationException");
        }
        System.out.println(names);

        names.removeIf(n -> n.length() == 3);      // cách an toàn
        System.out.println(names);

        Iterator<String> it = names.iterator();
        while (it.hasNext()) {
            if (it.next().equals("An")) it.remove();   // xoá qua iterator: an toàn
        }
        System.out.println(names);

        List<Integer> nums = new ArrayList<>(List.of(1, 2, 3, 4));
        nums.replaceAll(x -> x * 10);
        System.out.println(nums);
    }
}
```

Output thật (JDK 21.0.10):

```text
ConcurrentModificationException
[An, Chi, Dung]
[An, Dung]
[Dung]
[10, 20, 30, 40]
```
<!-- /EX -->

### 5. Set

<!-- EX:Ex05_Sets -->
`examples/ch05/Ex05_Sets.java`

```java
// objective: 5.1
// Set: không trùng lặp. HashSet (không thứ tự), LinkedHashSet (thứ tự thêm), TreeSet (sắp xếp).
import java.util.*;

public class Ex05_Sets {
    public static void main(String[] args) {
        List<String> data = List.of("pear", "apple", "fig", "apple", "kiwi");
        Set<String> linked = new LinkedHashSet<>(data);
        TreeSet<String> tree = new TreeSet<>(data);
        System.out.println(linked + " " + tree);

        Set<Integer> hs = new HashSet<>();
        System.out.println(hs.add(5) + " " + hs.add(5) + " " + hs.size());   // add trả về false khi đã có

        TreeSet<Integer> t = new TreeSet<>(List.of(10, 20, 30, 40));
        System.out.println(t.first() + " " + t.last() + " " + t.floor(25) + " " + t.ceiling(25)
                + " " + t.lower(10) + " " + t.higher(40));
        System.out.println(t.headSet(30) + " " + t.tailSet(30) + " " + t.subSet(15, 35) + " " + t.descendingSet());

        TreeSet<String> byLength = new TreeSet<>(Comparator.comparing(String::length));
        byLength.addAll(List.of("aa", "b", "cc", "ddd"));       // "cc" bị coi là trùng "aa" (cùng độ dài)
        System.out.println(byLength);
        try {
            new TreeSet<Object>().add(null);
        } catch (NullPointerException e) {
            System.out.println("TreeSet không nhận null");
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
[pear, apple, fig, kiwi] [apple, fig, kiwi, pear]
true false 1
10 40 20 30 null null
[10, 20] [30, 40] [20, 30] [40, 30, 20, 10]
[b, aa, ddd]
TreeSet không nhận null
```
<!-- /EX -->

### 6. Map

<!-- EX:Ex06_Maps -->
`examples/ch05/Ex06_Maps.java`

```java
// objective: 5.1
// Map: put/get/getOrDefault/putIfAbsent/merge/compute; HashMap vs LinkedHashMap vs TreeMap.
import java.util.*;

public class Ex06_Maps {
    public static void main(String[] args) {
        Map<String, Integer> stock = new HashMap<>();
        System.out.println(stock.put("apple", 3) + " " + stock.put("apple", 5));   // null, rồi giá trị cũ 3
        stock.putIfAbsent("apple", 100);                  // đã có → không đổi
        stock.putIfAbsent("pear", 1);
        System.out.println(stock.get("apple") + " " + stock.get("none") + " " + stock.getOrDefault("none", 0));

        Map<String, Integer> counts = new TreeMap<>();
        for (String w : "b a c a b a".split(" ")) counts.merge(w, 1, Integer::sum);
        System.out.println(counts);                       // TreeMap: sắp xếp theo key

        counts.compute("a", (k, v) -> v == null ? 1 : v * 10);
        counts.computeIfAbsent("z", k -> 0);
        counts.computeIfPresent("b", (k, v) -> null);     // trả về null → xoá key
        System.out.println(counts + " " + counts.containsKey("b") + " " + counts.containsValue(0));

        for (Map.Entry<String, Integer> e : counts.entrySet()) System.out.print(e.getKey() + "=" + e.getValue() + ";");
        System.out.println(" keys=" + counts.keySet() + " values=" + counts.values());

        TreeMap<Integer, String> tm = new TreeMap<>(Map.of(1, "one", 5, "five", 9, "nine"));
        System.out.println(tm.firstKey() + " " + tm.floorKey(6) + " " + tm.headMap(5) + " " + tm.tailMap(5, true));

        Map<String, Integer> fixed = Map.of("k", 1);
        try {
            fixed.put("x", 2);
        } catch (UnsupportedOperationException e) {
            System.out.println("Map.of: không sửa được");
        }
        HashMap<String, String> nulls = new HashMap<>();
        nulls.put(null, "null key OK"); nulls.put("v", null);
        System.out.println(nulls.get(null) + " " + nulls.containsKey("v"));
    }
}
```

Output thật (JDK 21.0.10):

```text
null 3
5 null 0
{a=3, b=2, c=1}
{a=30, c=1, z=0} false true
a=30;c=1;z=0; keys=[a, c, z] values=[30, 1, 0]
1 5 {1=one} {5=five, 9=nine}
Map.of: không sửa được
null key OK true
```
<!-- /EX -->

### 7. Deque: stack và queue

<!-- EX:Ex07_Deque -->
`examples/ch05/Ex07_Deque.java`

```java
// objective: 5.1
// Deque (ArrayDeque): dùng như ngăn xếp (stack, LIFO) và hàng đợi (queue, FIFO).
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Queue;

public class Ex07_Deque {
    public static void main(String[] args) {
        Deque<String> stack = new ArrayDeque<>();
        stack.push("a"); stack.push("b"); stack.push("c");        // push = addFirst
        System.out.println(stack + " peek=" + stack.peek() + " pop=" + stack.pop() + " " + stack);

        Queue<String> queue = new ArrayDeque<>();
        queue.offer("1"); queue.offer("2"); queue.add("3");         // offer/add = addLast
        System.out.println(queue + " peek=" + queue.peek() + " poll=" + queue.poll() + " " + queue);

        Deque<Integer> d = new ArrayDeque<>();
        d.offerFirst(2); d.offerLast(3); d.addFirst(1);
        System.out.println(d + " " + d.peekFirst() + " " + d.peekLast() + " " + d.pollLast() + " " + d);

        Deque<Integer> empty = new ArrayDeque<>();
        System.out.println(empty.poll() + " " + empty.peek());      // null: "special value"
        try {
            empty.pop();                                             // hoặc remove()/element(): ném exception
        } catch (java.util.NoSuchElementException e) {
            System.out.println("NoSuchElementException");
        }
        try {
            empty.offer(null);
        } catch (NullPointerException e) {
            System.out.println("ArrayDeque không nhận null");
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
[c, b, a] peek=c pop=c [b, a]
[1, 2, 3] peek=1 poll=1 [2, 3]
[1, 2, 3] 1 3 3 [1, 2]
null null
NoSuchElementException
ArrayDeque không nhận null
```
<!-- /EX -->

### 8. Sắp xếp với Comparable và Comparator

<!-- EX:Ex08_Sorting -->
`examples/ch05/Ex08_Sorting.java`

```java
// objective: 5.1
// Sắp xếp: Comparable (thứ tự tự nhiên) và Comparator (thứ tự tuỳ chọn, nối chuỗi được).
import java.util.*;

public class Ex08_Sorting {
    record Student(String name, int score) implements Comparable<Student> {
        public int compareTo(Student o) { return name.compareTo(o.name); }   // tự nhiên: theo tên
    }

    public static void main(String[] args) {
        List<Student> list = new ArrayList<>(List.of(
                new Student("Chi", 8), new Student("An", 9), new Student("Binh", 8), new Student("Dung", 7)));
        Collections.sort(list);
        System.out.println(list.stream().map(Student::name).toList());

        list.sort(Comparator.comparingInt(Student::score).reversed().thenComparing(Student::name));
        System.out.println(list);

        List<String> words = new ArrayList<>(List.of("b", "B", "a", "A", "10", "9"));
        words.sort(null);                                   // null = thứ tự tự nhiên
        System.out.println(words);
        words.sort(String.CASE_INSENSITIVE_ORDER);
        System.out.println(words);
        words.sort(Comparator.reverseOrder());
        System.out.println(words);

        List<String> withNull = new ArrayList<>(Arrays.asList("b", null, "a"));
        withNull.sort(Comparator.nullsFirst(Comparator.naturalOrder()));
        System.out.println(withNull);
        System.out.println(Collections.max(List.of(3, 9, 2)) + " " + Collections.min(List.of("pear", "fig"), Comparator.comparing(String::length)));
    }
}
```

Output thật (JDK 21.0.10):

```text
[An, Binh, Chi, Dung]
[Student[name=An, score=9], Student[name=Binh, score=8], Student[name=Chi, score=8], Student[name=Dung, score=7]]
[10, 9, A, B, a, b]
[10, 9, A, a, B, b]
[b, a, B, A, 9, 10]
[null, a, b]
9 fig
```
<!-- /EX -->

### 9. Generics và wildcard

<!-- EX:Ex09_Generics -->
`examples/ch05/Ex09_Generics.java`

```java
// objective: 5.1
// Generics: lớp và method generic, wildcard ? extends (đọc) và ? super (ghi) — "PECS".
import java.util.ArrayList;
import java.util.List;

public class Ex09_Generics {
    static class Box<T> {
        private T value;
        Box(T value) { this.value = value; }
        T get() { return value; }
        <R> Box<R> map(java.util.function.Function<T, R> f) { return new Box<>(f.apply(value)); }
    }

    static <T extends Comparable<T>> T max(List<T> list) {      // bounded type parameter
        T best = list.get(0);
        for (T t : list) if (t.compareTo(best) > 0) best = t;
        return best;
    }

    static double sum(List<? extends Number> nums) {             // Producer Extends: chỉ đọc
        double s = 0;
        for (Number n : nums) s += n.doubleValue();
        return s;
    }

    static void fill(List<? super Integer> out) {                // Consumer Super: ghi Integer vào được
        for (int i = 1; i <= 3; i++) out.add(i);
    }

    public static void main(String[] args) {
        Box<String> b = new Box<>("hello");
        Box<Integer> len = b.map(String::length);
        System.out.println(b.get() + " " + len.get());
        System.out.println(max(List.of(3, 7, 5)) + " " + max(List.of("pear", "apple")));
        System.out.println(sum(List.of(1, 2.5, 3L)));
        List<Number> numbers = new ArrayList<>();
        List<Object> objects = new ArrayList<>();
        fill(numbers);
        fill(objects);
        System.out.println(numbers + " " + objects);
        List<?> unknown = List.of("x", 1);
        Object first = unknown.get(0);                           // đọc ra kiểu Object
        System.out.println(first + " " + (new ArrayList<String>().getClass() == new ArrayList<Integer>().getClass()));
    }
}
```

Output thật (JDK 21.0.10):

```text
hello 5
7 pear
6.5
[1, 2, 3] [1, 2, 3]
x true
```
<!-- /EX -->

### 10. Sequenced collections (Java 21)

<!-- EX:Ex10_Sequenced -->
`examples/ch05/Ex10_Sequenced.java`

```java
// objective: 5.1
// Sequenced collections (Java 21): getFirst/getLast/reversed/addFirst cho List, Deque, LinkedHashSet, LinkedHashMap.
import java.util.*;

public class Ex10_Sequenced {
    public static void main(String[] args) {
        List<Integer> list = new ArrayList<>(List.of(1, 2, 3));
        list.addFirst(0);
        list.addLast(4);
        System.out.println(list + " " + list.getFirst() + " " + list.getLast() + " " + list.reversed());

        LinkedHashSet<String> set = new LinkedHashSet<>(List.of("b", "c"));
        set.addFirst("a");
        set.addFirst("c");                          // đã có → chuyển lên đầu
        System.out.println(set + " " + set.reversed() + " " + set.removeLast());

        LinkedHashMap<String, Integer> map = new LinkedHashMap<>();
        map.put("x", 1); map.put("y", 2);
        map.putFirst("w", 0);
        System.out.println(map + " " + map.firstEntry() + " " + map.lastEntry() + " " + map.sequencedKeySet().reversed());

        List<Integer> view = list.reversed();       // reversed() là một VIEW, không phải bản sao
        list.set(0, 100);
        System.out.println(view);
        try {
            List.of(1, 2).addFirst(0);
        } catch (UnsupportedOperationException e) {
            System.out.println("List.of vẫn bất biến");
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
[0, 1, 2, 3, 4] 0 4 [4, 3, 2, 1, 0]
[c, a, b] [b, a, c] b
{w=0, x=1, y=2} w=0 y=2 [y, x, w]
[4, 3, 2, 1, 100]
List.of vẫn bất biến
```
<!-- /EX -->

### 11. Collection bất biến

<!-- EX:Ex11_Unmodifiable -->
`examples/ch05/Ex11_Unmodifiable.java`

```java
// objective: 5.1
// So sánh List.of, List.copyOf, Collections.unmodifiableList (view), Arrays.asList.
import java.util.*;

public class Ex11_Unmodifiable {
    public static void main(String[] args) {
        List<String> src = new ArrayList<>(List.of("a", "b"));
        List<String> view = Collections.unmodifiableList(src);   // view chỉ đọc: vẫn thấy thay đổi của src
        List<String> copy = List.copyOf(src);                    // bản sao bất biến
        src.add("c");
        System.out.println(view + " " + copy);

        try {
            List.of("a", null);
        } catch (NullPointerException e) {
            System.out.println("List.of không nhận null");
        }
        List<String> asList = Arrays.asList("x", null);          // asList nhận null
        System.out.println(asList + " contains null? " + asList.contains(null));

        Set<Integer> s = Set.of(3, 1, 2);
        System.out.println(s.size() + " " + s.contains(2));
        try {
            Set.of(1, 1);
        } catch (IllegalArgumentException e) {
            System.out.println("Set.of trùng phần tử → IllegalArgumentException");
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
[a, b, c] [a, b]
List.of không nhận null
[x, null] contains null? true
3 true
Set.of trùng phần tử → IllegalArgumentException
```
<!-- /EX -->

### 12. Lỗi generics hay gặp

<!-- EX:Ex12_GenericsErrors -->
`examples/ch05/Ex12_GenericsErrors.java`

```java
// objective: 5.1
// expect: compile-error
// Generics không "hiệp biến" (invariant): List<String> KHÔNG phải List<Object>; không thêm được vào ? extends.
import java.util.ArrayList;
import java.util.List;

public class Ex12_GenericsErrors {
    public static void main(String[] args) {
        List<String> strings = new ArrayList<>();
        List<Object> objects = strings;
        List<? extends Number> nums = new ArrayList<Integer>();
        nums.add(1);
        List<int> primitives = new ArrayList<>();
    }
}
```

Output thật của `javac` (JDK 21.0.10) — cố ý không biên dịch được:

```text
Ex12_GenericsErrors.java:10: error: incompatible types: List<String> cannot be converted to List<Object>
        List<Object> objects = strings;
                               ^
Ex12_GenericsErrors.java:12: error: incompatible types: int cannot be converted to CAP#1
        nums.add(1);
                 ^
  where CAP#1 is a fresh type-variable:
    CAP#1 extends Number from capture of ? extends Number
Ex12_GenericsErrors.java:13: error: unexpected type
        List<int> primitives = new ArrayList<>();
             ^
  required: reference
  found:    int
Note: Some messages have been simplified; recompile with -Xdiags:verbose to get full output
3 errors
```
<!-- /EX -->

## Đi sâu

### Mảng

- Khai báo: `int[] a`, `int a[]`, `int[] a, b` (cả hai là mảng), `int[] a, b[]` (b là mảng 2 chiều).
- Tạo: `new int[3]` (phải có kích thước), `new int[]{1, 2}` (không được có kích thước), `{1, 2}` (chỉ khi khai báo).
- Mảng là object: `a.length` (thuộc tính, không phải method), `a.equals(b)` là so sánh tham chiếu.
- `Arrays.sort` (số tăng dần; `String` theo Unicode: số < chữ HOA < chữ thường), `Arrays.binarySearch` (mảng phải
  đã sắp xếp; không thấy → `-(điểm chèn) - 1`), `Arrays.equals`, `Arrays.compare`, `Arrays.mismatch`
  (chỉ số khác đầu tiên, hoặc -1), `Arrays.fill`, `Arrays.copyOf`, `Arrays.asList` (fixed-size, ghi xuống mảng gốc).

### List

| Method | Ghi chú |
|---|---|
| `add(e)`, `add(i, e)` | `add(i, e)` chèn, đẩy phần tử sau lùi lại |
| `set(i, e)` | Thay thế, trả về phần tử cũ |
| `remove(int i)` vs `remove(Object o)` | Với `List<Integer>`, `remove(1)` xoá **chỉ số** 1 |
| `get(i)`, `indexOf`, `lastIndexOf`, `contains` | `indexOf` không thấy → -1 |
| `removeIf(pred)`, `replaceAll(op)`, `sort(cmp)` | `sort(null)` = thứ tự tự nhiên |
| `subList(from, to)` | View: sửa view là sửa list gốc |

Sửa cấu trúc list (add/remove) trong for-each → thường là `ConcurrentModificationException`. Dùng `removeIf` hoặc
`Iterator.remove()`.

### Set và TreeSet

`add` trả về `false` nếu phần tử đã có. `HashSet` dùng `hashCode` + `equals`; `TreeSet` dùng `compareTo`/`compare`
— hai phần tử so sánh bằng 0 bị coi là trùng, kể cả khi `equals` khác.

`TreeSet`/`NavigableSet`: `first`, `last`, `floor(x)` (≤), `ceiling(x)` (≥), `lower(x)` (<), `higher(x)` (>),
`pollFirst`, `pollLast`, `headSet(x)` (< x), `tailSet(x)` (≥ x), `subSet(a, b)` ([a, b)), `descendingSet`.

### Map

| Method | Trả về / hành vi |
|---|---|
| `put(k, v)` | Giá trị cũ hoặc `null` |
| `get(k)`, `getOrDefault(k, d)` | `null` nếu không có (hoặc giá trị là `null`) |
| `putIfAbsent(k, v)` | Chỉ thêm khi chưa có (hoặc đang là `null`); trả về giá trị hiện tại |
| `merge(k, v, f)` | Chưa có → đặt `v`; có → `f(cũ, v)`; kết quả `null` → xoá key |
| `compute`, `computeIfAbsent`, `computeIfPresent` | Hàm trả về `null` → xoá / không thêm |
| `keySet()`, `values()`, `entrySet()` | View của map |
| `containsKey`, `containsValue`, `remove(k)` | |

`TreeMap`: `firstKey`, `lastKey`, `floorKey`, `ceilingKey`, `headMap(k)` (< k), `tailMap(k)` (≥ k).

### Deque

| | Ném exception khi rỗng | Trả về giá trị đặc biệt (`null`/`false`) |
|---|---|---|
| Thêm đầu | `addFirst`, `push` | `offerFirst` |
| Thêm cuối | `addLast`, `add` | `offerLast`, `offer` |
| Lấy + xoá đầu | `removeFirst`, `remove`, `pop` | `pollFirst`, `poll` |
| Lấy + xoá cuối | `removeLast` | `pollLast` |
| Xem đầu | `getFirst`, `element` | `peekFirst`, `peek` |
| Xem cuối | `getLast` | `peekLast` |

Stack: `push`/`pop`/`peek` đều làm việc ở **đầu**. Queue: `offer` ở **cuối**, `poll`/`peek` ở **đầu**.

### Comparable vs Comparator

- `Comparable<T>` (trong lớp): `int compareTo(T o)` — "thứ tự tự nhiên". `String`, wrapper, `LocalDate`… đều có.
- `Comparator<T>` (bên ngoài): `int compare(T a, T b)`. Factory: `Comparator.comparing(keyExtractor)`,
  `comparingInt`, `thenComparing`, `reversed()` (đảo **toàn bộ** chuỗi so sánh đứng trước nó), `naturalOrder()`,
  `reverseOrder()`, `nullsFirst`/`nullsLast`.
- Quy ước: âm nếu `a` đứng trước, 0 nếu bằng, dương nếu đứng sau.

### Generics

- `class Box<T>`, method generic `static <T> T first(List<T> l)`, giới hạn `<T extends Comparable<T>>`.
- **Bất biến (invariant)**: `List<Integer>` không phải `List<Number>`.
- Wildcard: `List<?>` (chỉ đọc ra `Object`), `List<? extends Number>` (đọc `Number`, không thêm được trừ `null`),
  `List<? super Integer>` (thêm `Integer` được, đọc ra `Object`). Ghi nhớ **PECS**: *Producer Extends, Consumer Super*.
- Không dùng primitive làm tham số kiểu (`List<int>` lỗi). Diamond `<>` chỉ ở sau `new`.
- **Type erasure**: thông tin kiểu generic bị xoá lúc chạy → `new ArrayList<String>().getClass() == new ArrayList<Integer>().getClass()`.

### Collection bất biến

| Tạo bằng | Sửa được? | null? | Ghi chú |
|---|---|---|---|
| `List.of`, `Set.of`, `Map.of` | Không | Không | `Set.of`/`Map.of` trùng phần tử/key → `IllegalArgumentException` |
| `List.copyOf` | Không | Không | Bản sao |
| `Collections.unmodifiableList(l)` | Không (qua view) | Theo list gốc | **View**: thấy thay đổi của `l` |
| `Arrays.asList(...)` | `set` được, `add`/`remove` không | Có | Ghi xuống mảng gốc |

### Sequenced collections (Java 21)

Interface mới `SequencedCollection` (List, Deque, LinkedHashSet, SortedSet…) có `addFirst`, `addLast`, `getFirst`,
`getLast`, `removeFirst`, `removeLast`, `reversed()` (view). `SequencedMap` (LinkedHashMap, TreeMap…) có `putFirst`,
`putLast`, `firstEntry`, `lastEntry`, `pollFirstEntry`, `sequencedKeySet()`… Với collection bất biến, các method
thay đổi ném `UnsupportedOperationException`.

## Lỗi và bẫy thường gặp (Exam traps)

1. `List<Integer>.remove(1)` xoá chỉ số, không xoá giá trị 1.
2. `Arrays.asList(...).add(...)` → `UnsupportedOperationException`; `set` thì được.
3. `binarySearch` trên mảng chưa sắp xếp → kết quả không xác định.
4. Thứ tự `String`: chữ hoa trước chữ thường.
5. `TreeSet`/`TreeMap` với comparator: "bằng 0" là trùng.
6. `ArrayDeque`, `TreeMap` (key), `List.of` không nhận `null`.
7. `push` thêm **đầu**, `offer`/`add` thêm **cuối**.
8. `reversed()` của Comparator đảo cả phần phía trước nó; `thenComparing` sau `reversed()` không bị đảo.
9. `Collections.unmodifiableList` là view, `List.copyOf` là bản sao.
10. `List<Number> = new ArrayList<Integer>()` → lỗi; thêm vào `List<? extends ...>` → lỗi.
11. `new int[3]{1,2,3}` và `new int[]` → lỗi.
12. `Map` không phải `Collection`: không có `add`, không dùng for-each trực tiếp trên `Map`.

## Góc nhìn từ TypeScript

| TypeScript | Java | Ghi chú |
|---|---|---|
| `const a: number[] = []` (co giãn) | `int[]` (cố định) hoặc `List<Integer>` (co giãn) | Dùng `List` khi cần thêm/xoá |
| `arr.push(x)`, `arr.splice(i, 1)` | `list.add(x)`, `list.remove(i)` | |
| `arr.sort()` sắp xếp theo **chuỗi** mặc định | `Collections.sort` theo thứ tự tự nhiên (số là số) | `[10, 9].sort()` trong JS cho `[10, 9]` |
| `arr.sort((a, b) => a - b)` | `list.sort(Comparator.naturalOrder())` hoặc `(a, b) -> a - b` | Cẩn thận tràn số với `a - b` |
| `new Set()`, `new Map()` giữ thứ tự thêm | `LinkedHashSet`, `LinkedHashMap` | `HashSet`/`HashMap` không giữ thứ tự |
| `readonly T[]`, `ReadonlyArray<T>` (chỉ lúc biên dịch) | `List.of(...)` (bất biến thật lúc chạy) | |
| Generics bị xoá khi biên dịch | Generics cũng bị xoá (type erasure) | Giống nhau về ý tưởng |
| `Array<T>` hiệp biến (covariant) | `List<T>` bất biến (invariant) | Java dùng wildcard `? extends` |

## Tóm tắt

- Mảng cố định, `length`; `Arrays` cho sort/search/compare.
- List có chỉ số; Set không trùng; Map key → value; Deque hai đầu.
- Hash (không thứ tự), Linked (thứ tự thêm), Tree (sắp xếp).
- `Comparable` bên trong lớp; `Comparator` bên ngoài, nối chuỗi bằng `thenComparing`, `reversed`.
- Generics bất biến; PECS; không primitive; diamond chỉ sau `new`.
- Java 21: sequenced collections với `getFirst`/`getLast`/`reversed`.

## Bài tập (có lời giải)

Mọi đáp án đã được `tools/book.py` biên dịch và chạy để xác nhận (code: `examples/questions/ch05/`).

### Câu hỏi

<!-- QUESTIONS:ch05 -->
#### Câu 05-01 · Dễ · objective 5.1

Chương trình sau in ra gì?

```java
import java.util.*;

public class Remove {
    public static void main(String[] args) {
        List<Integer> list = new ArrayList<>(List.of(5, 1, 3, 1));
        list.remove(1);
        list.remove(Integer.valueOf(1));
        System.out.println(list);
    }
}
```

- **A.** `[5, 3]`
- **B.** `[5, 3, 1]`
- **C.** `[3, 1]`
- **D.** `[5, 1]`

#### Câu 05-02 · Vừa · objective 5.1

Chương trình sau in ra gì?

```java
import java.util.*;

public class Nav {
    public static void main(String[] args) {
        TreeSet<Integer> t = new TreeSet<>(List.of(8, 2, 6, 4));
        System.out.println(t.floor(5) + " " + t.higher(6) + " " + t.headSet(6) + " "
                + t.pollFirst() + " " + t);
    }
}
```

- **A.** `4 8 [2, 4, 6] 2 [4, 6, 8]`
- **B.** `6 8 [2, 4] 2 [2, 4, 6, 8]`
- **C.** `4 6 [2, 4] 2 [4, 6, 8]`
- **D.** `4 8 [2, 4] 2 [4, 6, 8]`

#### Câu 05-03 · Vừa · objective 5.1

Chương trình sau in ra gì?

```java
import java.util.*;

public class Puts {
    public static void main(String[] args) {
        Map<String, Integer> m = new HashMap<>();
        m.put("a", 1);
        Integer r1 = m.put("a", 2);
        Integer r2 = m.putIfAbsent("a", 3);
        Integer r3 = m.putIfAbsent("b", 4);
        m.merge("a", 10, (x, y) -> x + y);
        System.out.println(r1 + " " + r2 + " " + r3 + " " + m.get("a") + " " + m.get("b"));
    }
}
```

- **A.** `1 null null 12 4`
- **B.** `null 2 null 13 4`
- **C.** `1 2 null 12 4`
- **D.** `1 2 4 12 4`

#### Câu 05-04 · Vừa · objective 5.1

Chương trình sau in ra gì?

```java
import java.util.*;

public class Dq {
    public static void main(String[] args) {
        Deque<Integer> d = new ArrayDeque<>();
        d.push(1);
        d.offer(2);
        d.push(3);
        d.offerFirst(4);
        System.out.println(d.pop() + " " + d.pollLast() + " " + d.peek() + " " + d);
    }
}
```

- **A.** `1 4 2 [2, 3]`
- **B.** `4 2 1 [3, 1]`
- **C.** `2 4 3 [3, 1]`
- **D.** `4 2 3 [3, 1]`

#### Câu 05-05 · Khó · objective 5.1

Chương trình sau in ra gì?

```java
import java.util.*;

public class Search {
    public static void main(String[] args) {
        String[] arr = {"kiwi", "Fig", "apple", "Date"};
        Arrays.sort(arr);
        System.out.println(Arrays.toString(arr) + " " + Arrays.binarySearch(arr, "banana"));
    }
}
```

- **A.** `[apple, Date, Fig, kiwi] -2`
- **B.** `[Date, Fig, apple, kiwi] -4`
- **C.** `[Date, Fig, apple, kiwi] -3`
- **D.** `[apple, Date, Fig, kiwi] -3`

#### Câu 05-06 · Vừa · objective 5.1

Chèn dòng nào vào chỗ `// INSERT CODE HERE` thì chương trình biên dịch được? **(Chọn 3 đáp án.)**

```java
import java.util.*;

public class Wildcards {
    public static void main(String[] args) {
        // INSERT CODE HERE
    }
}
```

- **A.** `List<Number> a = new ArrayList<Integer>();`
- **B.** `List<? extends Number> b = new ArrayList<Integer>();`
- **C.** `List<? super Integer> c = new ArrayList<Number>();`
- **D.** `List<Object> d = new ArrayList<String>();`
- **E.** `ArrayList<> e = new ArrayList<String>();`
- **F.** `var f = new ArrayList<>();`

#### Câu 05-07 · Khó · objective 5.1

Kết quả của chương trình là gì?

```java
import java.util.*;

public class Cme {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>(List.of("a", "b", "c"));
        for (String s : list) {
            if (s.equals("b")) list.remove(s);
        }
        System.out.println(list);
    }
}
```

- **A.** In ra `[a, c]`
- **B.** Ném `ConcurrentModificationException`
- **C.** In ra `[a, b, c]`
- **D.** Không biên dịch được

#### Câu 05-08 · Vừa · objective 5.1

Chương trình sau in ra gì?

```java
import java.util.*;

public class Sorter {
    record P(String name, int age) { }

    public static void main(String[] args) {
        List<P> ps = new ArrayList<>(List.of(new P("Lan", 30), new P("An", 25),
                new P("Minh", 30), new P("Bao", 25)));
        ps.sort(Comparator.comparing(P::age).reversed().thenComparing(P::name));
        System.out.println(ps.stream().map(P::name).toList());
    }
}
```

- **A.** `[Minh, Lan, Bao, An]`
- **B.** `[An, Bao, Lan, Minh]`
- **C.** `[Lan, Minh, An, Bao]`
- **D.** `[Lan, Minh, Bao, An]`

#### Câu 05-09 · Dễ · objective 5.1

Kết quả của chương trình là gì?

```java
public class Jagged {
    public static void main(String[] args) {
        int[][] a = new int[3][];
        a[0] = new int[2];
        System.out.println(a.length + " " + a[0].length + " " + a[0][1] + " " + a[1]);
    }
}
```

- **A.** In ra `3 0 0 null`
- **B.** In ra `3 2 null null`
- **C.** Ném `NullPointerException`
- **D.** In ra `3 2 0 null`

#### Câu 05-10 · Vừa · objective 5.1

Hai phát biểu nào đúng? **(Chọn 2 đáp án.)**

- **A.** `HashMap` cho phép một key `null`.
- **B.** `TreeMap` (thứ tự tự nhiên) cho phép key `null`.
- **C.** `ArrayDeque` cho phép phần tử `null`.
- **D.** `List.of(...)` trả về list không thay đổi được.
- **E.** `LinkedHashSet` sắp xếp phần tử theo thứ tự tự nhiên.

#### Câu 05-11 · Khó · objective 5.1

Những dòng nào gây lỗi biên dịch?

```java
import java.util.*;

public class Wild {
    static void read(List<? extends Number> in) {
        Number n = in.get(0);            // L1
        in.add(null);                    // L2
        in.add(Integer.valueOf(1));      // L3
    }

    static void write(List<? super Integer> out) {
        out.add(5);                      // L4
        Integer i = out.get(0);          // L5
    }

    public static void main(String[] args) { }
}
```

- **A.** L2 và L3
- **B.** L3 và L5
- **C.** Chỉ L3
- **D.** L2, L3 và L5
- **E.** L4 và L5

#### Câu 05-12 · Vừa · objective 5.1

Chương trình sau in ra gì?

```java
import java.util.*;

public class Seq {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>(List.of("b", "c"));
        list.addFirst("a");
        List<String> rev = list.reversed();
        list.addLast("d");
        System.out.println(rev + " " + rev.getFirst() + " " + list.getLast());
    }
}
```

- **A.** `[c, b, a] c d`
- **B.** `[d, c, b, a] a d`
- **C.** `[d, c, b, a] d d`
- **D.** `[a, b, c, d] a d`

#### Câu 05-13 · Vừa · objective 5.1

Chương trình sau in ra gì?

```java
import java.util.*;

public class Rev {
    public static void main(String[] args) {
        TreeMap<String, Integer> m = new TreeMap<>(Comparator.reverseOrder());
        m.put("b", 2);
        m.put("a", 1);
        m.put("c", 3);
        System.out.println(m + " " + m.firstKey() + " " + m.headMap("b"));
    }
}
```

- **A.** `{a=1, b=2, c=3} a {a=1}`
- **B.** `{c=3, b=2, a=1} c {a=1}`
- **C.** `{c=3, b=2, a=1} a {c=3}`
- **D.** `{c=3, b=2, a=1} c {c=3}`

#### Câu 05-14 · Dễ · objective 5.1

Những dòng nào gây lỗi biên dịch?

```java
public class Decl {
    public static void main(String[] args) {
        int[] a = new int[3];            // L1
        int[] b = new int[3]{1, 2, 3};   // L2
        int c[] = {1, 2, 3};             // L3
        int[] d = new int[];             // L4
        int[][] e = new int[2][];        // L5
    }
}
```

- **A.** Chỉ L2
- **B.** L2 và L4
- **C.** L4 và L5
- **D.** L2, L4 và L5
- **E.** L3 và L4

#### Câu 05-15 · Khó · objective 5.1

Chương trình sau in ra gì?

```java
import java.util.*;

public class Custom {
    public static void main(String[] args) {
        TreeSet<String> set = new TreeSet<>(
                Comparator.comparing(String::length).thenComparing(Comparator.reverseOrder()));
        set.addAll(List.of("bb", "a", "ccc", "aa", "b"));
        System.out.println(set);
    }
}
```

- **A.** `[b, a, bb, aa, ccc]`
- **B.** `[a, b, aa, bb, ccc]`
- **C.** `[ccc, bb, aa, b, a]`
- **D.** `[a, aa, b, bb, ccc]`

#### Câu 05-16 · Vừa · objective 5.1

Hai phát biểu nào đúng về lớp `Arrays`? **(Chọn 2 đáp án.)**

- **A.** `Arrays.asList` trả về list cố định kích thước nhưng vẫn gọi `set()` được.
- **B.** `Arrays.equals(a, b)` so sánh tham chiếu của hai mảng.
- **C.** `Arrays.binarySearch` trên mảng chưa sắp xếp luôn trả về -1.
- **D.** `Arrays.compare` trả về số âm nếu mảng thứ nhất nhỏ hơn theo thứ tự từ điển.
- **E.** Sau `int[] a = {};` thì `a.length` bằng 1.

#### Câu 05-17 · Vừa · objective 5.1

Chương trình sau in ra gì?

```java
import java.util.*;

public class Views {
    public static void main(String[] args) {
        List<String> src = new ArrayList<>(List.of("x"));
        List<String> v = Collections.unmodifiableList(src);
        List<String> c = List.copyOf(src);
        src.add("y");
        System.out.println(v.size() + " " + c.size());
    }
}
```

- **A.** `1 1`
- **B.** `2 2`
- **C.** `2 1`
- **D.** `1 2`

#### Câu 05-18 · Khó · objective 5.1

Đoạn code nào, chèn vào chỗ `// INSERT CODE HERE`, in ra `[3, 2, 1]`? **(Chọn 3 đáp án.)**

```java
import java.util.*;

public class Reverse {
    public static void main(String[] args) {
        List<Integer> list = new ArrayList<>(List.of(1, 2, 3));
        // INSERT CODE HERE
    }
}
```

- **A.** `Collections.reverse(list); System.out.println(list);`
- **B.** `System.out.println(list.reversed());`
- **C.** `list.sort(Comparator.reverseOrder()); System.out.println(list);`
- **D.** `Collections.sort(list); System.out.println(list);`
- **E.** `Deque<Integer> d = new ArrayDeque<>(list); System.out.println(d);`

#### Câu 05-19 · Vừa · objective 5.1

Những dòng nào gây lỗi biên dịch?

```java
import java.util.*;

public class Gen {
    static <T> T first(List<T> list) { return list.get(0); }

    public static void main(String[] args) {
        List<String> names = new ArrayList<>();                // L1
        String s = first(names);                               // L2
        Integer i = first(names);                              // L3
        Map<String, List<Integer>> m = new HashMap<>();        // L4
        List<> bad = new ArrayList<String>();                  // L5
    }
}
```

- **A.** Chỉ L3
- **B.** L3 và L5
- **C.** L2 và L3
- **D.** L4 và L5
- **E.** Chỉ L5

#### Câu 05-20 · Dễ · objective 5.1

Chương trình sau in ra gì?

```java
import java.util.*;

public class Adds {
    public static void main(String[] args) {
        List<String> l = new ArrayList<>();
        l.add("x");
        l.add(0, "y");
        l.add("z");
        l.set(1, "w");
        System.out.println(l + " " + l.indexOf("z"));
    }
}
```

- **A.** `[y, w, z] 2`
- **B.** `[w, x, z] 2`
- **C.** `[y, x, w] -1`
- **D.** `[y, w, x, z] 3`
<!-- /QUESTIONS -->

### Lời giải

<!-- ANSWERS:ch05 -->
#### Câu 05-01 — Đáp án: **A** (Dễ · objective 5.1)

- **Vì sao đúng:** `remove(1)` với tham số `int` gọi `remove(int index)` → xoá phần tử ở chỉ số 1 (giá trị 1) → `[5, 3, 1]`. `remove(Integer.valueOf(1))` gọi `remove(Object)` → xoá lần xuất hiện đầu tiên của giá trị 1 → `[5, 3]`.
- **B sai:** Lời gọi thứ hai xoá giá trị 1 còn lại.
- **C sai:** `remove(1)` xoá theo chỉ số, không xoá phần tử đầu tiên.
- **D sai:** `remove(1)` xoá phần tử ở chỉ số 1 chứ không phải giá trị 3.
- *Kiểm chứng:* `examples/questions/ch05/Q05_01/` — output confirmed (`python3 tools/book.py questions ch05`).

#### Câu 05-02 — Đáp án: **D** (Vừa · objective 5.1)

- **Vì sao đúng:** `floor(5)` = phần tử lớn nhất ≤ 5 → 4. `higher(6)` = nhỏ nhất > 6 → 8. `headSet(6)` = các phần tử **nhỏ hơn** 6 (không gồm 6) → [2, 4]. `pollFirst()` lấy **và xoá** 2, nên set còn [4, 6, 8]. Biểu thức tính từ trái sang phải nên `headSet` được in trước khi `pollFirst` chạy.
- **A sai:** `headSet(6)` mặc định không gồm 6.
- **B sai:** `floor(5)` phải ≤ 5; và `pollFirst()` đã xoá 2 khỏi set.
- **C sai:** `higher(6)` là phần tử lớn hơn hẳn 6, tức 8.
- *Kiểm chứng:* `examples/questions/ch05/Q05_02/` — output confirmed (`python3 tools/book.py questions ch05`).

#### Câu 05-03 — Đáp án: **C** (Vừa · objective 5.1)

- **Vì sao đúng:** `put` trả về giá trị **cũ** (1). `putIfAbsent` khi key đã có: không đổi và trả về giá trị hiện tại (2). Khi key chưa có: thêm và trả về `null`. `merge("a", 10, sum)` → 2 + 10 = 12.
- **A sai:** `putIfAbsent` trả về giá trị đang có (2) khi key đã tồn tại.
- **B sai:** `put` lần hai trả về giá trị cũ 1; `putIfAbsent("a", 3)` không ghi đè nên merge tính 2 + 10.
- **D sai:** `putIfAbsent` trả về `null` khi vừa thêm key mới.
- *Kiểm chứng:* `examples/questions/ch05/Q05_03/` — output confirmed (`python3 tools/book.py questions ch05`).

#### Câu 05-04 — Đáp án: **D** (Vừa · objective 5.1)

- **Vì sao đúng:** `push` = `addFirst`, `offer` = `addLast`. Sau 4 lệnh: [4, 3, 1, 2]. `pop()` lấy đầu → 4. `pollLast()` lấy cuối → 2. `peek()` xem đầu (không xoá) → 3. Còn lại [3, 1].
- **A sai:** `push` thêm vào **đầu** deque, không phải cuối.
- **B sai:** Sau khi `pop()` lấy 4, phần tử đầu là 3.
- **C sai:** `pop()` lấy từ đầu (4), `pollLast()` lấy từ cuối (2).
- *Kiểm chứng:* `examples/questions/ch05/Q05_04/` — output confirmed (`python3 tools/book.py questions ch05`).

#### Câu 05-05 — Đáp án: **B** (Khó · objective 5.1)

- **Vì sao đúng:** Thứ tự tự nhiên của `String` theo mã Unicode: chữ HOA (`D`, `F`) đứng trước chữ thường. `"banana"` sẽ chèn vào giữa `apple` (chỉ số 2) và `kiwi` (chỉ số 3), nên vị trí chèn là 3; không tìm thấy → `-(3) - 1 = -4`.
- **A sai:** Sắp xếp `String` phân biệt hoa thường: chữ hoa trước.
- **C sai:** Công thức khi không thấy là `-(insertion point) - 1`, tức -4 chứ không phải -3.
- **D sai:** Sai cả thứ tự sắp xếp lẫn giá trị trả về.
- *Kiểm chứng:* `examples/questions/ch05/Q05_05/` — output confirmed (`python3 tools/book.py questions ch05`).

#### Câu 05-06 — Đáp án: **B, C, F** (Vừa · objective 5.1)

- **Vì sao đúng:** Generics bất biến (invariant): `List<Number>` không nhận `ArrayList<Integer>`. Wildcard nới lỏng: `? extends Number` nhận list của bất kỳ lớp con nào của `Number` (B); `? super Integer` nhận list của `Integer` hoặc lớp cha (C). `var` với diamond suy ra `ArrayList<Object>` (F).
- **A sai:** `ArrayList<Integer>` không phải `List<Number>` dù `Integer` là `Number`.
- **D sai:** `ArrayList<String>` không phải `List<Object>`.
- **E sai:** Diamond `<>` chỉ dùng ở vế phải (sau `new`).
- *Kiểm chứng:* `examples/questions/ch05/Q05_06/` — variants: BCF satisfy compiles (`python3 tools/book.py questions ch05`).

#### Câu 05-07 — Đáp án: **A** (Khó · objective 5.1)

- **Vì sao đúng:** Bẫy khó: xoá phần tử **áp chót** (`b`) thì không có exception. Sau khi xoá, list còn 2 phần tử và vị trí con trỏ của iterator là 2, nên `hasNext()` trả về `false` và vòng lặp kết thúc trước khi `next()` kịp kiểm tra thay đổi. Đây là hành vi của cài đặt `ArrayList` — **đừng dựa vào nó** trong code thật; hãy dùng `removeIf` hoặc `Iterator.remove`.
- **B sai:** `ConcurrentModificationException` chỉ ném khi `next()` được gọi sau khi list bị sửa; ở đây vòng lặp đã dừng.
- **C sai:** `list.remove(s)` có chạy và xoá `b`.
- **D sai:** Sửa list trong for-each là lỗi lúc chạy (nếu có), không phải lỗi biên dịch.
- *Kiểm chứng:* `examples/questions/ch05/Q05_07/` — output confirmed (`python3 tools/book.py questions ch05`).

#### Câu 05-08 — Đáp án: **C** (Vừa · objective 5.1)

- **Vì sao đúng:** `comparing(P::age).reversed()` → tuổi giảm dần (30 trước 25). `thenComparing(P::name)` áp dụng **sau** `reversed()` nên tên vẫn tăng dần: Lan, Minh (30), rồi An, Bao (25).
- **A sai:** `reversed()` chỉ đảo phần so sánh theo tuổi đứng trước nó; tên vẫn tăng dần.
- **B sai:** `reversed()` làm tuổi giảm dần, nên nhóm 30 đứng trước.
- **D sai:** Trong nhóm 25, tên tăng dần: An trước Bao.
- *Kiểm chứng:* `examples/questions/ch05/Q05_08/` — output confirmed (`python3 tools/book.py questions ch05`).

#### Câu 05-09 — Đáp án: **D** (Dễ · objective 5.1)

- **Vì sao đúng:** `new int[3][]` tạo mảng ngoài 3 phần tử, mỗi phần tử (mảng con) mặc định `null`. `a[0]` được gán mảng 2 phần tử `int` (mặc định 0). In `a[1]` (là `null`) không gây NPE vì chỉ nối chuỗi, không truy cập phần tử.
- **A sai:** `a[0]` là mảng 2 phần tử nên `a[0].length` là 2.
- **B sai:** Phần tử của `int[]` mặc định là 0, không phải `null`.
- **C sai:** Nối `null` vào chuỗi in ra chữ `null`; không có truy cập `a[1][...]`.
- *Kiểm chứng:* `examples/questions/ch05/Q05_09/` — output confirmed (`python3 tools/book.py questions ch05`).

#### Câu 05-10 — Đáp án: **A, D** (Vừa · objective 5.1)

- **Vì sao đúng:** A: `HashMap` cho phép một key `null` (và nhiều value `null`). D: `List.of` trả về list bất biến; `add` ném `UnsupportedOperationException`.
- **B sai:** `TreeMap` phải so sánh key; so sánh `null` theo thứ tự tự nhiên ném `NullPointerException`.
- **C sai:** `ArrayDeque` dùng `null` làm tín hiệu "rỗng", nên cấm phần tử `null`.
- **E sai:** `LinkedHashSet` giữ **thứ tự thêm vào**; sắp xếp là việc của `TreeSet`.
- *Kiểm chứng:* `examples/questions/ch05/Q05_10/` — each option proven true/false by a program (`python3 tools/book.py questions ch05`).

#### Câu 05-11 — Đáp án: **B** (Khó · objective 5.1)

- **Vì sao đúng:** `? extends Number`: đọc ra được `Number` (L1) nhưng **không thêm** được gì ngoài `null` (L2 hợp lệ, L3 lỗi), vì list thật có thể là `List<Double>`. `? super Integer`: thêm `Integer` được (L4), nhưng đọc ra chỉ biết là `Object` (L5 lỗi).
- **A sai:** Thêm `null` luôn hợp lệ vì `null` thuộc mọi kiểu tham chiếu.
- **C sai:** L5 cũng lỗi: `out.get(0)` có kiểu `Object`.
- **D sai:** L2 hợp lệ (xem A).
- **E sai:** `? super Integer` cho phép thêm `Integer` → L4 hợp lệ.
- *Kiểm chứng:* `examples/questions/ch05/Q05_11/` — compile error confirmed at ['L3', 'L5'] (`python3 tools/book.py questions ch05`).

#### Câu 05-12 — Đáp án: **C** (Vừa · objective 5.1)

- **Vì sao đúng:** Java 21 thêm `SequencedCollection`: `addFirst`, `addLast`, `getFirst`, `getLast`, `reversed`. `reversed()` trả về một **view** đảo ngược, nên thay đổi sau đó (`addLast("d")`) vẫn thấy được. `rev` là [d, c, b, a].
- **A sai:** `reversed()` là view, không phải bản sao; nó thấy cả `d` được thêm sau.
- **B sai:** Phần tử đầu của view đảo ngược là phần tử cuối của list: `d`.
- **D sai:** `rev` là thứ tự đảo ngược của list.
- *Kiểm chứng:* `examples/questions/ch05/Q05_12/` — output confirmed (`python3 tools/book.py questions ch05`).

#### Câu 05-13 — Đáp án: **D** (Vừa · objective 5.1)

- **Vì sao đúng:** `TreeMap` sắp xếp theo comparator được truyền vào: ngược thứ tự tự nhiên → c, b, a. `firstKey()` là key đầu theo thứ tự đó (`c`). `headMap("b")` = các key đứng **trước** `b` theo thứ tự của map → chỉ `c`.
- **A sai:** Comparator `reverseOrder()` đảo thứ tự: c đứng đầu.
- **B sai:** `headMap` dùng thứ tự của map (c, b, a), nên phần đứng trước `b` là `c`.
- **C sai:** `firstKey()` là `c` theo thứ tự của map.
- *Kiểm chứng:* `examples/questions/ch05/Q05_13/` — output confirmed (`python3 tools/book.py questions ch05`).

#### Câu 05-14 — Đáp án: **B** (Dễ · objective 5.1)

- **Vì sao đúng:** Khi có danh sách giá trị `{...}` thì **không** được ghi kích thước (L2 lỗi). Khi không có danh sách giá trị thì **phải** ghi kích thước (L4 lỗi). L3 dùng cú pháp kiểu C (`int c[]`) vẫn hợp lệ. L5 chỉ cần kích thước chiều đầu.
- **A sai:** L4 cũng lỗi: `new int[]` thiếu kích thước.
- **C sai:** L5 hợp lệ: mảng nhiều chiều chỉ bắt buộc kích thước chiều đầu tiên.
- **D sai:** L5 hợp lệ (xem C).
- **E sai:** `int c[] = {...}` là cú pháp hợp lệ.
- *Kiểm chứng:* `examples/questions/ch05/Q05_14/` — compile error confirmed at ['L2', 'L4'] (`python3 tools/book.py questions ch05`).

#### Câu 05-15 — Đáp án: **A** (Khó · objective 5.1)

- **Vì sao đúng:** So sánh theo độ dài trước (1, 2, 3), cùng độ dài thì theo thứ tự chữ **ngược** (`b` trước `a`, `bb` trước `aa`).
- **B sai:** Tiêu chí thứ hai là `reverseOrder()`, nên cùng độ dài thì `b` đứng trước `a`.
- **C sai:** Độ dài được so sánh tăng dần (không có `reversed()` cho độ dài).
- **D sai:** Tiêu chí đầu tiên là độ dài, không phải chữ cái.
- *Kiểm chứng:* `examples/questions/ch05/Q05_15/` — output confirmed (`python3 tools/book.py questions ch05`).

#### Câu 05-16 — Đáp án: **A, D** (Vừa · objective 5.1)

- **Vì sao đúng:** A: list của `asList` "nhìn" vào mảng gốc: `set` được (ghi xuống mảng), `add`/`remove` thì không. D: `Arrays.compare` so sánh từng phần tử theo thứ tự từ điển, trả về âm/0/dương.
- **B sai:** `Arrays.equals` so sánh **nội dung** từng phần tử; `==` mới so sánh tham chiếu.
- **C sai:** Với mảng chưa sắp xếp, kết quả là **không xác định (undefined)**, không phải luôn -1 (ví dụ ở đây là -4).
- **E sai:** `{}` là mảng rỗng, độ dài 0.
- *Kiểm chứng:* `examples/questions/ch05/Q05_16/` — each option proven true/false by a program (`python3 tools/book.py questions ch05`).

#### Câu 05-17 — Đáp án: **C** (Vừa · objective 5.1)

- **Vì sao đúng:** `Collections.unmodifiableList` trả về một **view** chỉ đọc của list gốc: list gốc đổi thì view thấy. `List.copyOf` tạo **bản sao** bất biến tại thời điểm gọi.
- **A sai:** View `v` phản ánh thay đổi của `src`.
- **B sai:** `List.copyOf` là bản sao, không thấy phần tử thêm sau.
- **D sai:** Ngược lại: view thay đổi theo, bản sao thì không.
- *Kiểm chứng:* `examples/questions/ch05/Q05_17/` — output confirmed (`python3 tools/book.py questions ch05`).

#### Câu 05-18 — Đáp án: **A, B, C** (Khó · objective 5.1)

- **Vì sao đúng:** A đảo list tại chỗ. B dùng view đảo ngược của Java 21. C sắp xếp giảm dần.
- **D sai:** `Collections.sort` sắp xếp tăng dần → `[1, 2, 3]`.
- **E sai:** `ArrayDeque` giữ thứ tự của list nguồn khi in → `[1, 2, 3]`.
- *Kiểm chứng:* `examples/questions/ch05/Q05_18/` — variants: ABC satisfy output (`python3 tools/book.py questions ch05`).

#### Câu 05-19 — Đáp án: **B** (Vừa · objective 5.1)

- **Vì sao đúng:** Với `List<String>`, `T` được suy ra là `String`, nên kết quả không gán cho `Integer` được (L3). Diamond `<>` chỉ được dùng sau `new`, không dùng ở kiểu khai báo (L5). L4 dùng diamond đúng cách.
- **A sai:** L5 cũng lỗi: `List<>` ở vế trái không hợp lệ.
- **C sai:** L2 hợp lệ: `T` = `String`.
- **D sai:** L4 hợp lệ: diamond suy ra `HashMap<String, List<Integer>>`.
- **E sai:** L3 cũng lỗi: không gán `String` cho `Integer`.
- *Kiểm chứng:* `examples/questions/ch05/Q05_19/` — compile error confirmed at ['L3', 'L5'] (`python3 tools/book.py questions ch05`).

#### Câu 05-20 — Đáp án: **A** (Dễ · objective 5.1)

- **Vì sao đúng:** [x] → `add(0, "y")` chèn đầu → [y, x] → thêm cuối → [y, x, z] → `set(1, "w")` **thay** phần tử ở chỉ số 1 → [y, w, z]. `indexOf("z")` = 2.
- **B sai:** `add(0, "y")` chèn `y` vào đầu, sau đó `set(1, ...)` thay `x` chứ không thay `y`.
- **C sai:** `set(1, ...)` thay chỉ số 1 (là `x`), không phải chỉ số 2.
- **D sai:** `set` thay thế, không chèn thêm.
- *Kiểm chứng:* `examples/questions/ch05/Q05_20/` — output confirmed (`python3 tools/book.py questions ch05`).
<!-- /ANSWERS -->

## Đọc thêm (link chính thức — bị chặn trong sandbox nên mình chưa mở được)

- Javadoc `java.util` (Collections Framework): https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/package-summary.html
- JEP 431 Sequenced Collections: https://openjdk.org/jeps/431

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:

- `SequencedCollection.java`: https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/util/SequencedCollection.java
- `Arrays.java` (`binarySearch`, `asList`, `mismatch`): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/util/Arrays.java
- `ArrayDeque.java` (cấm phần tử null): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/util/ArrayDeque.java
- `Deque.java` (bảng method ném exception / trả giá trị đặc biệt): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/util/Deque.java
