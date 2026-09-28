// objective: 3.4
// Tạo lớp bất biến (immutable) và đóng gói (encapsulation) với defensive copy.
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class Ex07_Immutable {
    static final class Order {                    // final: không cho lớp con phá vỡ bất biến
        private final String id;                  // private final
        private final List<String> items;

        Order(String id, List<String> items) {
            this.id = id;
            this.items = new ArrayList<>(items);  // copy khi nhận vào
        }

        String getId() { return id; }
        List<String> getItems() { return Collections.unmodifiableList(items); }  // không trả ra list gốc
        Order withItem(String item) {             // "thay đổi" = tạo object mới
            List<String> copy = new ArrayList<>(items);
            copy.add(item);
            return new Order(id, copy);
        }
    }

    public static void main(String[] args) {
        List<String> src = new ArrayList<>(List.of("pen"));
        Order o = new Order("O1", src);
        src.add("hack");                          // không ảnh hưởng o
        Order o2 = o.withItem("book");
        System.out.println(o.getItems() + " " + o2.getItems());
        try {
            o.getItems().add("x");
        } catch (UnsupportedOperationException e) {
            System.out.println("UnsupportedOperationException: không sửa được từ bên ngoài");
        }
    }
}
