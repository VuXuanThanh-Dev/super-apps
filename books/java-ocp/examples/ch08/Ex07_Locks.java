// objective: 8.2
// ReentrantLock: lock()/unlock() trong finally, tryLock(), khoá "reentrant", ReadWriteLock.
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.*;

public class Ex07_Locks {
    static final ReentrantLock lock = new ReentrantLock();
    static int balance = 100;

    static void withdraw(int amount) {
        lock.lock();
        try {
            if (balance >= amount) balance -= amount;
            nested();                                     // cùng thread lấy lại khoá được (reentrant)
        } finally {
            lock.unlock();                                // LUÔN mở khoá trong finally
        }
    }

    static void nested() {
        lock.lock();
        try { System.out.println("hold count = " + lock.getHoldCount()); } finally { lock.unlock(); }
    }

    public static void main(String[] args) throws Exception {
        withdraw(30);
        System.out.println("balance = " + balance + ", locked now? " + lock.isLocked());

        lock.lock();                                      // main giữ khoá
        Thread other = new Thread(() -> {
            try {
                boolean got = lock.tryLock(100, TimeUnit.MILLISECONDS);
                System.out.println("other tryLock: " + got);
                if (got) lock.unlock();
            } catch (InterruptedException e) { }
        });
        other.start();
        other.join();
        lock.unlock();

        try {
            lock.unlock();                                // mở khoá khi không giữ
        } catch (IllegalMonitorStateException e) {
            System.out.println("IllegalMonitorStateException");
        }

        ReadWriteLock rw = new ReentrantReadWriteLock();
        rw.readLock().lock();
        rw.readLock().lock();                             // nhiều reader cùng lúc được
        System.out.println("read locks = " + ((ReentrantReadWriteLock) rw).getReadLockCount());
        rw.readLock().unlock();
        rw.readLock().unlock();
    }
}
