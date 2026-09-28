// objective: 8.1
// Vòng đời thread: NEW → RUNNABLE → (BLOCKED/WAITING/TIMED_WAITING) → TERMINATED; run() vs start().
import java.util.concurrent.CountDownLatch;

public class Ex02_Lifecycle {
    public static void main(String[] args) throws Exception {
        CountDownLatch started = new CountDownLatch(1);
        Thread t = new Thread(() -> {
            started.countDown();
            try { Thread.sleep(2_000); } catch (InterruptedException e) {
                System.out.println("bị interrupt khi đang sleep → InterruptedException");
            }
        }, "sleeper");
        System.out.println("1: " + t.getState());          // NEW
        t.start();
        started.await();
        while (t.getState() != Thread.State.TIMED_WAITING) Thread.onSpinWait();
        System.out.println("2: " + t.getState());          // TIMED_WAITING (đang sleep)
        t.interrupt();                                      // đánh thức sớm
        t.join();
        System.out.println("3: " + t.getState() + ", alive? " + t.isAlive());

        Thread r = new Thread(() -> System.out.println("run() chạy trên thread: " + Thread.currentThread().getName()), "other");
        r.run();                                            // KHÔNG tạo thread mới
        r.start();
        r.join();
        try {
            r.start();                                      // start lần 2
        } catch (IllegalThreadStateException e) {
            System.out.println("IllegalThreadStateException: không start() hai lần");
        }
    }
}
