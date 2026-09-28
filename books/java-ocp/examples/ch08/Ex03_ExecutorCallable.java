// objective: 8.1
// ExecutorService: submit Runnable/Callable, Future.get, invokeAll, shutdown, awaitTermination.
import java.util.List;
import java.util.concurrent.*;

public class Ex03_ExecutorCallable {
    public static void main(String[] args) throws Exception {
        ExecutorService pool = Executors.newFixedThreadPool(2);
        Callable<Integer> sum = () -> {
            int s = 0;
            for (int i = 1; i <= 100; i++) s += i;
            return s;
        };
        Future<Integer> f = pool.submit(sum);
        Future<?> r = pool.submit(() -> System.out.println("Runnable không trả về giá trị"));
        System.out.println("sum = " + f.get() + ", runnable result = " + r.get() + ", done? " + f.isDone());

        List<Callable<String>> tasks = List.of(() -> "a", () -> "b", () -> "c");
        StringBuilder sb = new StringBuilder();
        for (Future<String> fu : pool.invokeAll(tasks)) sb.append(fu.get());   // kết quả theo đúng thứ tự task
        System.out.println("invokeAll: " + sb);

        Future<Integer> failing = pool.submit(() -> 1 / 0);
        try {
            failing.get();
        } catch (ExecutionException e) {
            System.out.println("ExecutionException, cause: " + e.getCause());
        }
        Future<String> slow = pool.submit(() -> { Thread.sleep(3_000); return "late"; });
        try {
            slow.get(100, TimeUnit.MILLISECONDS);
        } catch (TimeoutException e) {
            System.out.println("TimeoutException; cancel → " + slow.cancel(true) + ", cancelled? " + slow.isCancelled());
        }

        pool.shutdown();                                   // không nhận task mới, chạy nốt task cũ
        System.out.println("isShutdown=" + pool.isShutdown() + " terminated=" + pool.awaitTermination(5, TimeUnit.SECONDS));
        try {
            pool.submit(() -> "x");
        } catch (RejectedExecutionException e) {
            System.out.println("RejectedExecutionException sau shutdown");
        }
    }
}
