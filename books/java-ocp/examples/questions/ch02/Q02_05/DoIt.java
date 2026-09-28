public class DoIt {
    public static void main(String[] args) {
        int i = 5;
        do {
            System.out.print(i + " ");
            i -= 2;
        } while (i > 5);
        System.out.println(i);
    }
}
