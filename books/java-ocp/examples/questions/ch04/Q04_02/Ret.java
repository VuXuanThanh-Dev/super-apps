public class Ret {
    static int f() {
        int x = 10;
        try {
            x++;
            return x;
        } finally {
            x += 100;
            System.out.print(x + " ");
        }
    }

    public static void main(String[] args) {
        System.out.println(f());
    }
}
