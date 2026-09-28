import java.util.concurrent.*;

public class Tasks {
    public static void main(String[] args) throws Exception {
        ExecutorService ex = Executors.newFixedThreadPool(1);
        Future<?> a = ex.submit(() -> System.out.println("a"));        // L1
        Future<String> b = ex.submit(() -> "b");                       // L2
        Callable<Void> c = () -> { Thread.sleep(10); return null; };   // L3
        Runnable d = () -> { Thread.sleep(10); };                      // L4
        Future<Integer> e = ex.submit(() -> { return; });              // L5
        ex.shutdown();
    }
}
