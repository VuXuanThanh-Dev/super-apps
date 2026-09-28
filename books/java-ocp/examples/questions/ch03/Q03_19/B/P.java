public class P {
    interface Named { String label(); }
    enum E implements Named { X; public String label() { return "x!"; } }
    public static void main(String[] a) { System.out.println(E.X.label()); }
}
