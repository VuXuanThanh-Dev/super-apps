import java.util.*;
import java.util.stream.*;

public class ToMap {
    public static void main(String[] args) {
        Map<Integer, String> m = Stream.of("aa", "b", "cc", "ddd", "e")
                .collect(Collectors.toMap(String::length, s -> s, (x, y) -> x + y, TreeMap::new));
        System.out.println(m);
    }
}
