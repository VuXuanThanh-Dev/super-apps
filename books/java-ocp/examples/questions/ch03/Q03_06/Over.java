public class Over {
    static String f(Object o)  { return "O"; }
    static String f(long l)    { return "L"; }
    static String f(Integer i) { return "I"; }
    static String f(int... is) { return "V"; }

    public static void main(String[] args) {
        short s = 1;
        Integer boxed = 2;
        System.out.println(f(s) + f(boxed) + f(3L) + f() + f('c') + f(4.0));
    }
}
