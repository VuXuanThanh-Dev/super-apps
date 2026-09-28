public class Order {
    static String log = "";

    static void m() {
        try {
            log += "t";
            throw new RuntimeException();
        } catch (RuntimeException e) {
            log += "c";
            throw new IllegalStateException();
        } finally {
            log += "f";
        }
    }

    public static void main(String[] args) {
        try { m(); } catch (IllegalStateException e) { log += "m"; }
        System.out.println(log);
    }
}
