// objective: 8.2
// Phối hợp thread: CountDownLatch (đợi N việc xong), CyclicBarrier (đợi nhau tại một điểm).
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

public class Ex10_Coordination {
    public static void main(String[] args) throws Exception {
        CountDownLatch done = new CountDownLatch(3);
        AtomicInteger work = new AtomicInteger();
        for (int i = 0; i < 3; i++) {
            Thread.ofVirtual().start(() -> { work.addAndGet(10); done.countDown(); });
        }
        done.await();                                      // chặn cho tới khi count = 0
        System.out.println("latch released, work = " + work.get() + ", count = " + done.getCount());

        CyclicBarrier barrier = new CyclicBarrier(3, () -> System.out.println("barrier action: cả 3 đã tới"));
        try (ExecutorService ex = Executors.newFixedThreadPool(3)) {
            for (int i = 0; i < 3; i++) ex.submit(() -> { barrier.await(); return null; });
        }
        System.out.println("parties = " + barrier.getParties() + ", broken? " + barrier.isBroken());
    }
}
