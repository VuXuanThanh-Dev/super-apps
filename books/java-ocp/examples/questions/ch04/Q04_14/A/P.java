public class P {
    static int f() { try { return 1; } finally { System.out.print("finally "); } }
    public static void main(String[] a) { System.out.println(f()); }
}
