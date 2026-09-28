import java.util.concurrent.*;
public class P { public static void main(String[] a) throws Exception {
    int n = 200;
    CountDownLatch allRunning = new CountDownLatch(n);
    try (var ex = Executors.newVirtualThreadPerTaskExecutor()) {
        for (int i = 0; i < n; i++) ex.submit(() -> { allRunning.countDown(); allRunning.await(); return null; });
    }
    System.out.println(n + " tasks were running at the same time"); } }
