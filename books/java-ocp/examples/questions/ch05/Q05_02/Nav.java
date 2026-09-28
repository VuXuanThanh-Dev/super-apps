import java.util.*;

public class Nav {
    public static void main(String[] args) {
        TreeSet<Integer> t = new TreeSet<>(List.of(8, 2, 6, 4));
        System.out.println(t.floor(5) + " " + t.higher(6) + " " + t.headSet(6) + " "
                + t.pollFirst() + " " + t);
    }
}
