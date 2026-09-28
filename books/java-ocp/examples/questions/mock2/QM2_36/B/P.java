import java.util.*;
import java.util.stream.*;
public class P { public static void main(String[] a) {
    List<Integer> src = IntStream.range(0, 1000).boxed().toList();
    System.out.println(src.parallelStream().collect(Collectors.toList()).equals(src)); } }
