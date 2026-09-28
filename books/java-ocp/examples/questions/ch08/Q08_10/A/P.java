import java.util.concurrent.*;
public class P { public static void main(String[] a) {
    new ConcurrentHashMap<String, Integer>().put(null, 1); } }
