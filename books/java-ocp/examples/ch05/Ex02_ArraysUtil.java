// objective: 5.1
// Lớp tiện ích Arrays: sort, binarySearch, fill, copyOf, equals, compare, mismatch, asList.
import java.util.Arrays;
import java.util.List;

public class Ex02_ArraysUtil {
    public static void main(String[] args) {
        int[] nums = {40, 10, 30, 20};
        Arrays.sort(nums);
        System.out.println(Arrays.toString(nums));
        System.out.println(Arrays.binarySearch(nums, 30) + " " + Arrays.binarySearch(nums, 25)
                + " " + Arrays.binarySearch(nums, 5));        // không thấy: -(vị trí chèn) - 1

        String[] words = {"banana", "Apple", "cherry", "apple"};
        Arrays.sort(words);                                   // chữ HOA đứng trước chữ thường (theo Unicode)
        System.out.println(Arrays.toString(words));

        int[] copy = Arrays.copyOf(nums, 6);
        int[] range = Arrays.copyOfRange(nums, 1, 3);
        int[] filled = new int[3];
        Arrays.fill(filled, 7);
        System.out.println(Arrays.toString(copy) + " " + Arrays.toString(range) + " " + Arrays.toString(filled));

        int[] p = {1, 2, 3}, q = {1, 2, 3}, r = {1, 2, 4};
        System.out.println((p == q) + " " + p.equals(q) + " " + Arrays.equals(p, q)
                + " " + Arrays.compare(p, r) + " " + Arrays.mismatch(p, r) + " " + Arrays.mismatch(p, q));

        String[] backing = {"x", "y"};
        List<String> view = Arrays.asList(backing);          // list cố định kích thước, "nhìn" vào mảng
        view.set(0, "CHANGED");
        System.out.println(backing[0]);
        try {
            view.add("z");
        } catch (UnsupportedOperationException e) {
            System.out.println("asList: không add/remove được");
        }
    }
}
