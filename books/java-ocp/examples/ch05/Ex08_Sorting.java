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
