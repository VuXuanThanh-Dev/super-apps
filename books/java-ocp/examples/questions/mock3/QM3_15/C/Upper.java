import java.util.*;
import java.util.stream.*;

public class Upper {
    public static void main(String[] args) {
        List<String> in = List.of("a,b", "c");
        System.out.println(in.stream().<String>mapMulti((s, sink) -> { for (String p : s.split(",")) sink.accept(p.toUpperCase()); }).toList());
    }
}
