public class Pick {
    static String f(Object o) { return "Object"; }
    static String f(Number n) { return "Number"; }
    static String f(Integer i) { return "Integer"; }

    public static void main(String[] args) {
        short s = 1;
        System.out.println(f(5) + " " + f(5L) + " " + f(s) + " " + f("s") + " " + f(null));
    }
}
