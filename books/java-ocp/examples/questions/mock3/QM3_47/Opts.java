import java.util.*;
import java.util.stream.*;

public class Opts {
    public static void main(String[] args) {
        List<Optional<String>> opts = List.of(Optional.of("a"), Optional.empty(), Optional.of("c"));
        String r = opts.stream().flatMap(Optional::stream).collect(Collectors.joining("+"));
        long empties = opts.stream().filter(Optional::isEmpty).count();
        System.out.println(r + " " + empties + " " + opts.get(1).map(String::length).orElse(-1));
    }
}
