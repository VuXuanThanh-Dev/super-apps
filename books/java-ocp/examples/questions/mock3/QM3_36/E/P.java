import java.util.*;
public class P { public static void main(String[] a) {
    Map<String, Integer> m = new HashMap<>(); m.put(null, 1); m.put(null, 2); System.out.println(m.size() + " " + m.get(null)); } }
