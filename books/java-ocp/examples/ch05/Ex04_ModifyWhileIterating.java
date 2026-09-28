// objective: 5.1
// Sửa list khi đang duyệt bằng for-each → ConcurrentModificationException; dùng removeIf hoặc Iterator.
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class Ex04_ModifyWhileIterating {
    public static void main(String[] args) {
        List<String> names = new ArrayList<>(List.of("An", "Binh", "Chi", "Dung"));
        try {
            for (String n : names) {
                if (n.startsWith("B")) names.remove(n);
            }
        } catch (java.util.ConcurrentModificationException e) {
            System.out.println("ConcurrentModificationException");
        }
        System.out.println(names);

        names.removeIf(n -> n.length() == 3);      // cách an toàn
        System.out.println(names);

        Iterator<String> it = names.iterator();
        while (it.hasNext()) {
            if (it.next().equals("An")) it.remove();   // xoá qua iterator: an toàn
        }
        System.out.println(names);

        List<Integer> nums = new ArrayList<>(List.of(1, 2, 3, 4));
        nums.replaceAll(x -> x * 10);
        System.out.println(nums);
    }
}
