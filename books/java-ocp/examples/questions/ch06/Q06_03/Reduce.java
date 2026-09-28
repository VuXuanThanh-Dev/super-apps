import java.util.*;
import java.util.stream.*;

public class Reduce {
    public static void main(String[] args) {
        int a = Stream.of(1, 2, 3).reduce(10, Integer::sum);
        Optional<Integer> b = Stream.<Integer>empty().reduce(Integer::sum);
        int c = Stream.of("a", "bb", "ccc").reduce(0, (acc, s) -> acc + s.length(), Integer::sum);
        System.out.println(a + " " + b + " " + c);
    }
}
