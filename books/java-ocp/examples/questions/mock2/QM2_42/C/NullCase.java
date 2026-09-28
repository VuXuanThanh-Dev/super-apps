public class NullCase {
    static String t(Object o) {
        return switch (o) {
            case null -> "N"; case Integer i -> "int"; default -> "D";
        };
    }

    public static void main(String[] args) { System.out.println(t(null)); }
}
