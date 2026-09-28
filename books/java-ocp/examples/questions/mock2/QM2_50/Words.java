import java.util.*;
import java.util.stream.*;

public class Words {
    public static void main(String[] args) {
        List<String> words = List.of("sun", "sea", "sky", "moon", "mars", "star");
        Map<Character, String> m = words.stream().collect(Collectors.groupingBy(w -> w.charAt(0), TreeMap::new,
                Collectors.mapping(String::toUpperCase, Collectors.joining("/"))));
        Map<Integer, Long> byLen = words.stream().collect(
                Collectors.groupingBy(String::length, TreeMap::new, Collectors.counting()));
        System.out.println(m + " " + byLen);
    }
}
