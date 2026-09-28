// objective: 8.3
// Xử lý collection song song: parallel stream, groupingByConcurrent, và bẫy tác dụng phụ (side effect).
import java.util.*;
import java.util.concurrent.*;
import java.util.stream.*;

public class Ex11_ParallelCollections {
    public static void main(String[] args) {
        List<Integer> nums = IntStream.rangeClosed(1, 10_000).boxed().toList();
        System.out.println("sum = " + nums.parallelStream().mapToLong(Integer::longValue).sum());

        List<Integer> good = nums.parallelStream().filter(n -> n % 1000 == 0).toList();   // giữ thứ tự gặp
        System.out.println("collected (ordered) = " + good);

        List<Integer> bad = new ArrayList<>();                 // KHÔNG an toàn khi ghi từ nhiều thread
        List<Integer> safe = Collections.synchronizedList(new ArrayList<>());
        nums.parallelStream().forEach(safe::add);
        System.out.println("synchronizedList size = " + safe.size() + " (thứ tự có thể lộn xộn)");

        ConcurrentMap<Boolean, Long> evenOdd = nums.parallelStream()
                .collect(Collectors.groupingByConcurrent(n -> n % 2 == 0, Collectors.counting()));
        System.out.println("groupingByConcurrent = " + new TreeMap<>(evenOdd));

        System.out.println("parallelism of common pool >= 1 ? " + (ForkJoinPool.commonPool().getParallelism() >= 1)
                + ", bad.size() = " + bad.size());
    }
}
