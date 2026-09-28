import java.util.stream.*;

public class Lazy {
    public static void main(String[] args) {
        Stream.of(1, 2, 3, 4, 5)
                .peek(x -> System.out.print("p" + x + " "))
                .filter(x -> x % 2 == 0)
                .limit(1)
                .forEach(x -> System.out.print("f" + x + " "));
    }
}
