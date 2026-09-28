import java.util.concurrent.*;

public class Exec {
    public static void main(String[] args) throws Exception {
        ExecutorService ex = Executors.newCachedThreadPool();
        ex.execute(() -> System.out.println("x"));               // L1
        Future<?> f = ex.execute(() -> System.out.println("y"));  // L2
        Future<String> g = ex.submit(() -> "z");                  // L3
        ex.execute(() -> "w");                                    // L4
        ex.shutdown();
    }
}
