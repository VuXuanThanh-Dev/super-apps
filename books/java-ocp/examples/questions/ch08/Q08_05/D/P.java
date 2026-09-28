public class P { public static void main(String[] a) {
    Thread.ofVirtual().unstarted(() -> { }).setDaemon(false); } }
