import java.util.stream.*;
public class P { public static void main(String[] a) {
    Stream.of("a", "a").collect(Collectors.toMap(s -> s, s -> 1)); } }
