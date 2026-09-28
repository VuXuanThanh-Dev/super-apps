// objective: 2.1
// if / else if / else, "dangling else", và điều kiện phải là boolean.
public class Ex01_IfElse {
    static String grade(int score) {
        if (score >= 90) return "A";
        else if (score >= 80) return "B";
        else if (score >= 50) return "C";
        else return "F";
    }

    public static void main(String[] args) {
        System.out.println(grade(95) + grade(85) + grade(50) + grade(10));

        int x = 5;
        if (x > 10)
            if (x > 20) System.out.println("> 20");
        else System.out.println("else thuộc về if GẦN NHẤT (x > 20)");   // không in gì!
        System.out.println("sau khối if lồng nhau");

        boolean done = false;
        if (done = true) {                 // gán, không phải so sánh — vẫn hợp lệ vì kiểu boolean
            System.out.println("done = " + done);
        }
        // if (x = 3) {}                   // lỗi biên dịch: int không phải boolean
    }
}
