// objective: 3.6
// Functional interface: đúng MỘT method abstract (không tính default, static, và method public của Object).
import java.util.function.Function;

public class Ex13_FunctionalInterface {
    @FunctionalInterface
    interface Calculator {
        int apply(int a, int b);                     // method abstract duy nhất
        default Calculator twice() { return (a, b) -> apply(apply(a, b), b); }
        static Calculator plus() { return (a, b) -> a + b; }
        boolean equals(Object o);                    // method của Object: không tính
        String toString();                           // không tính
    }

    interface NotFunctional { void a(); void b(); }  // hai method abstract → không dùng được với lambda

    public static void main(String[] args) {
        Calculator mul = (a, b) -> a * b;
        System.out.println(mul.apply(3, 4) + " " + Calculator.plus().twice().apply(1, 10));
        Function<String, Integer> len = String::length;
        System.out.println(len.apply("lambda"));
        // NotFunctional nf = () -> {};              // lỗi: không phải functional interface
    }
}
