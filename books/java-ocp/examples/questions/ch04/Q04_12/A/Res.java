public class Res {
    static class R implements AutoCloseable { public void close() { } }

    public static void main(String[] args) {
        R outer = new R();
        try (outer) { }
    }
}
