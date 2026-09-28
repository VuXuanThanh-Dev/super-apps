import java.util.concurrent.atomic.AtomicInteger;
public class P { public static void main(String[] a) {
    AtomicInteger x = new AtomicInteger(5);
    System.out.println(x.compareAndSet(4, 9) + " " + x.get()); } }
