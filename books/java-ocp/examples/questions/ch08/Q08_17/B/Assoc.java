import java.util.stream.*;

public class Assoc {
    public static void main(String[] args) {
        int seq = IntStream.rangeClosed(1, 5).reduce(1, (a, b) -> a * b);
        int par = IntStream.rangeClosed(1, 5).parallel().reduce(1, (a, b) -> a * b);
        System.out.println(seq == par ? "same" : "different");
    }
}
