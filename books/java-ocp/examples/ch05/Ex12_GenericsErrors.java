// objective: 5.1
// expect: compile-error
// Generics không "hiệp biến" (invariant): List<String> KHÔNG phải List<Object>; không thêm được vào ? extends.
import java.util.ArrayList;
import java.util.List;

public class Ex12_GenericsErrors {
    public static void main(String[] args) {
        List<String> strings = new ArrayList<>();
        List<Object> objects = strings;
        List<? extends Number> nums = new ArrayList<Integer>();
        nums.add(1);
        List<int> primitives = new ArrayList<>();
    }
}
