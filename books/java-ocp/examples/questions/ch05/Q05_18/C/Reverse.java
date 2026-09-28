import java.util.*;

public class Reverse {
    public static void main(String[] args) {
        List<Integer> list = new ArrayList<>(List.of(1, 2, 3));
        list.sort(Comparator.reverseOrder()); System.out.println(list);
    }
}
