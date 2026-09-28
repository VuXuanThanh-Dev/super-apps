// objective: 6.1, 3.6
// expect: compile-error
// Lỗi lambda hay gặp: tham số trùng tên biến cục bộ; khối lệnh thiếu return.
import java.util.function.*;

public class Ex12_LambdaErrors {
    public static void main(String[] args) {
        String s = "x";
        Predicate<String> p = s -> s.isEmpty();
        Function<Integer, Integer> f = x -> { int y = x * 2; };
    }
}
