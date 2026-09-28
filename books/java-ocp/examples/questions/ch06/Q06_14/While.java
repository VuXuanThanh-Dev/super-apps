import java.util.stream.*;

public class While {
    public static void main(String[] args) {
        System.out.println(Stream.of(2, 4, 5, 6).takeWhile(x -> x % 2 == 0).toList() + " "
                + Stream.of(2, 4, 5, 6).dropWhile(x -> x % 2 == 0).toList());
    }
}
