// objective: 1.2
// Các hàm hay gặp của Math.
public class Ex06_MathApi {
    public static void main(String[] args) {
        System.out.println(Math.round(2.5) + " " + Math.round(-2.5) + " " + Math.round(2.4f));
        System.out.println(Math.floor(-1.1) + " " + Math.ceil(-1.1) + " " + Math.rint(2.5));
        System.out.println(Math.max(3, 7L) + " " + Math.min(-0.0, 0.0) + " " + Math.abs(-4.5));
        System.out.println(Math.pow(2, 10) + " " + Math.sqrt(-1) + " " + Math.cbrt(27));
        System.out.println(Math.abs(Integer.MIN_VALUE));        // vẫn âm! (tràn số)
        System.out.println(Math.floorDiv(-7, 2) + " " + Math.floorMod(-7, 2));
        System.out.println(1.0 / 0 + " " + -1.0 / 0 + " " + 0.0 / 0);
        System.out.println(0.1 + 0.2);
        try {
            System.out.println(Math.addExact(Integer.MAX_VALUE, 1));
        } catch (ArithmeticException e) {
            System.out.println("ArithmeticException: " + e.getMessage());
        }
        try {
            System.out.println(10 / 0);
        } catch (ArithmeticException e) {
            System.out.println("ArithmeticException: " + e.getMessage());
        }
    }
}
