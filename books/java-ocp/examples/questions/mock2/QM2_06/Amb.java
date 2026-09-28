public class Amb {
    static void f(String s) { }
    static void f(StringBuilder sb) { }
    static void g(Object o) { }
    static void g(String s) { }
    static void h(int... a) { }
    static void h(long... a) { }

    public static void main(String[] args) {
        f(null);             // L1
        g(null);             // L2
        h();                 // L3
        h(1);                // L4
        f((String) null);    // L5
    }
}
