public class Seal {
    sealed interface Shape permits Circle, Square { }
    record Circle(double r) implements Shape { }              // L1
    final class Square implements Shape { }                   // L2
    class Triangle implements Shape { }                       // L3

    static String name(Shape s) {
        return switch (s) {
            case Circle c -> "circle";
            case Square q -> "square";
        };                                                    // L4
    }

    public static void main(String[] args) { }
}
