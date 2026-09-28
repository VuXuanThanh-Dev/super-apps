import java.util.*;
import java.util.stream.*;

public class Product {
    public static void main(String[] args) {
        List<List<Integer>> ll = List.of(List.of(1, 2, 3), List.of(3, 4), List.of(4, 5, 1));
        int product = ll.stream().flatMap(List::stream).distinct().reduce(1, (a, b) -> a * b);
        long dup = ll.stream().flatMap(List::stream).count() - ll.stream().flatMap(List::stream).distinct().count();
        System.out.println(product + " " + dup);
    }
}
