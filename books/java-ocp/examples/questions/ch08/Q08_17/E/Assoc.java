import java.util.stream.*;

public class Assoc {
    public static void main(String[] args) {
        int seq = IntStream.rangeClosed(1, 5).reduce(Integer.MIN_VALUE, Integer::max);
        int par = IntStream.rangeClosed(1, 5).parallel().reduce(Integer.MIN_VALUE, Integer::max);
        System.out.println(seq == par ? "same" : "different");
    }
}
