import java.util.concurrent.atomic.*;
public class P { public static void main(String[] a) {
    System.out.println(new AtomicInteger(5).getAndIncrement()); } }
