// objective: 8.2
// Lớp atomic: incrementAndGet vs getAndIncrement, compareAndSet, updateAndGet, accumulateAndGet.
import java.util.concurrent.atomic.*;

public class Ex09_Atomics {
    public static void main(String[] args) {
        AtomicInteger a = new AtomicInteger(5);
        System.out.println(a.getAndIncrement() + " " + a.get() + " " + a.incrementAndGet() + " " + a.get());
        System.out.println(a.compareAndSet(7, 100) + " " + a.get() + " " + a.compareAndSet(7, 200) + " " + a.get());
        System.out.println(a.updateAndGet(x -> x * 2) + " " + a.getAndUpdate(x -> x + 1) + " " + a.get());
        System.out.println(a.accumulateAndGet(10, Math::max) + " " + a.addAndGet(-1));

        AtomicLong big = new AtomicLong();
        big.addAndGet(5_000_000_000L);
        AtomicBoolean flag = new AtomicBoolean();
        System.out.println(big + " " + flag.getAndSet(true) + " " + flag.get());

        LongAdder adder = new LongAdder();                 // nhanh hơn khi nhiều thread cùng cộng
        adder.increment(); adder.add(10);
        AtomicReference<String> ref = new AtomicReference<>("v1");
        ref.set("v2");
        System.out.println(adder.sum() + " " + ref.get());
    }
}
