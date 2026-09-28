import java.util.*;

public class Seq {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>(List.of("b", "c"));
        list.addFirst("a");
        List<String> rev = list.reversed();
        list.addLast("d");
        System.out.println(rev + " " + rev.getFirst() + " " + list.getLast());
    }
}
