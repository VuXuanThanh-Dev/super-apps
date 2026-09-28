import java.util.*;
import java.util.stream.*;

public class Flat {
    public static void main(String[] args) {
        List<List<String>> data = List.of(List.of("a", "b"), List.of("b", "c"), List.of());
        long n = data.stream().flatMap(List::stream).distinct().count();
        String s = data.stream().map(List::size).map(String::valueOf)
                .collect(Collectors.joining("-", "<", ">"));
        System.out.println(n + " " + s);
    }
}
