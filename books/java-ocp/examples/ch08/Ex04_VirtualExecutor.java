// objective: 8.1
// Virtual threads: một thread cho mỗi task, rất rẻ; ExecutorService là AutoCloseable (close() đợi task xong).
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.*;

public class Ex04_VirtualExecutor {
    public static void main(String[] args) throws Exception {
        List<Future<Integer>> results = new ArrayList<>();
        try (ExecutorService ex = Executors.newVirtualThreadPerTaskExecutor()) {
            for (int i = 1; i <= 10_000; i++) {
                int n = i;
                results.add(ex.submit(() -> {
                    Thread.sleep(Duration.ofMillis(10));   // "chặn" (blocking) nhưng virtual thread nhả carrier thread
                    return n;
                }));
            }
        }                                                  // close() = shutdown + đợi mọi task kết thúc
        long total = 0;
        for (Future<Integer> f : results) total += f.get();
        System.out.println("10000 virtual tasks, total = " + total);

        try (var ex = Executors.newVirtualThreadPerTaskExecutor()) {
            Future<Boolean> isVirtual = ex.submit(() -> Thread.currentThread().isVirtual());
            System.out.println("task chạy trên virtual thread? " + isVirtual.get());
        }
    }
}
