import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

public class Count {
    public static void main(String[] args) {
        AtomicInteger ai = new AtomicInteger();
        try (var ex = Executors.newFixedThreadPool(4)) {
            for (int i = 0; i < 1000; i++) ex.submit(ai::incrementAndGet);
        }
        System.out.println(ai.get() + " " + ai.getAndSet(0) + " " + ai.get());
    }
}
