import java.util.*;

public class Adds {
    public static void main(String[] args) {
        List<String> l = new ArrayList<>();
        l.add("x");
        l.add(0, "y");
        l.add("z");
        l.set(1, "w");
        System.out.println(l + " " + l.indexOf("z"));
    }
}
