import java.util.*;

public class Sorter {
    record P(String name, int age) { }

    public static void main(String[] args) {
        List<P> ps = new ArrayList<>(List.of(new P("Lan", 30), new P("An", 25),
                new P("Minh", 30), new P("Bao", 25)));
        ps.sort(Comparator.comparing(P::age).reversed().thenComparing(P::name));
        System.out.println(ps.stream().map(P::name).toList());
    }
}
