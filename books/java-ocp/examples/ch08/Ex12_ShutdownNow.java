// objective: 8.1
// shutdown() vs shutdownNow(): shutdownNow interrupt các task đang chạy và trả về task chưa chạy.
import java.util.List;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicBoolean;

public class Ex12_ShutdownNow {
    public static void main(String[] args) throws Exception {
        ExecutorService single = Executors.newSingleThreadExecutor();
        CountDownLatch running = new CountDownLatch(1);
        AtomicBoolean interrupted = new AtomicBoolean();
        single.submit(() -> {
            running.countDown();
            try { Thread.sleep(10_000); } catch (InterruptedException e) {
                interrupted.set(true);                     // shutdownNow() đã interrupt task này
            }
        });
        for (int i = 0; i < 3; i++) single.submit(() -> System.out.println("never runs"));
        running.await();
        List<Runnable> notStarted = single.shutdownNow();
        System.out.println("chưa chạy: " + notStarted.size());
        System.out.println("terminated: " + single.awaitTermination(2, TimeUnit.SECONDS) + ", isTerminated: " + single.isTerminated());
        System.out.println("task đang chạy bị interrupt? " + interrupted.get());
    }
}
