public class P {
    enum E { X { String f() { return "special"; } }, Y; String f() { return "normal"; } }
    public static void main(String[] a) { System.out.println(E.X.f() + " " + E.Y.f()); }
}
