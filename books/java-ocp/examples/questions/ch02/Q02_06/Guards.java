public class Guards {
    static String t(Object o) {
        return switch (o) {
            case Integer i when i > 10 -> "L";
            case Integer i -> "S";
            case String s when s.length() > 2 -> "W";
            case CharSequence cs -> "C";
            default -> "D";
        };
    }

    public static void main(String[] args) {
        System.out.println(t(5) + t(50) + t("hi") + t("hello")
                + t(new StringBuilder("x")) + t(1.0));
    }
}
