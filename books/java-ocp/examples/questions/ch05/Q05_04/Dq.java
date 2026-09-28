import java.util.*;

public class Dq {
    public static void main(String[] args) {
        Deque<Integer> d = new ArrayDeque<>();
        d.push(1);
        d.offer(2);
        d.push(3);
        d.offerFirst(4);
        System.out.println(d.pop() + " " + d.pollLast() + " " + d.peek() + " " + d);
    }
}
