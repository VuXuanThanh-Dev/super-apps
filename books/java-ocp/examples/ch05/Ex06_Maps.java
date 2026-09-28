// objective: 5.1
// Map: put/get/getOrDefault/putIfAbsent/merge/compute; HashMap vs LinkedHashMap vs TreeMap.
import java.util.*;

public class Ex06_Maps {
    public static void main(String[] args) {
        Map<String, Integer> stock = new HashMap<>();
        System.out.println(stock.put("apple", 3) + " " + stock.put("apple", 5));   // null, rồi giá trị cũ 3
        stock.putIfAbsent("apple", 100);                  // đã có → không đổi
        stock.putIfAbsent("pear", 1);
        System.out.println(stock.get("apple") + " " + stock.get("none") + " " + stock.getOrDefault("none", 0));

        Map<String, Integer> counts = new TreeMap<>();
        for (String w : "b a c a b a".split(" ")) counts.merge(w, 1, Integer::sum);
        System.out.println(counts);                       // TreeMap: sắp xếp theo key

        counts.compute("a", (k, v) -> v == null ? 1 : v * 10);
        counts.computeIfAbsent("z", k -> 0);
        counts.computeIfPresent("b", (k, v) -> null);     // trả về null → xoá key
        System.out.println(counts + " " + counts.containsKey("b") + " " + counts.containsValue(0));

        for (Map.Entry<String, Integer> e : counts.entrySet()) System.out.print(e.getKey() + "=" + e.getValue() + ";");
        System.out.println(" keys=" + counts.keySet() + " values=" + counts.values());

        TreeMap<Integer, String> tm = new TreeMap<>(Map.of(1, "one", 5, "five", 9, "nine"));
        System.out.println(tm.firstKey() + " " + tm.floorKey(6) + " " + tm.headMap(5) + " " + tm.tailMap(5, true));

        Map<String, Integer> fixed = Map.of("k", 1);
        try {
            fixed.put("x", 2);
        } catch (UnsupportedOperationException e) {
            System.out.println("Map.of: không sửa được");
        }
        HashMap<String, String> nulls = new HashMap<>();
        nulls.put(null, "null key OK"); nulls.put("v", null);
        System.out.println(nulls.get(null) + " " + nulls.containsKey("v"));
    }
}
