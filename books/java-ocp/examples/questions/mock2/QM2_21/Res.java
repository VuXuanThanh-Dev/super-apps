public class Res {
    static class R implements AutoCloseable { public void close() { } }

    public static void main(String[] args) throws Exception {
        R a = new R();
        try (a) { }                                 // L1
        R b = new R();
        b = new R();
        try (b) { }                                 // L2
        try (R c = new R()) { c = new R(); }        // L3
        final R d = new R();
        try (d; R e = new R()) { }                  // L4
    }
}
