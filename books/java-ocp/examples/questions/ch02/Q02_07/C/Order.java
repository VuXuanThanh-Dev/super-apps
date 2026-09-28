public class Order {
    static String f(Object o) {
        return switch (o) {
            case String s when s.isEmpty() -> "E"; case String s -> "S"; default -> "D";
        };
    }

    public static void main(String[] args) {
        System.out.println(f("x"));
    }
}
