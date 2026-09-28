// objective: 5.1
// ArrayList: add, set, get, remove(int) vs remove(Object), indexOf, contains, subList.
import java.util.ArrayList;
import java.util.List;

public class Ex03_Lists {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>();
        list.add("a");
        list.add("c");
        list.add(1, "b");                          // chèn tại chỉ số 1
        System.out.println(list + " size=" + list.size());
        String old = list.set(2, "C");             // set trả về phần tử cũ
        System.out.println(old + " -> " + list + " " + list.get(0) + " " + list.indexOf("z"));
        list.remove("a");                          // remove(Object)
        list.remove(0);                            // remove(int index)
        System.out.println(list + " " + list.contains("C") + " " + list.isEmpty());

        List<Integer> nums = new ArrayList<>(List.of(10, 20, 30, 40));
        nums.remove(1);                            // xoá CHỈ SỐ 1 (giá trị 20)!
        nums.remove(Integer.valueOf(40));          // xoá GIÁ TRỊ 40
        System.out.println(nums);

        List<Integer> big = new ArrayList<>(List.of(1, 2, 3, 4, 5));
        List<Integer> sub = big.subList(1, 3);     // view [2, 3]
        sub.set(0, 99);
        System.out.println(sub + " " + big);
        try {
            list.get(5);
        } catch (IndexOutOfBoundsException e) {
            System.out.println(e.getMessage());
        }
    }
}
