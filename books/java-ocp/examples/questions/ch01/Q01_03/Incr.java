public class Incr {
    public static void main(String[] args) {
        int i = 3;
        int j = i++ * 2 + --i;
        System.out.println(i + " " + j);
    }
}
