import java.util.*;
import java.util.stream.*;

public class ArrStream {
    public static void main(String[] args) {
        int[] nums = {3, 1, 2};
        System.out.println(Stream.of(nums).count() + " " + Arrays.stream(nums).count() + " "
                + Stream.of(3, 1, 2).count() + " " + IntStream.of(nums).sorted().boxed().toList());
    }
}
