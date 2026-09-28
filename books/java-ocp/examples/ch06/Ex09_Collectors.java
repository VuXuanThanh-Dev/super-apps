// objective: 6.2
// Collectors: toList, joining, toMap, groupingBy (gom nhóm), partitioningBy (chia hai), counting, mapping...
import java.util.*;
import java.util.stream.*;

public class Ex09_Collectors {
    record Emp(String name, String dept, int salary) { }

    public static void main(String[] args) {
        List<Emp> emps = List.of(new Emp("An", "IT", 3000), new Emp("Binh", "HR", 2000),
                new Emp("Chi", "IT", 4000), new Emp("Dung", "Sales", 2500), new Emp("Em", "HR", 2200));

        Map<String, List<String>> byDept = emps.stream().collect(
                Collectors.groupingBy(Emp::dept, TreeMap::new, Collectors.mapping(Emp::name, Collectors.toList())));
        System.out.println(byDept);

        Map<String, Long> count = emps.stream().collect(Collectors.groupingBy(Emp::dept, TreeMap::new, Collectors.counting()));
        Map<String, Double> avg = emps.stream().collect(Collectors.groupingBy(Emp::dept, TreeMap::new, Collectors.averagingInt(Emp::salary)));
        System.out.println(count + " " + avg);

        Map<Boolean, List<String>> rich = emps.stream().collect(
                Collectors.partitioningBy(e -> e.salary() >= 3000, Collectors.mapping(Emp::name, Collectors.toList())));
        System.out.println(rich);
        System.out.println(Stream.of("x").collect(Collectors.partitioningBy(s -> s.isEmpty())));   // luôn có cả false và true

        Map<String, Integer> nameToSalary = emps.stream().collect(Collectors.toMap(Emp::name, Emp::salary));
        System.out.println(new TreeMap<>(nameToSalary));
        Map<String, Integer> maxByDept = emps.stream().collect(
                Collectors.toMap(Emp::dept, Emp::salary, Integer::max, TreeMap::new));
        System.out.println(maxByDept);
        try {
            emps.stream().collect(Collectors.toMap(Emp::dept, Emp::name));     // key trùng, không có merge
        } catch (IllegalStateException e) {
            System.out.println("IllegalStateException: " + e.getMessage());
        }

        System.out.println(emps.stream().map(Emp::name).collect(Collectors.joining("|")) + " "
                + emps.stream().collect(Collectors.summingInt(Emp::salary)) + " "
                + emps.stream().collect(Collectors.teeing(Collectors.counting(), Collectors.summingInt(Emp::salary),
                        (n, total) -> total / n)));
        Optional<Emp> top = emps.stream().collect(Collectors.maxBy(Comparator.comparingInt(Emp::salary)));
        System.out.println(top.map(Emp::name).orElse("-") + " "
                + emps.stream().map(Emp::dept).collect(Collectors.toCollection(TreeSet::new)));
    }
}
