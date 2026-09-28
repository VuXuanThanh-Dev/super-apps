import java.util.*;
import java.util.stream.*;

public class Api {
    public static void main(String[] args) {
        List<String> l = List.of("a", "bb");
        int a = l.stream().mapToInt(String::length).sum();                  // L1
        double b = l.stream().mapToInt(String::length).average();           // L2
        long c = l.stream().count();                                        // L3
        int d = l.stream().map(String::length).max(Integer::compare);       // L4
        Optional<String> e = l.stream().findFirst();                        // L5
    }
}
