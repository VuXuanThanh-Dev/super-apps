import java.util.*;
import java.util.stream.*;

public class Chars {
    public static void main(String[] args) {
        String r = Stream.of("delta", "alpha", "charlie", "bravo")
                .filter(s -> s.length() == 5)
                .map(s -> s.charAt(0))
                .sorted(Comparator.reverseOrder())
                .map(String::valueOf)
                .collect(Collectors.joining());
        System.out.println(r);
    }
}
