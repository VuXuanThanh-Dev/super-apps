public class NullCase {
    static String t(Object o) {
        return switch (o) {
            case null, default -> "N/D"; case Integer i -> "int";
        };
    }

    public static void main(String[] args) { System.out.println(t(null)); }
}
