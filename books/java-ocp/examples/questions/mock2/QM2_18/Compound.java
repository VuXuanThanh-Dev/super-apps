public class Compound {
    public static void main(String[] args) {
        short s = 10;
        char c = 'A';
        byte b = 5;
        s *= 2.5;
        c += 1.9;
        b >>= 1;
        int i = 'a' + 'b';
        System.out.println(s + " " + c + " " + b + " " + i + " " + (char) (c + 1));
    }
}
