import java.util.*;

public class Dq {
    public static void main(String[] args) {
        Deque<String> d = new ArrayDeque<>(List.of("b", "c"));
        d.offerFirst("a");
        d.push("z");
        d.offerLast("d");
        System.out.println(d.pollLast() + d.pop() + d.peekFirst() + d.size());
    }
}
