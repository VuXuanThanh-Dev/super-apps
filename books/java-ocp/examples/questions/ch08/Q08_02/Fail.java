import java.util.concurrent.*;

public class Fail {
    public static void main(String[] args) {
        ExecutorService ex = Executors.newSingleThreadExecutor();
        Future<Integer> f = ex.submit(() -> Integer.parseInt("x1"));
        try {
            System.out.println(f.get());
        } catch (ExecutionException e) {
            System.out.println("EE:" + e.getCause().getClass().getSimpleName());
        } catch (InterruptedException e) {
            System.out.println("IE");
        } finally {
            ex.shutdown();
        }
    }
}
