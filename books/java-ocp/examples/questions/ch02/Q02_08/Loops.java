public class Loops {
    public static void main(String[] args) {
        int[] a = {1, 2, 3};
        for (int x : a) {
            x = x * 2;
        }
        int sum = 0;
        for (int i = 0; i < a.length; i++) {
            a[i] += i;
            sum += a[i];
        }
        System.out.println(sum);
    }
}
