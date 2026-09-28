// objective: 6.1
// Terminal operation "ngắn mạch" (short-circuit): anyMatch, allMatch, noneMatch, findFirst; takeWhile, dropWhile.
import java.util.stream.*;

public class Ex10_ShortCircuit {
    public static void main(String[] args) {
        System.out.println(Stream.of(1, 2, 3).anyMatch(x -> x > 2) + " " + Stream.of(1, 2, 3).allMatch(x -> x > 2)
                + " " + Stream.of(1, 2, 3).noneMatch(x -> x > 5));
        System.out.println("empty: any=" + Stream.empty().anyMatch(x -> true) + " all=" + Stream.empty().allMatch(x -> false)
                + " none=" + Stream.empty().noneMatch(x -> true));

        boolean found = Stream.iterate(1, x -> x + 1)                  // stream vô hạn
                .peek(x -> System.out.print(x + " "))
                .anyMatch(x -> x % 7 == 0);                             // dừng ở phần tử đầu tiên thoả
        System.out.println("→ " + found);

        System.out.println(Stream.of(1, 3, 5, 6, 7, 9).takeWhile(x -> x % 2 == 1).toList() + " "
                + Stream.of(1, 3, 5, 6, 7, 9).dropWhile(x -> x % 2 == 1).toList());
        System.out.println(Stream.of("a", "b", "c").findFirst().get() + " "
                + IntStream.iterate(10, x -> x - 3).filter(x -> x < 0).findFirst().getAsInt());
    }
}
