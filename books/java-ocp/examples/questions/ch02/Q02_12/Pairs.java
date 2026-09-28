public class Pairs {
    record Pair(Object a, Object b) {}

    static String m(Object o) {
        return switch (o) {
            case Pair(String s, Integer i) when i > 0 -> "SI+";
            case Pair(String s, Object x) -> "SO";
            case Pair(Object x, Integer i) -> "OI";
            case Pair p -> "P";
            default -> "D";
        };
    }

    public static void main(String[] args) {
        System.out.println(m(new Pair("a", 1)) + m(new Pair("a", -1)) + m(new Pair(1, 2))
                + m(new Pair(1, "b")) + m("z"));
    }
}
