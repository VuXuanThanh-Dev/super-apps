// objective: 2.1, 3.5
// Pattern matching cho switch (Java 21): type pattern, guard "when", case null.
public class Ex04_PatternSwitch {
    static String describe(Object o) {
        return switch (o) {
            case null -> "null!";
            case Integer i when i > 100 -> "big int " + i;
            case Integer i -> "int " + i;
            case String s when s.isEmpty() -> "empty string";
            case String s -> "string of " + s.length();
            case int[] arr -> "int array of " + arr.length;
            default -> "other " + o.getClass().getSimpleName();
        };
    }

    public static void main(String[] args) {
        Object[] data = {7, 500, "", "hello", new int[3], 2.5, null};
        for (Object o : data) System.out.println(describe(o));

        Object o = "abc";
        try {
            switch (o) {
                case Integer i -> System.out.println("int");
                default -> System.out.println("default, không null");
            }
            o = null;
            switch (o) {                    // không có case null → NPE
                case Integer i -> System.out.println("int");
                default -> System.out.println("default");
            }
        } catch (NullPointerException e) {
            System.out.println("NullPointerException: switch trên null không có case null");
        }
    }
}
