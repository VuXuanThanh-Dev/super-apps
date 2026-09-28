import java.util.*;
import java.util.concurrent.*;
public class P { public static void main(String[] a) {
    List<Integer> l = new CopyOnWriteArrayList<>(List.of(1, 2));
    for (Integer i : l) l.add(i);
    System.out.println(l); } }
