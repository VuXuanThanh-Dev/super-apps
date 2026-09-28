// objective: 1.2
// Numeric promotion: byte/short/char + ... luôn thành int; compound assignment tự ép kiểu.
public class Ex03_Promotion {
    public static void main(String[] args) {
        byte x = 10, y = 20;
        // byte z = x + y;        // KHÔNG biên dịch: x + y là int
        byte z = (byte) (x + y);  // phải ép kiểu
        x += 5;                   // OK: += có ép kiểu ngầm (implicit cast)
        System.out.println(z + " " + x);

        short s = 1;
        char ch = 'a';
        var r1 = s + ch;          // int
        var r2 = 1 + 2L;          // long
        var r3 = 1L + 2.0f;       // float
        var r4 = 'a' + 1.0;       // double
        System.out.println(((Object) r1).getClass().getSimpleName() + " "
                + ((Object) r2).getClass().getSimpleName() + " "
                + ((Object) r3).getClass().getSimpleName() + " "
                + ((Object) r4).getClass().getSimpleName());

        int max = Integer.MAX_VALUE;
        System.out.println("overflow: " + (max + 1));       // tràn số, không có exception
        long ok = max + 1L;                                 // tính bằng long ngay từ đầu
        System.out.println("long    : " + ok);
        long wrong = max * 2;                               // nhân bằng int rồi mới mở rộng
        System.out.println("int*int : " + wrong);
    }
}
