import java.util.*;
import java.util.concurrent.*;

public class AnyOf {
    public static void main(String[] args) throws Exception {
        ExecutorService ex = Executors.newFixedThreadPool(3);
        List<Callable<String>> tasks = List.of(
                () -> { throw new IllegalStateException(); },
                () -> "ok",
                () -> { throw new IllegalArgumentException(); });
        String r = ex.invokeAny(tasks);
        ex.shutdown();
        System.out.println(r + " " + ex.awaitTermination(1, TimeUnit.SECONDS));
    }
}
