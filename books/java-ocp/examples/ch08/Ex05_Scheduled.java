// objective: 8.1
// ScheduledExecutorService: chạy sau một khoảng trễ, hoặc lặp lại định kỳ.
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

public class Ex05_Scheduled {
    public static void main(String[] args) throws Exception {
        ScheduledExecutorService ses = Executors.newSingleThreadScheduledExecutor();
        ScheduledFuture<String> later = ses.schedule(() -> "chạy sau 100ms", 100, TimeUnit.MILLISECONDS);
        System.out.println(later.get());

        AtomicInteger ticks = new AtomicInteger();
        CountDownLatch three = new CountDownLatch(3);
        ScheduledFuture<?> repeat = ses.scheduleAtFixedRate(() -> {
            ticks.incrementAndGet();
            three.countDown();
        }, 0, 50, TimeUnit.MILLISECONDS);
        three.await();
        repeat.cancel(false);
        System.out.println("ticks >= 3 ? " + (ticks.get() >= 3) + ", cancelled? " + repeat.isCancelled());
        ses.shutdown();
        System.out.println("terminated: " + ses.awaitTermination(2, TimeUnit.SECONDS));
    }
}
