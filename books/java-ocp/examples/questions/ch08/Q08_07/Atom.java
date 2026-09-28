import java.util.concurrent.atomic.AtomicInteger;

public class Atom {
    public static void main(String[] args) {
        AtomicInteger a = new AtomicInteger(10);
        int x = a.getAndAdd(5);
        int y = a.incrementAndGet();
        boolean z = a.compareAndSet(15, 0);
        int w = a.updateAndGet(v -> v * 2);
        System.out.println(x + " " + y + " " + z + " " + w);
    }
}
