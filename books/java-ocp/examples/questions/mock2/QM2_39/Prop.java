public class Prop {
    static void a() {
        try { b(); } finally { System.out.print("a "); }
    }

    static void b() {
        try {
            throw new IllegalArgumentException("x");
        } catch (IllegalStateException e) {
            System.out.print("b-catch ");
        } finally {
            System.out.print("b ");
        }
    }

    public static void main(String[] args) {
        try { a(); } catch (RuntimeException e) { System.out.print("main:" + e.getMessage()); }
    }
}
