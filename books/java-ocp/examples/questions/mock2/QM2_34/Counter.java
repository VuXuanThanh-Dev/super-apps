public class Counter {
    static int total;
    int mine;

    Counter() { total++; mine++; }

    static Counter make() { return new Counter(); }

    public static void main(String[] args) {
        Counter a = new Counter();
        Counter b = make();
        Counter c = b;
        c.mine += 5;
        System.out.println(Counter.total + " " + a.mine + " " + b.mine + " " + a.total);
    }
}
