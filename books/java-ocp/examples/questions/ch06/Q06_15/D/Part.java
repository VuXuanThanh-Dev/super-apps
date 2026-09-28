import java.util.*;
import java.util.stream.*;

public class Part {
    public static void main(String[] args) {
        List<Integer> nums = List.of(1, 2, 3, 4);
        System.out.println(nums.stream().collect(Collectors.partitioningBy(n -> n % 2 == 0, Collectors.counting())));
    }
}
