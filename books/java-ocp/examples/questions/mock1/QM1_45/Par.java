import java.util.*;
import java.util.stream.*;

public class Par {
    public static void main(String[] args) {
        List<Integer> nums = IntStream.rangeClosed(1, 100).boxed().toList();
        int s1 = nums.parallelStream().mapToInt(i -> i).sum();
        List<Integer> quarter = nums.parallelStream().filter(i -> i % 25 == 0).toList();
        long c = nums.parallelStream().unordered().filter(i -> i > 90).count();
        System.out.println(s1 + " " + quarter + " " + c);
    }
}
