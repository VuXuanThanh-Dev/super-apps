// objective: 6.1
// IntStream, LongStream, DoubleStream: range, sum, average, summaryStatistics, boxed, mapToObj.
import java.util.*;
import java.util.stream.*;

public class Ex08_PrimitiveStreams {
    public static void main(String[] args) {
        System.out.println(IntStream.range(1, 5).boxed().toList() + " " + IntStream.rangeClosed(1, 5).sum());
        IntSummaryStatistics st = IntStream.of(4, 9, 2).summaryStatistics();
        System.out.println(st.getMin() + " " + st.getMax() + " " + st.getAverage() + " " + st.getSum() + " " + st.getCount());
        OptionalDouble avg = IntStream.of(1, 2).average();
        OptionalInt max = IntStream.empty().max();
        System.out.println(avg + " " + avg.getAsDouble() + " " + max + " " + max.orElse(-1));
        System.out.println(DoubleStream.of(1.5, 2.5).map(d -> d * 2).sum() + " " + LongStream.rangeClosed(1, 20).reduce(1, (a, b) -> a * b));
        List<String> labels = IntStream.range(0, 3).mapToObj(i -> "#" + i).toList();
        System.out.println(labels + " " + Stream.of("a", "bb").mapToInt(String::length).max().getAsInt());
        double[] ds = Stream.of(1, 2).mapToDouble(Integer::doubleValue).toArray();
        System.out.println(Arrays.toString(ds) + " " + IntStream.of(3, 4).asLongStream().sum() + " " + IntStream.of(1, 2).mapToLong(i -> i * 10L).sum());
    }
}
