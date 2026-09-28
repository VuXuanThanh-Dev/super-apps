// objective: 6.1
// Tạo, lọc, biến đổi, sắp xếp dữ liệu với stream.
import java.util.*;
import java.util.stream.*;

public class Ex04_FilterMapSort {
    record Emp(String name, String dept, int salary) { }

    public static void main(String[] args) {
        List<Emp> emps = List.of(
                new Emp("An", "IT", 3000), new Emp("Binh", "HR", 2000),
                new Emp("Chi", "IT", 4000), new Emp("Dung", "Sales", 2500), new Emp("Em", "IT", 3000));

        System.out.println(emps.stream()
                .filter(e -> e.dept().equals("IT"))
                .sorted(Comparator.comparingInt(Emp::salary).reversed().thenComparing(Emp::name))
                .map(Emp::name)
                .collect(Collectors.joining(", ", "[", "]")));

        System.out.println(Stream.of(5, 3, 5, 1, 3, 9).distinct().sorted().skip(1).limit(2).toList());
        System.out.println(Stream.of("b", "a", "c").sorted(Comparator.reverseOrder()).toList());
        System.out.println(Stream.iterate(1, x -> x * 2).limit(6).toList());
        System.out.println(Stream.iterate(1, x -> x < 50, x -> x * 3).toList());   // iterate có điều kiện dừng
        System.out.println(Stream.generate(() -> "x").limit(3).collect(Collectors.joining()));
        System.out.println(Arrays.stream(new int[]{3, 1, 2}).map(x -> x * 10).boxed().toList());
        System.out.println(Stream.ofNullable(null).count() + " " + Stream.empty().findFirst());
    }
}
