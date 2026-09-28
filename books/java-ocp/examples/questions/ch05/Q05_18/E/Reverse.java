import java.util.*;

public class Reverse {
    public static void main(String[] args) {
        List<Integer> list = new ArrayList<>(List.of(1, 2, 3));
        Deque<Integer> d = new ArrayDeque<>(list); System.out.println(d);
    }
}
