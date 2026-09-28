public class P {
    static void f() { throw new AssertionError("x"); }          // Error: không cần throws
    public static void main(String[] a) { System.out.println("compiles"); }
}
