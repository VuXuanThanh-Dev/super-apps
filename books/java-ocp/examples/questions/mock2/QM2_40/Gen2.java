import java.util.*;

public class Gen2 {
    static double total(List<? extends Number> l) { double t = 0; for (Number n : l) t += n.doubleValue(); return t; }
    static void addAll(List<? super Integer> l) { l.add(1); }

    public static void main(String[] args) {
        total(new ArrayList<Integer>());                   // L1
        total(List.of(1.5, 2));                            // L2
        addAll(new ArrayList<Number>());                   // L3
        addAll(new ArrayList<Double>());                   // L4
        List<? extends Number> x = List.of(1); x.add(2);   // L5
    }
}
