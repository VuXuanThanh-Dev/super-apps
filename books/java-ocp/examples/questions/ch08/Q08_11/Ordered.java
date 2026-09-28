import java.util.*;

public class Ordered {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder();
        List.of(1, 2, 3, 4, 5).parallelStream()
                .map(x -> x * x)
                .forEachOrdered(x -> sb.append(x).append(','));
        System.out.println(sb);
    }
}
