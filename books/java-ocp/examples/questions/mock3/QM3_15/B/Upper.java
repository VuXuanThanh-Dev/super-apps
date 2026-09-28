import java.util.*;
import java.util.stream.*;

public class Upper {
    public static void main(String[] args) {
        List<String> in = List.of("a,b", "c");
        System.out.println(in.stream().map(s -> s.split(",")).map(String::toUpperCase).toList());
    }
}
