import java.util.*;
import java.util.stream.*;

public class NullKey {
    public static void main(String[] args) {
        List<String> l = Arrays.asList("a", null, "b");
        try {
            l.stream().collect(Collectors.groupingBy(s -> s == null ? null : s.length()));
            System.out.print("ok ");
        } catch (NullPointerException e) {
            System.out.print("NPE ");
        }
        System.out.println(l.stream().filter(Objects::nonNull).collect(Collectors.partitioningBy(s -> s.equals("a"))));
    }
}
