import java.util.*;

public class Wild {
    static void read(List<? extends Number> in) {
        Number n = in.get(0);            // L1
        in.add(null);                    // L2
        in.add(Integer.valueOf(1));      // L3
    }

    static void write(List<? super Integer> out) {
        out.add(5);                      // L4
        Integer i = out.get(0);          // L5
    }

    public static void main(String[] args) { }
}
