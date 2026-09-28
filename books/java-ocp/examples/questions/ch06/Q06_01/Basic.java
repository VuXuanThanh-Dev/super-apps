import java.util.*;
import java.util.stream.*;

public class Basic {
    public static void main(String[] args) {
        List<String> r = Stream.of("pear", "fig", "apple", "kiwi")
                .filter(s -> s.length() > 3)
                .map(String::toUpperCase)
                .sorted()
                .toList();
        System.out.println(r);
    }
}
