import java.util.*;

public class Ends {
    public static void main(String[] args) {
        Deque<Integer> d = new ArrayDeque<>();
        for (int i = 1; i <= 4; i++) {
            if (i % 2 == 0) d.addFirst(i); else d.addLast(i);
        }
        StringBuilder sb = new StringBuilder();
        d.descendingIterator().forEachRemaining(sb::append);
        System.out.println(d + " " + sb + " " + d.removeLast() + " " + d.peekFirst());
    }
}
