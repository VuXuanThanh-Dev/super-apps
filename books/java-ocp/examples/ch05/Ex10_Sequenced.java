// objective: 5.1
// Sequenced collections (Java 21): getFirst/getLast/reversed/addFirst cho List, Deque, LinkedHashSet, LinkedHashMap.
import java.util.*;

public class Ex10_Sequenced {
    public static void main(String[] args) {
        List<Integer> list = new ArrayList<>(List.of(1, 2, 3));
        list.addFirst(0);
        list.addLast(4);
        System.out.println(list + " " + list.getFirst() + " " + list.getLast() + " " + list.reversed());

        LinkedHashSet<String> set = new LinkedHashSet<>(List.of("b", "c"));
        set.addFirst("a");
        set.addFirst("c");                          // đã có → chuyển lên đầu
        System.out.println(set + " " + set.reversed() + " " + set.removeLast());

        LinkedHashMap<String, Integer> map = new LinkedHashMap<>();
        map.put("x", 1); map.put("y", 2);
        map.putFirst("w", 0);
        System.out.println(map + " " + map.firstEntry() + " " + map.lastEntry() + " " + map.sequencedKeySet().reversed());

        List<Integer> view = list.reversed();       // reversed() là một VIEW, không phải bản sao
        list.set(0, 100);
        System.out.println(view);
        try {
            List.of(1, 2).addFirst(0);
        } catch (UnsupportedOperationException e) {
            System.out.println("List.of vẫn bất biến");
        }
    }
}
