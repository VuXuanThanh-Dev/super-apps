public class Grid {
    public static void main(String[] args) {
        int[][] grid = {{1, 2}, {3, 4}, {5, 6}};
        int total = 0;
        for (var row : grid) {
            for (var v : row) {
                if (v == 4) break;
                total += v;
            }
        }
        System.out.println(total);
    }
}
