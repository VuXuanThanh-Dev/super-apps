public class P { public static void main(String[] a) throws Exception {
    Thread t = Thread.ofVirtual().unstarted(() -> { });
    System.out.println(t.isDaemon()); } }
