public class Chain {
    @FunctionalInterface
    interface Calc {
        int calc(int x);
        default Calc then(Calc next) { return x -> next.calc(calc(x)); }
        static Calc id() { return x -> x; }
    }

    public static void main(String[] args) {
        Calc inc = x -> x + 1;
        Calc dbl = x -> x * 2;
        System.out.println(inc.then(dbl).calc(5) + " " + dbl.then(inc).calc(5) + " " + Calc.id().then(inc).calc(0));
    }
}
