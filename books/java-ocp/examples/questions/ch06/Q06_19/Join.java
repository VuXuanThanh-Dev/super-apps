import java.util.*;
import java.util.stream.*;

public class Join {
    public static void main(String[] args) {
        Map<Integer, String> m = Stream.of("sun", "moon", "sky", "star")
                .collect(Collectors.groupingBy(String::length, TreeMap::new, Collectors.joining("+")));
        System.out.println(m);
    }
}
