import java.util.*;
import java.util.concurrent.*;

public class Cow {
    public static void main(String[] args) {
        List<Integer> list = new CopyOnWriteArrayList<>(List.of(1, 2, 3));
        int count = 0;
        for (Integer i : list) {
            list.add(i * 10);
            count++;
        }
        System.out.println(count + " " + list.size());
    }
}
