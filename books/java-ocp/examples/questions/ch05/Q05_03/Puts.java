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
