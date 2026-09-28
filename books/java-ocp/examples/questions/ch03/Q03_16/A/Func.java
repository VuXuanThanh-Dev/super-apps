public class Func {
    interface F { int apply(String s); }

    public static void main(String[] args) {
        F f = s -> s.length();
        System.out.println(f.apply("abc"));
    }
}
