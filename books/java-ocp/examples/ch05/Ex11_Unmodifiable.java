// objective: 5.1
// So sánh List.of, List.copyOf, Collections.unmodifiableList (view), Arrays.asList.
import java.util.*;

public class Ex11_Unmodifiable {
    public static void main(String[] args) {
        List<String> src = new ArrayList<>(List.of("a", "b"));
        List<String> view = Collections.unmodifiableList(src);   // view chỉ đọc: vẫn thấy thay đổi của src
        List<String> copy = List.copyOf(src);                    // bản sao bất biến
        src.add("c");
        System.out.println(view + " " + copy);

        try {
            List.of("a", null);
        } catch (NullPointerException e) {
            System.out.println("List.of không nhận null");
        }
        List<String> asList = Arrays.asList("x", null);          // asList nhận null
        System.out.println(asList + " contains null? " + asList.contains(null));

        Set<Integer> s = Set.of(3, 1, 2);
        System.out.println(s.size() + " " + s.contains(2));
        try {
            Set.of(1, 1);
        } catch (IllegalArgumentException e) {
            System.out.println("Set.of trùng phần tử → IllegalArgumentException");
        }
    }
}
