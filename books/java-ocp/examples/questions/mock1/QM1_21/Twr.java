public class Twr {
    static class R implements AutoCloseable {
        final String n;
        R(String n) { this.n = n; }
        public void close() {
            System.out.print("close" + n + " ");
            throw new RuntimeException("c" + n);
        }
    }

    public static void main(String[] args) {
        try (R a = new R("A"); R b = new R("B")) {
            throw new IllegalStateException("body");
        } catch (Exception e) {
            System.out.print(e.getMessage() + " " + e.getSuppressed().length + " " + e.getSuppressed()[0].getMessage());
        }
    }
}
