import java.util.*;
import java.util.stream.*;

public class Evens {
    public static void main(String[] args) {
        System.out.println(IntStream.range(1, 3).map(i -> i * 2).boxed().toList());
    }
}
