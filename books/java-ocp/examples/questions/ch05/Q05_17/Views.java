import java.util.*;

public class Views {
    public static void main(String[] args) {
        List<String> src = new ArrayList<>(List.of("x"));
        List<String> v = Collections.unmodifiableList(src);
        List<String> c = List.copyOf(src);
        src.add("y");
        System.out.println(v.size() + " " + c.size());
    }
}
