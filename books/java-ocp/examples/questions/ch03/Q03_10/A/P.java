import java.util.*;
public class P {
    record Box(List<String> items) {}
    public static void main(String[] a) {
        Box b = new Box(new ArrayList<>());
        b.items().add("x");
        System.out.println(b.items().size());
    }
}
