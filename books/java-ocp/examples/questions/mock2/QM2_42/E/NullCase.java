public class NullCase {
    static String t(Object o) {
        return switch (o) {
            case Integer i -> "int"; case null -> "N";
        };
    }

    public static void main(String[] args) { System.out.println(t(null)); }
}
