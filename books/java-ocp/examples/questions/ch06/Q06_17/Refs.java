import java.util.function.*;

public class Refs {
    static int twice(int x) { return 2 * x; }

    public static void main(String[] args) {
        Function<String, Integer> a = String::length;           // L1
        Supplier<String> b = String::new;                       // L2
        IntUnaryOperator c = Refs::twice;                       // L3
        Function<String, String> d = String::toUpperCase();     // L4
        BiFunction<String, String, Boolean> e = String::equals; // L5
    }
}
