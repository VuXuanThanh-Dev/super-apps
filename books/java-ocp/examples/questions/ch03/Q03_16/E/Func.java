public class Func {
    abstract class F { abstract int apply(String s); }

    public static void main(String[] args) {
        F f = s -> s.length();
        System.out.println(f.apply("abc"));
    }
}
