// objective: 3.3
// Chọn method overload: đúng kiểu > nới rộng (widening) > boxing > varargs.
public class Ex05_Overloading {
    static void m(long x)     { System.out.println("long"); }
    static void m(Integer x)  { System.out.println("Integer"); }
    static void m(int... x)   { System.out.println("int..."); }
    static void m(Object x)   { System.out.println("Object"); }

    static void s(String x)   { System.out.println("String"); }
    static void s(Object x)   { System.out.println("Object"); }

    static int sum(int... nums) {             // varargs là một mảng
        int t = 0;
        for (int n : nums) t += n;
        return t;
    }

    public static void main(String[] args) {
        int i = 5;
        m(i);            // widening int → long thắng boxing
        m(Integer.valueOf(5));
        m();             // chỉ varargs khớp
        m(5, 6);
        m("text");       // String → Object
        byte b = 1;
        m(b);            // byte → long (widening)
        char c = 'x';
        m(c);            // char → long

        s(null);         // chọn kiểu CỤ THỂ nhất: String
        s((Object) "a");

        System.out.println(sum() + " " + sum(1, 2, 3) + " " + sum(new int[]{4, 5}));
    }
}
