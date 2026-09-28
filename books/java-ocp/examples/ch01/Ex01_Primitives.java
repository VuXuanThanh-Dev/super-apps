// objective: 1.1
// 8 kiểu nguyên thủy (primitive), literal và giá trị mặc định của field.
public class Ex01_Primitives {
    static int defaultInt;        // field: có giá trị mặc định
    static boolean defaultBool;
    static char defaultChar;
    static double defaultDouble;

    public static void main(String[] args) {
        System.out.println("byte  : " + Byte.MIN_VALUE + " .. " + Byte.MAX_VALUE);
        System.out.println("short : " + Short.MIN_VALUE + " .. " + Short.MAX_VALUE);
        System.out.println("int   : " + Integer.MIN_VALUE + " .. " + Integer.MAX_VALUE);
        System.out.println("long  : " + Long.MIN_VALUE + " .. " + Long.MAX_VALUE);
        System.out.println("char  : " + (int) Character.MIN_VALUE + " .. " + (int) Character.MAX_VALUE);
        System.out.println("float max  = " + Float.MAX_VALUE);
        System.out.println("double max = " + Double.MAX_VALUE);

        int million = 1_000_000;      // dấu gạch dưới giúp dễ đọc
        int hex = 0xFF, oct = 017, bin = 0b1010;
        long big = 3_000_000_000L;    // cần hậu tố L
        float f = 1.5f;               // cần hậu tố f
        char c = 'A' + 1;             // hằng số int vừa kiểu char → OK
        System.out.println(million + " " + hex + " " + oct + " " + bin + " " + big + " " + f + " " + c);

        System.out.println("defaults: " + defaultInt + " " + defaultBool + " ["
                + (int) defaultChar + "] " + defaultDouble);
    }
}
