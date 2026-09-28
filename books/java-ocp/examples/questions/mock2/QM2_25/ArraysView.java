import java.util.*;

public class ArraysView {
    public static void main(String[] args) {
        Integer[] arr = {5, 3, 9, 1};
        Arrays.sort(arr, Comparator.reverseOrder());
        List<Integer> view = Arrays.asList(arr);
        view.set(0, 7);
        Collections.reverse(view);
        System.out.println(Arrays.toString(arr) + " " + Arrays.binarySearch(arr, 5) + " " + view.indexOf(7));
    }
}
