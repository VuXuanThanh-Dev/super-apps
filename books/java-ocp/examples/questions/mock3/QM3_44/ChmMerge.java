import java.util.*;
import java.util.concurrent.*;
import java.util.stream.*;

public class ChmMerge {
    public static void main(String[] args) {
        ConcurrentHashMap<Integer, Integer> m = new ConcurrentHashMap<>();
        IntStream.range(0, 1000).parallel().forEach(i -> m.merge(i % 3, 1, Integer::sum));
        System.out.println(new TreeMap<>(m) + " " + m.reduceValues(1, Integer::sum));
    }
}
