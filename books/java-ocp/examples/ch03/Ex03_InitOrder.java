// objective: 3.2
// Thứ tự khởi tạo: static (cha → con) một lần, rồi mỗi object: field/instance initializer → constructor, cha trước con.
class Parent {
    static { System.out.println("1. Parent static block"); }
    int p = log("3. Parent field");
    { System.out.println("4. Parent instance block"); }
    Parent() { System.out.println("5. Parent constructor"); }
    static int log(String s) { System.out.println(s); return 0; }
}

class Child extends Parent {
    static { System.out.println("2. Child static block"); }
    int c = log("6. Child field");
    { System.out.println("7. Child instance block"); }
    Child() {
        super();                    // luôn là lệnh đầu tiên (thêm ngầm nếu không viết)
        System.out.println("8. Child constructor");
    }
    Child(String s) {
        this();                     // gọi constructor khác trong cùng lớp
        System.out.println("9. Child(String) " + s);
    }
}

public class Ex03_InitOrder {
    public static void main(String[] args) {
        new Child("x");
        System.out.println("--- object thứ hai: không chạy lại static");
        new Child();
    }
}
