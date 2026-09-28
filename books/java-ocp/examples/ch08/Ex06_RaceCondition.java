// objective: 8.2
// Race condition: count++ không nguyên tử (atomic). So sánh với synchronized và AtomicInteger.
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

public class Ex06_RaceCondition {
    static int unsafe = 0;
    static int safe = 0;
    static final Object LOCK = new Object();
    static final AtomicInteger atomic = new AtomicInteger();

    public static void main(String[] args) throws Exception {
        int threads = 4, perThread = 100_000;
        try (ExecutorService ex = Executors.newFixedThreadPool(threads)) {
            for (int t = 0; t < threads; t++) {
                ex.submit(() -> {
                    for (int i = 0; i < perThread; i++) {
                        unsafe++;                                  // đọc - cộng - ghi: có thể mất cập nhật
                        synchronized (LOCK) { safe++; }            // một thread một lúc
                        atomic.incrementAndGet();                  // compare-and-set bên trong
                    }
                });
            }
        }
        int expected = threads * perThread;
        System.out.println("expected    = " + expected);
        System.out.println("synchronized= " + safe);
        System.out.println("atomic      = " + atomic.get());
        System.out.println("unsafe <= expected? " + (unsafe <= expected) + " (giá trị thật thay đổi mỗi lần chạy)");
    }
}
