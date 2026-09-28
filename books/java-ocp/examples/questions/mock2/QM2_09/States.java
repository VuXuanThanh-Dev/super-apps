import java.io.IOException;
import java.util.concurrent.*;

public class States {
    public static void main(String[] args) throws Exception {
        ExecutorService ex = Executors.newSingleThreadExecutor();
        Future<Integer> f = ex.submit(() -> {
            if (true) throw new IOException("disk");
            return 1;
        });
        try {
            f.get();
        } catch (ExecutionException e) {
            System.out.print(e.getCause() instanceof IOException ? "IO " : "other ");
        }
        System.out.print(f.isDone() + " " + f.isCancelled() + " " + f.state());
        ex.shutdown();
    }
}
