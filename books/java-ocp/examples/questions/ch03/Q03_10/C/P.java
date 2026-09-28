public class P {
    static class Temp { private final int c; Temp(int c) { this.c = c; } int get() { return c; } }
    static class Evil extends Temp { Evil() { super(1); } @Override int get() { return 999; } }
    public static void main(String[] a) {
        Temp t = new Evil();
        System.out.println(t.get());
    }
}
