// objective: 5.1
// Set: không trùng lặp. HashSet (không thứ tự), LinkedHashSet (thứ tự thêm), TreeSet (sắp xếp).
import java.util.*;

public class Ex05_Sets {
    public static void main(String[] args) {
        List<String> data = List.of("pear", "apple", "fig", "apple", "kiwi");
        Set<String> linked = new LinkedHashSet<>(data);
        TreeSet<String> tree = new TreeSet<>(data);
        System.out.println(linked + " " + tree);

        Set<Integer> hs = new HashSet<>();
        System.out.println(hs.add(5) + " " + hs.add(5) + " " + hs.size());   // add trả về false khi đã có

        TreeSet<Integer> t = new TreeSet<>(List.of(10, 20, 30, 40));
        System.out.println(t.first() + " " + t.last() + " " + t.floor(25) + " " + t.ceiling(25)
                + " " + t.lower(10) + " " + t.higher(40));
        System.out.println(t.headSet(30) + " " + t.tailSet(30) + " " + t.subSet(15, 35) + " " + t.descendingSet());

        TreeSet<String> byLength = new TreeSet<>(Comparator.comparing(String::length));
        byLength.addAll(List.of("aa", "b", "cc", "ddd"));       // "cc" bị coi là trùng "aa" (cùng độ dài)
        System.out.println(byLength);
        try {
            new TreeSet<Object>().add(null);
        } catch (NullPointerException e) {
            System.out.println("TreeSet không nhận null");
        }
    }
}
