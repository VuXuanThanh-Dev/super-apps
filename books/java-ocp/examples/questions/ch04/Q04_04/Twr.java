public class Twr {
    static class R implements AutoCloseable {
        final String n;
        R(String n) { this.n = n; System.out.print("o" + n + " "); }
        public void close() { System.out.print("c" + n + " "); }
    }

    public static void main(String[] args) {
        try (R a = new R("1"); R b = new R("2")) {
            System.out.print("body ");
            throw new RuntimeException();
        } catch (RuntimeException e) {
            System.out.print("catch ");
        } finally {
            System.out.print("fin");
        }
    }
}
