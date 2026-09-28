// objective: 5.1
// Deque (ArrayDeque): dùng như ngăn xếp (stack, LIFO) và hàng đợi (queue, FIFO).
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Queue;

public class Ex07_Deque {
    public static void main(String[] args) {
        Deque<String> stack = new ArrayDeque<>();
        stack.push("a"); stack.push("b"); stack.push("c");        // push = addFirst
        System.out.println(stack + " peek=" + stack.peek() + " pop=" + stack.pop() + " " + stack);

        Queue<String> queue = new ArrayDeque<>();
        queue.offer("1"); queue.offer("2"); queue.add("3");         // offer/add = addLast
        System.out.println(queue + " peek=" + queue.peek() + " poll=" + queue.poll() + " " + queue);

        Deque<Integer> d = new ArrayDeque<>();
        d.offerFirst(2); d.offerLast(3); d.addFirst(1);
        System.out.println(d + " " + d.peekFirst() + " " + d.peekLast() + " " + d.pollLast() + " " + d);

        Deque<Integer> empty = new ArrayDeque<>();
        System.out.println(empty.poll() + " " + empty.peek());      // null: "special value"
        try {
            empty.pop();                                             // hoặc remove()/element(): ném exception
        } catch (java.util.NoSuchElementException e) {
            System.out.println("NoSuchElementException");
        }
        try {
            empty.offer(null);
        } catch (NullPointerException e) {
            System.out.println("ArrayDeque không nhận null");
        }
    }
}
