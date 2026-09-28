// objective: 6.2
// Phân rã (decomposition) bằng flatMap, nối (concatenation) bằng Stream.concat.
import java.util.*;
import java.util.stream.*;

public class Ex05_FlatMapConcat {
    public static void main(String[] args) {
        List<List<Integer>> nested = List.of(List.of(1, 2), List.of(3), List.of());
        System.out.println(nested.stream().flatMap(List::stream).map(x -> x * x).toList());

        List<String> lines = List.of("to be", "or not", "to be");
        System.out.println(lines.stream().flatMap(l -> Arrays.stream(l.split(" "))).distinct().toList());

        Stream<String> a = Stream.of("x", "y");
        Stream<String> b = Stream.of("z");
        System.out.println(Stream.concat(a, b).toList());

        System.out.println(IntStream.concat(IntStream.range(0, 2), IntStream.of(9)).boxed().toList());
        System.out.println(Stream.of("ab", "cde").flatMapToInt(String::chars).mapToObj(c -> (char) c).toList());

        List<Object> expanded = Stream.of(1, 2, 3)
                .<Object>mapMulti((n, sink) -> { if (n != 2) { sink.accept(n); sink.accept(-n); } })
                .toList();
        System.out.println(expanded);
    }
}
