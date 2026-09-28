public class Over {
    static String f(long a, long b) { return "LL"; }
    static String f(Integer... a) { return "I..."; }
    static String f(Object a, Object b) { return "OO"; }

    public static void main(String[] args) {
        System.out.println(f(1, 2) + " " + f(1) + " " + f(1L, 2) + " " + f("a", 1));
    }
}
