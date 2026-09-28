import java.util.concurrent.CountDownLatch;
import java.util.concurrent.locks.ReentrantLock;

public class Try {
    public static void main(String[] args) throws Exception {
        ReentrantLock lock = new ReentrantLock();
        CountDownLatch held = new CountDownLatch(1), release = new CountDownLatch(1);
        Thread t = new Thread(() -> {
            lock.lock();
            try {
                held.countDown();
                release.await();
            } catch (InterruptedException e) {
            } finally {
                lock.unlock();
            }
        });
        t.start();
        held.await();
        boolean first = lock.tryLock();
        release.countDown();
        t.join();
        boolean second = lock.tryLock();
        System.out.println(first + " " + second + " " + lock.isHeldByCurrentThread() + " " + lock.getHoldCount());
    }
}
