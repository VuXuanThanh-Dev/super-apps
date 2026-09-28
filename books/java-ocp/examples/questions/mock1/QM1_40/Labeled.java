public class Labeled {
    public static void main(String[] args) {
        int count = 0;
        outer:
        do {
            for (int i = 0; i < 5; i++) {
                count++;
                if (count % 4 == 0) continue outer;
                if (count > 9) break outer;
            }
        } while (count < 20);
        System.out.println(count);
    }
}
