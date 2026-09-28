public class Supp {
    static class R implements AutoCloseable {
        public void close() { throw new IllegalStateException("close"); }
    }

    public static void main(String[] args) {
        try (R r = new R()) {
            throw new IllegalArgumentException("body");
        } catch (RuntimeException e) {
            System.out.println(e.getMessage() + " " + e.getSuppressed().length + " "
                    + e.getSuppressed()[0].getMessage());
        }
    }
}
