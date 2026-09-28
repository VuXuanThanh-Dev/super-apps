// objective: 4.1
// Những exception hay gặp trong đề và thông điệp thật của chúng (JDK 21).
import java.util.List;

public class Ex09_CommonExceptions {
    interface Action { void run() throws Exception; }

    static void show(Action a) {
        try {
            a.run();
        } catch (Exception e) {
            System.out.println(e.getClass().getName() + ": " + e.getMessage());
        }
    }

    public static void main(String[] args) {
        show(() -> { String s = null; s.length(); });
        show(() -> { int[] arr = new int[2]; arr[2] = 1; });
        show(() -> Integer.parseInt("12a"));
        show(() -> { Object o = "x"; Integer i = (Integer) o; });
        show(() -> List.of(1).add(2));
        show(() -> List.of(1, 2).get(5));
        show(() -> { throw new IllegalArgumentException("bad arg"); });
        show(() -> new java.util.ArrayList<Integer>().iterator().next());
    }
}
