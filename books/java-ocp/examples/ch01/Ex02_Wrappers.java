// objective: 1.1
// Wrapper class, autoboxing/unboxing, cache của Integer và bẫy null.
public class Ex02_Wrappers {
    public static void main(String[] args) {
        Integer a = 127, b = 127;        // autoboxing dùng Integer.valueOf → có cache -128..127
        Integer c = 128, d = 128;
        System.out.println("127 == 127 ? " + (a == b));
        System.out.println("128 == 128 ? " + (c == d));
        System.out.println("128 equals 128 ? " + c.equals(d));

        int p = Integer.parseInt("42");      // trả về int (primitive)
        Integer w = Integer.valueOf("42");   // trả về Integer (object)
        System.out.println(p + w);           // unboxing rồi cộng: 84

        Long l = 42L;
        System.out.println("Long(42).equals(42) ? " + l.equals(42)); // 42 boxing thành Integer!

        System.out.println(Character.isDigit('7') + " " + Character.toUpperCase('x')
                + " " + Boolean.parseBoolean("TRUE") + " " + Boolean.parseBoolean("yes"));

        Integer nothing = null;
        try {
            int boom = nothing;              // unboxing null → NullPointerException
            System.out.println(boom);
        } catch (NullPointerException e) {
            System.out.println("NPE khi unboxing null");
        }
    }
}
