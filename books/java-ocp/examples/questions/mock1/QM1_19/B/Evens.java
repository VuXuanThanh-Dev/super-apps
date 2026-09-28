import java.util.*;
import java.util.stream.*;

public class Evens {
    public static void main(String[] args) {
        System.out.println(Stream.iterate(2, i -> i <= 6, i -> i + 2).toList());
    }
}
