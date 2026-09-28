import java.util.*;
import java.util.concurrent.*;

public class AllOf {
    public static void main(String[] args) throws Exception {
        ExecutorService ex = Executors.newFixedThreadPool(3);
        List<Callable<Integer>> tasks = List.of(
                () -> { Thread.sleep(200); return 1; },
                () -> 2,
                () -> { Thread.sleep(100); return 3; });
        StringBuilder sb = new StringBuilder();
        for (Future<Integer> f : ex.invokeAll(tasks)) sb.append(f.get());
        ex.shutdown();
        System.out.println(sb);
    }
}
