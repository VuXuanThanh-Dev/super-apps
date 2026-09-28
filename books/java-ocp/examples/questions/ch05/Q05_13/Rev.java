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
