import java.util.stream.*;

public class Assoc {
    public static void main(String[] args) {
        int seq = IntStream.rangeClosed(1, 5).reduce(5, Integer::sum);
        int par = IntStream.rangeClosed(1, 5).parallel().reduce(5, Integer::sum);
        System.out.println(seq == par ? "same" : "different");
    }
}
