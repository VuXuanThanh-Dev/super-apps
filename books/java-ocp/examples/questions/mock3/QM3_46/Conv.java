import java.util.*;

public class Conv {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>(List.of("a"));
        String[] a1 = list.toArray(new String[0]);        // L1
        String[] a2 = list.toArray();                     // L2
        Object[] a3 = list.toArray();                     // L3
        String[] a4 = list.toArray(String[]::new);        // L4
        List<String> l2 = Arrays.asList(a1);              // L5
        int[] ints = {1, 2};
        List<Integer> l3 = Arrays.asList(ints);           // L6
    }
}
