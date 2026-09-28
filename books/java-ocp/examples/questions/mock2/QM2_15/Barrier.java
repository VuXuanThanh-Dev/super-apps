import java.util.*;
import java.util.stream.*;

public class Barrier {
    public static void main(String[] args) {
        List<Integer> r = Stream.of(3, 1, 2)
                .peek(x -> System.out.print("a" + x + " "))
                .sorted()
                .peek(x -> System.out.print("b" + x + " "))
                .limit(2)
                .toList();
        System.out.println(r);
    }
}
