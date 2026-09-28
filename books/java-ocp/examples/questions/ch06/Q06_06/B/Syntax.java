import java.util.function.*;

public class Syntax {
    public static void main(String[] args) {
        BiFunction<String, String, Boolean> b = (x, y) -> { x.equals(y); };
    }
}
