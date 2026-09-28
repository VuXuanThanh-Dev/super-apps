public class Promo {
    public static void main(String[] args) {
        short s = 10;
        s += 5;          // L1
        s = s * 2;       // L2
        char c = 'a';
        c++;             // L3
        final byte k = 3;
        byte b = k + 1;  // L4
    }
}
