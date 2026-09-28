import java.util.*;

public class Nulls {
    public static void main(String[] args) {
        List<String> l = new ArrayList<>(Arrays.asList("pear", null, "Fig", "apple"));
        l.sort(Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER));
        System.out.print(l + " ");
        l.sort(Comparator.nullsFirst(Comparator.<String>naturalOrder().reversed()));
        System.out.println(l);
    }
}
