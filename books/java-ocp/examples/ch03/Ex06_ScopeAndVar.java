// objective: 3.4
// Phạm vi biến (scope), shadowing, và var (local variable type inference).
import java.util.ArrayList;

public class Ex06_ScopeAndVar {
    int count = 100;                           // instance field

    void show(int count) {                     // tham số che (shadow) field cùng tên
        System.out.println("param=" + count + " field=" + this.count);
        {
            int inner = count * 2;             // chỉ sống trong khối
            System.out.println("inner=" + inner);
        }
        // System.out.println(inner);          // lỗi: ngoài phạm vi
    }

    public static void main(String[] args) {
        new Ex06_ScopeAndVar().show(7);

        var n = 10;                             // int
        var list = new ArrayList<String>();     // ArrayList<String>
        list.add("a");
        var mixed = new ArrayList<>();          // ArrayList<Object> (không có thông tin kiểu)
        mixed.add(1);
        mixed.add("x");
        for (var s : list) System.out.println("for-each var: " + s);
        var arr = new int[]{1, 2};
        System.out.println(n + " " + list + " " + mixed + " " + arr.length);
        // var a;            // lỗi: phải khởi tạo
        // var b = null;     // lỗi: không suy ra được kiểu
        // var c = 1, d = 2; // lỗi: không khai báo nhiều biến
        // var e = {1, 2};   // lỗi: array initializer cần kiểu rõ ràng
        var var = "var là 'reserved type name', không phải keyword → đặt tên biến được";
        System.out.println(var);
    }
}
