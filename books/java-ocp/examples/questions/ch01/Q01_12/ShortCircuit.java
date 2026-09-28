public class ShortCircuit {
    public static void main(String[] args) {
        int a = 0, b = 0;
        boolean r = (a++ > 0) && (b++ > 0);
        boolean s = (a++ > 0) | (b++ > 0);
        System.out.println(a + " " + b + " " + r + " " + s);
    }
}
