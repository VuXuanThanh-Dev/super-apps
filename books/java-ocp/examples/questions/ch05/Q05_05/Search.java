import java.util.*;

public class Search {
    public static void main(String[] args) {
        String[] arr = {"kiwi", "Fig", "apple", "Date"};
        Arrays.sort(arr);
        System.out.println(Arrays.toString(arr) + " " + Arrays.binarySearch(arr, "banana"));
    }
}
