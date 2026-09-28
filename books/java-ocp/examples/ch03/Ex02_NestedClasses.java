// objective: 3.1
// 4 loại lớp lồng nhau: static nested, inner (member), local, anonymous.
public class Ex02_NestedClasses {
    private int value = 10;
    private static int counter = 1;

    static class StaticNested {                 // không cần object bên ngoài
        int read() { return counter; }          // chỉ truy cập được thành viên static của lớp ngoài
    }

    class Inner {                               // gắn với một object của lớp ngoài
        int value = 20;
        int read() { return value + Ex02_NestedClasses.this.value; }   // 20 + 10
    }

    interface Greeter { String greet(String n); }

    Greeter make(String prefix) {
        int local = 1;                          // effectively final → local/anonymous class dùng được
        class LocalGreeter implements Greeter {
            public String greet(String n) { return prefix + n + local; }
        }
        return new LocalGreeter();
    }

    public static void main(String[] args) {
        StaticNested sn = new StaticNested();
        Ex02_NestedClasses outer = new Ex02_NestedClasses();
        Ex02_NestedClasses.Inner in = outer.new Inner();   // cú pháp đặc biệt: outer.new Inner()
        System.out.println(sn.read() + " " + in.read());

        Greeter anon = new Greeter() {                     // anonymous class
            @Override public String greet(String n) { return "Hi " + n; }
        };
        System.out.println(anon.greet("Nobin") + " | " + outer.make("Yo ").greet("Java"));
        System.out.println(in.getClass().getName() + " " + anon.getClass().getName());
    }
}
