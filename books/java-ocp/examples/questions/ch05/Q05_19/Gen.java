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
