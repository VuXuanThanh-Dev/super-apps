public class Flow {
    public static void main(String[] args) {
        try {
            System.out.print("A");
            int x = 5 / 0;
            System.out.print("B");
        } catch (ArithmeticException e) {
            System.out.print("C");
        } finally {
            System.out.print("D");
        }
        System.out.print("E");
    }
}
