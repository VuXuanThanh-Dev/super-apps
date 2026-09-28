// objective: 1.2
// Thứ tự ưu tiên (precedence), ++/--, short-circuit, % với số âm.
public class Ex05_Operators {
    static boolean check(String name, boolean v) {
        System.out.print(name + " ");
        return v;
    }

    public static void main(String[] args) {
        int i = 5;
        int j = i++ + ++i;       // 5 + 7
        System.out.println("i=" + i + " j=" + j);

        System.out.println(2 + 3 * 4 - 6 / 4);    // 2 + 12 - 1 = 13
        System.out.println(-7 / 2 + " " + -7 % 2 + " " + 7 % -2);
        System.out.println(1 + 2 + "3" + 4 + 5);  // "3345"

        boolean r = check("A", false) && check("B", true);   // B không chạy
        System.out.println("-> " + r);
        r = check("A", false) & check("B", true);            // & luôn chạy cả hai
        System.out.println("-> " + r);
        r = check("A", true) || check("B", true);
        System.out.println("-> " + r);

        int k = 10;
        k += k++ + ++k;          // k = 10 + (10 + 12)
        System.out.println("k=" + k);

        int t = 3;
        String size = t > 5 ? "big" : t > 2 ? "medium" : "small";
        System.out.println(size + " " + (5 & 3) + " " + (5 | 3) + " " + (5 ^ 3) + " " + (~5));
    }
}
