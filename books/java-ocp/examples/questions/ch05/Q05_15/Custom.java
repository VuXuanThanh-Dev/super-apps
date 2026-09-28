import java.util.*;

public class Custom {
    public static void main(String[] args) {
        TreeSet<String> set = new TreeSet<>(
                Comparator.comparing(String::length).thenComparing(Comparator.reverseOrder()));
        set.addAll(List.of("bb", "a", "ccc", "aa", "b"));
        System.out.println(set);
    }
}
