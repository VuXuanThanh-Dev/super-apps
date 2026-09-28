public class Sizes {
    enum Size {
        S(1), M(2), L(3);
        private final int n;
        Size(int n) { this.n = n; }
        Size next() { return values()[(ordinal() + 1) % values().length]; }
    }

    public static void main(String[] args) {
        Size s = Size.valueOf("M");
        System.out.println(s.next() + " " + s.next().next().n + " "
                + s.compareTo(Size.L) + " " + Size.L.name().toLowerCase());
    }
}
