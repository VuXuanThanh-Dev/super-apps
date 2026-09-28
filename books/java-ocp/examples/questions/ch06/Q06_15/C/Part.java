import java.util.*;
import java.util.stream.*;

public class Part {
    public static void main(String[] args) {
        List<Integer> nums = List.of(1, 2, 3, 4);
        Map<Boolean, List<Integer>> m = nums.stream().collect(Collectors.groupingBy(n -> n % 2 == 0, TreeMap::new, Collectors.toList())); System.out.println(m);
    }
}
