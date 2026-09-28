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
