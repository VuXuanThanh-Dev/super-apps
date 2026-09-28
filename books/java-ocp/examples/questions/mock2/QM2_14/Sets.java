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
