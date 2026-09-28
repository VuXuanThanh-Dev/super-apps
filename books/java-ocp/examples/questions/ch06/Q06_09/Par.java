import java.util.*;
import java.util.stream.*;

public class Par {
    public static void main(String[] args) {
        List<Integer> r = IntStream.rangeClosed(1, 10).parallel()
                .filter(i -> i % 3 == 0).boxed().collect(Collectors.toList());
        int first = IntStream.rangeClosed(1, 10).parallel().filter(i -> i > 4).findFirst().getAsInt();
        System.out.println(r + " " + first);
    }
}
