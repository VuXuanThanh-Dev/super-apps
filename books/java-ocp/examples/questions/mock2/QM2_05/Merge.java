import java.util.*;
import java.util.stream.*;

public class Merge {
    public static void main(String[] args) {
        Map<Character, Integer> m = Stream.of("kiwi", "apple", "avocado", "kale", "banana")
                .collect(Collectors.toMap(s -> s.charAt(0), String::length, Integer::sum, LinkedHashMap::new));
        System.out.println(m);
    }
}
