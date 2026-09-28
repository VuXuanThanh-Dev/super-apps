import java.util.*;
import java.util.stream.*;

public class Prim {
    public static void main(String[] args) {
        IntSummaryStatistics s = IntStream.of(3, 8, 1).summaryStatistics();
        double avg = IntStream.rangeClosed(1, 4).average().orElse(0);
        System.out.println(s.getMax() + " " + s.getAverage() + " " + avg + " " + IntStream.range(1, 4).sum());
    }
}
