import java.util.function.*;

public class Syntax {
    public static void main(String[] args) {
        Consumer<String> c = (String x) -> System.out.println(x);
    }
}
