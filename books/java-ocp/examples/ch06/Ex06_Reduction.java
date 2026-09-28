// objective: 6.2
// Rút gọn (reduction): reduce, count, min, max, sum, average.
import java.util.*;
import java.util.stream.*;

public class Ex06_Reduction {
    public static void main(String[] args) {
        List<Integer> nums = List.of(4, 8, 15, 16, 23, 42);
        int sum1 = nums.stream().reduce(0, Integer::sum);                 // identity + accumulator
        Optional<Integer> sum2 = nums.stream().reduce(Integer::sum);       // không identity → Optional
        int totalLen = Stream.of("ab", "cde").reduce(0, (acc, s) -> acc + s.length(), Integer::sum);  // 3 tham số
        System.out.println(sum1 + " " + sum2 + " " + totalLen);

        System.out.println(nums.stream().count() + " " + nums.stream().max(Integer::compare).get()
                + " " + nums.stream().min(Comparator.naturalOrder()).orElse(-1));
        System.out.println(nums.stream().mapToInt(Integer::intValue).sum() + " "
                + nums.stream().mapToInt(i -> i).average().getAsDouble());
        System.out.println(Stream.<Integer>empty().reduce(Integer::sum) + " "
                + Stream.<Integer>empty().reduce(100, Integer::sum) + " "
                + IntStream.empty().average() + " " + IntStream.empty().sum());
        String joined = Stream.of("a", "b", "c").reduce("", (x, y) -> x + y);
        System.out.println(joined);
    }
}
