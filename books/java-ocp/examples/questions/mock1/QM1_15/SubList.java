import java.util.*;

public class SubList {
    public static void main(String[] args) {
        List<Integer> base = new ArrayList<>(List.of(1, 2, 3, 4, 5));
        List<Integer> sub = base.subList(1, 4);
        sub.remove(Integer.valueOf(3));
        sub.add(9);
        base.set(0, 0);
        System.out.println(base + " " + sub);
    }
}
