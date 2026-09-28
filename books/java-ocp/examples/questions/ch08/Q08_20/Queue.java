import java.util.concurrent.*;

public class Queue {
    public static void main(String[] args) {
        BlockingQueue<String> q = new ArrayBlockingQueue<>(2);
        System.out.print(q.offer("a") + " " + q.offer("b") + " " + q.offer("c") + " ");
        System.out.print(q.poll() + " " + q.peek() + " " + q.size());
    }
}
