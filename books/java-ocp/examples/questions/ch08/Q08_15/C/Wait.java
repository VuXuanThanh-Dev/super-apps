import java.util.*;
import java.util.concurrent.*;

public class Wait {
    public static void main(String[] args) throws Exception {
        ExecutorService ex = Executors.newFixedThreadPool(2);
        Callable<Integer> task = () -> 2 + 2;
        System.out.println(ex.invokeAll(List.of(task)).get(0).get());
        ex.shutdown();
    }
}
