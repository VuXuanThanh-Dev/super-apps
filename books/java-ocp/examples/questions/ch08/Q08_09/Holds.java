import java.util.concurrent.locks.ReentrantLock;

public class Holds {
    public static void main(String[] args) {
        ReentrantLock lock = new ReentrantLock();
        lock.lock();
        lock.lock();
        System.out.print(lock.getHoldCount() + " ");
        lock.unlock();
        System.out.print(lock.isLocked() + " ");
        lock.unlock();
        System.out.print(lock.isLocked() + " ");
        try {
            lock.unlock();
        } catch (IllegalMonitorStateException e) {
            System.out.print("IMSE");
        }
    }
}
