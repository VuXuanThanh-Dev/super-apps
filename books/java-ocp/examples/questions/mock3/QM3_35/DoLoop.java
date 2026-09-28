public class DoLoop {
    public static void main(String[] args) {
        int n = 0, sum = 0;
        do {
            n++;
            if (n == 2) continue;
            if (n == 5) break;
            sum += n;
        } while (n < 10);
        System.out.println(n + " " + sum);
    }
}
