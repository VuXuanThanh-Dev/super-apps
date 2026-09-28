public class NullCase {
    static String t(Object o) {
        return switch (o) {
            case Integer i -> "int"; case Integer i when i < 0 -> "neg"; default -> "D";
        };
    }

    public static void main(String[] args) { System.out.println(t(null)); }
}
