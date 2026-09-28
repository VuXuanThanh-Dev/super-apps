import java.util.function.*;

public class Fi {
    public static void main(String[] args) {
        Supplier<String> a = String::new;                              // L1
        Function<String, Integer> b = Integer::parseInt;               // L2
        BiFunction<String, Integer, Character> c = String::charAt;     // L3
        Predicate<String> d = String::isEmpty;                         // L4
        UnaryOperator<String> e = s -> s.length();                     // L5
        Consumer<String> f = s -> s.length();                          // L6
        Runnable g = () -> { return 1; };                              // L7
    }
}
