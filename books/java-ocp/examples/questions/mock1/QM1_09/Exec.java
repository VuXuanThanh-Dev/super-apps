import java.util.*;
import java.util.concurrent.*;

public class Exec {
    public static void main(String[] args) throws Exception {
        ExecutorService ex = Executors.newFixedThreadPool(2);
        Future<String> f1 = ex.submit(() -> "A");
        Future<?> f2 = ex.submit(() -> { });
        List<Future<Integer>> fs = ex.invokeAll(List.of(() -> 1, () -> 2));
        ex.shutdown();
        System.out.println(f1.get() + f2.get() + fs.get(1).get() + ex.isShutdown());
    }
}
