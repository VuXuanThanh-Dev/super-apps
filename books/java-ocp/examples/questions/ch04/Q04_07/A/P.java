public class P {
    static void f() { throw new NumberFormatException("x"); }   // không cần throws
    public static void main(String[] a) { System.out.println("compiles"); }
}
