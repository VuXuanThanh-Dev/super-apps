public class OpenFail {
    static class R implements AutoCloseable {
        final String n;
        R(String n, boolean fail) {
            this.n = n;
            if (fail) throw new IllegalStateException("open " + n);
            System.out.print("open" + n + " ");
        }
        public void close() { System.out.print("close" + n + " "); }
    }

    public static void main(String[] args) {
        try (R a = new R("A", false); R b = new R("B", true)) {
            System.out.print("body ");
        } catch (IllegalStateException e) {
            System.out.print(e.getMessage());
        }
    }
}
