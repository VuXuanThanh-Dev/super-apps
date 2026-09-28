import java.util.*;
import java.util.stream.*;

public class Skills {
    record Dev(String team, List<String> skills) { }

    public static void main(String[] args) {
        List<Dev> ds = List.of(new Dev("A", List.of("java", "sql")), new Dev("B", List.of("js")),
                new Dev("A", List.of("java", "go")));
        Map<String, Set<String>> skills = ds.stream().collect(Collectors.groupingBy(Dev::team, TreeMap::new,
                Collectors.flatMapping(d -> d.skills().stream(), Collectors.toCollection(TreeSet::new))));
        Map<String, Long> javaDevs = ds.stream().collect(Collectors.groupingBy(Dev::team, TreeMap::new,
                Collectors.filtering(d -> d.skills().contains("java"), Collectors.counting())));
        System.out.println(skills + " " + javaDevs);
    }
}
