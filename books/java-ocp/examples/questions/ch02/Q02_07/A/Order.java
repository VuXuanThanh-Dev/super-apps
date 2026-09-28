public class Order {
    static String f(Object o) {
        return switch (o) {
            case String s -> "S"; case CharSequence cs -> "C"; default -> "D";
        };
    }

    public static void main(String[] args) {
        System.out.println(f("x"));
    }
}
