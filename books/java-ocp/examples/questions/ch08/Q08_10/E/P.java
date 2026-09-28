import java.util.concurrent.*;
public class P { public static void main(String[] a) {
    BlockingQueue<Integer> q = new ArrayBlockingQueue<>(1);
    q.offer(1);
    System.out.println(q.offer(2)); } }
