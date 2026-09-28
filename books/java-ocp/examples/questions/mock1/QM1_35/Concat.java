import java.util.*;
import java.util.stream.*;

public class Concat {
    public static void main(String[] args) {
        List<String> a = List.of("x,y", "z");
        List<String> b = List.of("y,w");
        String r = Stream.concat(a.stream(), b.stream())
                .flatMap(s -> Arrays.stream(s.split(",")))
                .distinct().sorted().reduce("", String::concat);
        System.out.println(r);
    }
}
