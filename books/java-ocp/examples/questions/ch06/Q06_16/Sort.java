import java.util.*;
import java.util.stream.*;

public class Sort {
    public static void main(String[] args) {
        List<Integer> r = Stream.of("10", "9", "100").sorted().map(Integer::parseInt).toList();
        List<Integer> s = Stream.of("10", "9", "100").map(Integer::parseInt)
                .sorted(Comparator.reverseOrder()).toList();
        System.out.println(r + " " + s);
    }
}
