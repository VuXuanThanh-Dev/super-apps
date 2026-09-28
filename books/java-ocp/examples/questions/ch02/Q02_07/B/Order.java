public class Order {
    static String f(Object o) {
        return switch (o) {
            case CharSequence cs -> "C"; case String s -> "S"; default -> "D";
        };
    }

    public static void main(String[] args) {
        System.out.println(f("x"));
    }
}
