import java.util.*;
import java.util.stream.*;

public class Groups {
    record Item(String cat, int price) { }

    public static void main(String[] args) {
        Map<Boolean, Map<String, Long>> m = Stream.of(
                new Item("a", 5), new Item("b", 20), new Item("a", 30), new Item("c", 1))
            .collect(Collectors.partitioningBy(i -> i.price() > 10,
                    Collectors.groupingBy(Item::cat, TreeMap::new, Collectors.counting())));
        System.out.println(m);
    }
}
