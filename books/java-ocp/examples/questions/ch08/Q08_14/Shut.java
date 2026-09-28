import java.util.concurrent.*;

public class Shut {
    public static void main(String[] args) throws Exception {
        ExecutorService ex = Executors.newSingleThreadExecutor();
        ex.submit(() -> System.out.print("A ")).get();
        ex.shutdown();
        try {
            ex.submit(() -> System.out.print("B "));
        } catch (RejectedExecutionException e) {
            System.out.print("R ");
        }
        ex.awaitTermination(1, TimeUnit.SECONDS);
        System.out.print(ex.isTerminated());
    }
}
