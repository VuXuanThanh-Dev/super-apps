public class Ops {
    enum Op {
        PLUS("+") { int apply(int a, int b) { return a + b; } },
        TIMES("*") { int apply(int a, int b) { return a * b; } };

        final String sym;
        Op(String s) { sym = s; }
        abstract int apply(int a, int b);
    }

    public static void main(String[] args) {
        for (Op op : Op.values()) System.out.print(op + op.sym + op.apply(3, 4) + op.ordinal() + " ");
    }
}
