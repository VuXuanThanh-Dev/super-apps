import java.util.*;

public class Wrap {
    public static void main(String[] args) {
        List<Integer> l = new ArrayList<>(List.of(10, 20, 30));
        l.remove(Integer.valueOf(20));
        l.add(1, 99);
        int sum = 0;
        for (int x : l) sum += x;
        Integer big1 = 1000, big2 = 1000;
        System.out.println(l + " " + sum + " " + big1.equals(big2) + " " + (big1 == 1000));
    }
}
