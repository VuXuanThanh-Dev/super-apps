// objective: 1.2
// Ép kiểu thu hẹp (narrowing) cắt bit; ép double → int bỏ phần thập phân.
public class Ex04_Casting {
    public static void main(String[] args) {
        System.out.println((int) 3.99);         // 3 (cắt, không làm tròn)
        System.out.println((int) -3.99);        // -3
        System.out.println((byte) 200);         // 200 - 256 = -56
        System.out.println((short) 70000);      // 70000 - 65536 = 4464
        System.out.println((char) 66);          // B
        System.out.println((int) 'z');          // 122
        System.out.println((int) 1e20);         // bão hòa ở Integer.MAX_VALUE
        System.out.println((long) Double.NaN);  // NaN → 0

        final int small = 100;
        byte fits = small;                      // hằng số compile-time vừa byte → OK không cần cast
        System.out.println(fits);

        double d = 10 / 4;                      // chia int trước → 2, rồi mới thành 2.0
        double e = 10 / 4.0;
        System.out.println(d + " " + e);
    }
}
