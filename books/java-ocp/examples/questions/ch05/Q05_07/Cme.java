import java.util.*;

public class Cme {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>(List.of("a", "b", "c"));
        for (String s : list) {
            if (s.equals("b")) list.remove(s);
        }
        System.out.println(list);
    }
}
