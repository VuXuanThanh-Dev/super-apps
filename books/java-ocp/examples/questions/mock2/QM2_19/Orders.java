import java.util.*;
import java.util.stream.*;

public class Orders {
    record Order(String id, double amount, boolean paid) { }

    public static void main(String[] args) {
        List<Order> os = List.of(new Order("a", 100, true), new Order("b", 50, false),
                new Order("c", 25, true), new Order("d", 75, false));
        Map<Boolean, Double> sums = os.stream().collect(
                Collectors.partitioningBy(Order::paid, Collectors.summingDouble(Order::amount)));
        String r = os.stream().collect(Collectors.teeing(Collectors.counting(),
                Collectors.averagingDouble(Order::amount), (n, avg) -> n + "@" + avg));
        System.out.println(sums + " " + r);
    }
}
