import java.util.concurrent.CountDownLatch;
public class P {
    static final CountDownLatch inside = new CountDownLatch(1), done = new CountDownLatch(1);
    synchronized void inst() throws InterruptedException { inside.countDown(); done.await(); }
    static synchronized void stat() { System.out.println("static entered while instance lock held"); }
    public static void main(String[] a) throws Exception {
        P p = new P();
        Thread t = new Thread(() -> { try { p.inst(); } catch (InterruptedException e) { } });
        t.start();
        inside.await();
        stat();
        done.countDown();
        t.join();
    }
}
