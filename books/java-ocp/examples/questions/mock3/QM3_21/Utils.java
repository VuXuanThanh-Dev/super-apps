import java.util.*;

public class Utils {
    public static void main(String[] args) {
        List<String> l = new ArrayList<>(Collections.nCopies(2, "x"));
        l.addAll(List.of("y", "x", "z"));
        Collections.sort(l, Comparator.reverseOrder());
        System.out.println(l + " " + Collections.frequency(l, "x") + " " + Collections.max(l) + " " + l.lastIndexOf("x"));
    }
}
