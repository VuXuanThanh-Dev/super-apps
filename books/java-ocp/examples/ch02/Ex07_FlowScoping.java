// objective: 2.1, 3.5
// Pattern matching với instanceof và "flow scoping": biến pattern có mặt ở đâu?
public class Ex07_FlowScoping {
    static int len(Object o) {
        if (!(o instanceof String s)) {
            return -1;
        }
        return s.length();                 // s dùng được: nhánh trên luôn return
    }

    public static void main(String[] args) {
        System.out.println(len("hello") + " " + len(42));

        Object o = "Java";
        if (o instanceof String s && s.length() > 3) {   // && : s đã được gán khi vế phải chạy
            System.out.println("dài: " + s.toUpperCase());
        }
        // if (o instanceof String s || s.isEmpty()) {}  // lỗi: s có thể chưa được gán

        Number n = 3.5;
        if (n instanceof Integer i) System.out.println("Integer " + i);
        else if (n instanceof Double d) System.out.println("Double " + (d * 2));

        String str = "x";
        if (str instanceof String t) System.out.println("Java 21 cho phép pattern không điều kiện: " + t);
        System.out.println(str instanceof CharSequence cs ? "CharSequence " + cs.length() : "no");
    }
}
