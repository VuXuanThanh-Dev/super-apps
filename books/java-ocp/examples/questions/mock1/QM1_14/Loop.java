public class Loop {
    public static void main(String[] args) {
        int sum = 0;
        for (int i = 0; i < 10; i++) {
            if (i % 3 == 0) continue;
            if (i > 7) break;
            sum += i;
        }
        System.out.println(sum);
    }
}
