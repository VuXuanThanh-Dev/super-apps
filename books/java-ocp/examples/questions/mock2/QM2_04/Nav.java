import java.util.*;

public class Nav {
    public static void main(String[] args) {
        TreeMap<Integer, String> m = new TreeMap<>(Map.of(10, "ten", 20, "twenty", 30, "thirty", 40, "forty"));
        System.out.println(m.floorKey(25) + " " + m.ceilingEntry(25) + " " + m.headMap(30).keySet() + " "
                + m.tailMap(30, false) + " " + m.descendingMap().firstKey());
    }
}
