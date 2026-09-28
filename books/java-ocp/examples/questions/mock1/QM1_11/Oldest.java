import java.util.*;
import java.util.stream.*;

public class Oldest {
    record P(String name, String city, int age) { }

    public static void main(String[] args) {
        List<P> ps = List.of(new P("An", "HN", 30), new P("Binh", "HCM", 25), new P("Chi", "HN", 22),
                new P("Dung", "HCM", 40), new P("Em", "DN", 35));
        Map<String, Optional<P>> oldest = ps.stream().collect(Collectors.groupingBy(
                P::city, TreeMap::new, Collectors.maxBy(Comparator.comparingInt(P::age))));
        oldest.forEach((k, v) -> System.out.print(k + "=" + v.map(P::name).orElse("-") + " "));
    }
}
