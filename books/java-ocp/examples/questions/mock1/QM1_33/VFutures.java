import java.util.*;
import java.util.concurrent.*;

public class VFutures {
    public static void main(String[] args) throws Exception {
        List<Future<String>> fs = new ArrayList<>();
        try (var ex = Executors.newVirtualThreadPerTaskExecutor()) {
            for (String s : List.of("x", "y", "z"))
                fs.add(ex.submit(() -> {
                    Thread.sleep(s.equals("x") ? 100 : 10);
                    return s.toUpperCase();
                }));
        }
        StringBuilder sb = new StringBuilder();
        for (Future<String> f : fs) sb.append(f.get()).append(f.isDone() ? "+" : "-");
        System.out.println(sb);
    }
}
