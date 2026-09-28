// objective: 6.1, 3.6
// Cú pháp lambda và 4 loại method reference.
import java.util.*;
import java.util.function.*;

public class Ex01_LambdaSyntax {
    static boolean isShort(String s) { return s.length() < 4; }

    public static void main(String[] args) {
        Predicate<String> p1 = s -> s.isEmpty();                  // 1 tham số: bỏ được ()
        Predicate<String> p2 = (String s) -> s.isEmpty();         // ghi kiểu rõ
        Predicate<String> p3 = (var s) -> { return s.isEmpty(); }; // var + khối lệnh cần return
        BiFunction<Integer, Integer, Integer> add = (a, b) -> a + b;
        Supplier<List<String>> maker = () -> new ArrayList<>();
        System.out.println(p1.test("") + " " + p2.test("x") + " " + p3.test("") + " " + add.apply(2, 3) + " " + maker.get());

        Predicate<String> r1 = Ex01_LambdaSyntax::isShort;        // static method
        String prefix = "Mr. ";
        Function<String, String> r2 = prefix::concat;             // method của một object cụ thể
        Function<String, Integer> r3 = String::length;            // method instance, object là tham số đầu
        Supplier<StringBuilder> r4 = StringBuilder::new;          // constructor
        Function<Integer, int[]> r5 = int[]::new;                 // tạo mảng
        System.out.println(r1.test("abc") + " " + r2.apply("Nobin") + " " + r3.apply("lambda")
                + " " + r4.get().append("sb") + " " + r5.apply(3).length);

        int base = 10;                                            // effectively final
        IntUnaryOperator plusBase = x -> x + base;
        // base++;                                                // nếu có dòng này → lambda trên lỗi biên dịch
        System.out.println(plusBase.applyAsInt(5));
    }
}
