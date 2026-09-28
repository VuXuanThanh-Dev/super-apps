public class Outer {
    private int x = 1;

    class Inner {
        private int x = 2;
        int sum(int x) { return x + this.x + Outer.this.x; }
    }

    static class Nested {
        int get() { return new Outer().x; }
    }

    public static void main(String[] args) {
        Outer o = new Outer();
        o.x = 10;
        Outer.Inner in = o.new Inner();
        System.out.println(in.sum(100) + " " + new Nested().get());
    }
}
