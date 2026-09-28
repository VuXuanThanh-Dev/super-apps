public class Expr {
    public static void main(String[] args) {
        int x = 10;
        long y = x++ + ++x * 2L;
        double z = y / 4;
        System.out.println(x + " " + y + " " + z);
    }
}
