import java.util.concurrent.CountDownLatch;
import java.util.concurrent.locks.ReentrantLock;
public class P { public static void main(String[] a) throws Exception {
    ReentrantLock lock = new ReentrantLock();
    CountDownLatch held = new CountDownLatch(1);
    Thread t = new Thread(() -> { lock.lock(); held.countDown();
        try { Thread.sleep(100); } catch (InterruptedException e) { } finally { lock.unlock(); } });
    t.start();
    held.await();
    lock.lock();
    System.out.println("acquired after waiting");
    lock.unlock(); } }
