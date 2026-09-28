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
