// objective: 6.1, 3.6
// Các functional interface có sẵn trong java.util.function và cách kết hợp chúng.
import java.util.function.*;

public class Ex02_FunctionalInterfaces {
    public static void main(String[] args) {
        Supplier<String> sup = () -> "hi";
        Consumer<String> con = s -> System.out.print("[" + s + "]");
        BiConsumer<String, Integer> bi = (k, v) -> System.out.print(k + "=" + v + " ");
        con.andThen(s -> System.out.println(" again " + s)).accept(sup.get());
        bi.accept("a", 1);
        System.out.println();

        Predicate<Integer> even = n -> n % 2 == 0;
        Predicate<Integer> big = n -> n > 10;
        System.out.println(even.and(big).test(12) + " " + even.or(big).test(3) + " " + even.negate().test(3)
                + " " + Predicate.not(even).test(4) + " " + Predicate.isEqual("x").test("x"));

        Function<Integer, Integer> times2 = x -> x * 2;
        Function<Integer, Integer> plus3 = x -> x + 3;
        System.out.println(times2.andThen(plus3).apply(5) + " " + times2.compose(plus3).apply(5)
                + " " + Function.<Integer>identity().apply(7));

        UnaryOperator<String> upper = String::toUpperCase;
        BinaryOperator<Integer> max = BinaryOperator.maxBy(Integer::compare);
        System.out.println(upper.apply("java") + " " + max.apply(4, 9));

        IntPredicate odd = i -> i % 2 != 0;                 // primitive: tránh boxing
        ToIntFunction<String> len = String::length;
        IntFunction<String> stars = n -> "*".repeat(n);
        DoubleUnaryOperator half = d -> d / 2;
        IntBinaryOperator mul = (a, b) -> a * b;
        BooleanSupplier yes = () -> true;
        System.out.println(odd.test(3) + " " + len.applyAsInt("abcd") + " " + stars.apply(3) + " "
                + half.applyAsDouble(5) + " " + mul.applyAsInt(6, 7) + " " + yes.getAsBoolean());
    }
}
