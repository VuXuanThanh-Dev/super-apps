import java.util.*;
import java.util.stream.*;

public class Evens {
    public static void main(String[] args) {
        System.out.println(Stream.of(1, 2, 3).map(i -> i * 2).collect(Collectors.toList()));
    }
}
