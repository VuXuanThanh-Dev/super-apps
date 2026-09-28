public class Ret {
    static int f() {
        int x = 1;
        try {
            x = 2;
            throw new RuntimeException("try");
        } catch (RuntimeException e) {
            x = 3;
            return x;
        } finally {
            x = 4;
            System.out.print("finally x=" + x + " ");
        }
    }

    public static void main(String[] args) {
        System.out.println("result=" + f());
    }
}
