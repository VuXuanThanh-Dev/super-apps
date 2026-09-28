import java.util.stream.*;

public class Combiner {
    public static void main(String[] args) {
        int total = Stream.of("a", "bb", "ccc").reduce(0,
                (acc, s) -> acc + s.length(),
                (x, y) -> { System.out.print("combine "); return x + y; });
        System.out.println(total);
    }
}
