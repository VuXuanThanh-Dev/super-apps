public class Order {
    static String f(Object o) {
        return switch (o) {
            case String s -> "S"; case Integer i -> "I";
        };
    }

    public static void main(String[] args) {
        System.out.println(f("x"));
    }
}
