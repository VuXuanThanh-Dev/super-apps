public class P {
    static void f() { throw new RuntimeException("x"); }
    public static void main(String[] a) { System.out.println("compiles"); }
}
