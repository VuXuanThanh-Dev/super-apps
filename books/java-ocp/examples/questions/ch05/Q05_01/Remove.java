import java.util.*;

public class Remove {
    public static void main(String[] args) {
        List<Integer> list = new ArrayList<>(List.of(5, 1, 3, 1));
        list.remove(1);
        list.remove(Integer.valueOf(1));
        System.out.println(list);
    }
}
