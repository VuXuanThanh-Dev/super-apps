import java.util.stream.*;
public class P { public static void main(String[] a) {
    int seq = IntStream.rangeClosed(1, 8).reduce(0, (x, y) -> x - y);
    int par = IntStream.rangeClosed(1, 8).parallel().reduce(0, (x, y) -> x - y);
    System.out.println(seq == par ? "same" : "different"); } }
