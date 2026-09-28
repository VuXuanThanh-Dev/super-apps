import java.util.*;
import java.util.stream.*;
public class P { public static void main(String[] a) {
    OptionalDouble d = IntStream.of(1, 2).average(); System.out.println(d.getAsDouble()); } }
