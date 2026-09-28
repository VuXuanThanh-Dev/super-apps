import java.util.*;
public class P { public static void main(String[] a) {
    Map<String, Integer> m = new HashMap<>(Map.of("k", 1));
    m.merge("k", 5, (x, y) -> null);
    System.out.println(m.containsKey("k")); } }
