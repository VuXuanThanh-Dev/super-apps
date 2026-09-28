public class P {
    static class R implements AutoCloseable { public void close() { System.out.print("close "); } }
    public static void main(String[] a) {
        try (R r = new R()) { throw new RuntimeException(); }
        catch (RuntimeException e) { System.out.println("catch"); }
    }
}
