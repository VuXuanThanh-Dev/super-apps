public class P { public static void main(String[] a) throws Exception {
    Thread t = Thread.ofVirtual().start(() -> { });
    System.out.println(t.getState() != Thread.State.NEW); t.join(); } }
