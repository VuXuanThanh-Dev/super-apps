import java.util.function.*;

public class Capture {
    int field = 0;

    void run() {
        int local = 1;
        int other = 2;
        Supplier<Integer> a = () -> field++;          // L1
        Supplier<Integer> b = () -> local + 1;        // L2
        Supplier<Integer> c = () -> other++;          // L3
        IntUnaryOperator d = local -> local * 2;      // L4
    }

    public static void main(String[] args) { }
}
