public class Converge {
    public static void main(String[] args) {
        int i = 0, j = 10, steps = 0;
        while (i++ < j--) {
            if (i == j) continue;
            steps++;
        }
        System.out.println(i + " " + j + " " + steps);
    }
}
