// objective: 6.1
// Optional: chứa 0 hoặc 1 giá trị; tránh null.
import java.util.Optional;

public class Ex07_Optional {
    static String expensive() {
        System.out.print("(expensive called) ");
        return "fallback";
    }

    public static void main(String[] args) {
        Optional<String> some = Optional.of("java");
        Optional<String> none = Optional.empty();
        Optional<String> maybe = Optional.ofNullable(null);
        System.out.println(some + " " + none + " " + maybe.isPresent() + " " + none.isEmpty());

        System.out.println(some.orElse(expensive()));                 // orElse LUÔN tính tham số
        System.out.println(some.orElseGet(Ex07_Optional::expensive)); // orElseGet chỉ gọi khi rỗng
        System.out.println(some.map(String::length).filter(n -> n > 3).orElse(0));
        some.ifPresentOrElse(v -> System.out.println("có " + v), () -> System.out.println("rỗng"));
        none.ifPresentOrElse(v -> System.out.println("có " + v), () -> System.out.println("rỗng"));
        System.out.println(some.flatMap(v -> Optional.of(v + "!")).get() + " " + none.or(() -> Optional.of("B")).get());
        try {
            none.get();
        } catch (java.util.NoSuchElementException e) {
            System.out.println("NoSuchElementException: " + e.getMessage());
        }
        try {
            Optional.of(null);
        } catch (NullPointerException e) {
            System.out.println("Optional.of(null) → NPE");
        }
        try {
            none.orElseThrow();
        } catch (java.util.NoSuchElementException e) {
            System.out.println("orElseThrow() → NoSuchElementException");
        }
    }
}
