import java.util.*;

public class Group {
    public static void main(String[] args) {
        Map<String, List<Integer>> m = new TreeMap<>();
        for (String w : "b1 a2 b3 c4 a5".split(" "))
            m.computeIfAbsent(w.substring(0, 1), k -> new ArrayList<>()).add(Integer.parseInt(w.substring(1)));
        System.out.println(m + " " + m.getOrDefault("z", List.of()).size());
    }
}
