// objective: 3.6
// Interface: method abstract, default, static, private; xung đột default giữa hai interface.
public class Ex12_Interfaces {
    interface Walker {
        int SPEED = 5;                              // ngầm public static final
        default String move() { return "walk " + helper(); }
        private String helper() { return "at " + SPEED; }   // private: chỉ dùng bên trong interface
        static String info() { return "Walker.info"; }       // static: gọi qua tên interface
    }

    interface Swimmer {
        default String move() { return "swim"; }
    }

    static class Duck implements Walker, Swimmer {
        @Override public String move() {                     // BẮT BUỘC override khi hai default trùng
            return Walker.super.move() + " & " + Swimmer.super.move();
        }
    }

    static class Robot implements Walker { }                 // dùng default có sẵn

    public static void main(String[] args) {
        System.out.println(new Duck().move());
        System.out.println(new Robot().move());
        System.out.println(Walker.info() + " " + Walker.SPEED);
        // new Robot().info();     // lỗi: static method của interface không được kế thừa
    }
}
