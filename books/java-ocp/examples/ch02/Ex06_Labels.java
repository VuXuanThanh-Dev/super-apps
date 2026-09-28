// objective: 2.1
// break / continue có nhãn (label) trong vòng lặp lồng nhau.
public class Ex06_Labels {
    public static void main(String[] args) {
        int[][] grid = {{1, 2, 3}, {4, -1, 6}, {7, 8, 9}};

        OUTER:
        for (int[] row : grid) {
            for (int v : row) {
                if (v < 0) break OUTER;          // thoát cả hai vòng
                System.out.print(v + " ");
            }
        }
        System.out.println("| sau break OUTER");

        ROW:
        for (int r = 0; r < 3; r++) {
            for (int c = 0; c < 3; c++) {
                if (c > r) continue ROW;         // sang hàng tiếp theo
                System.out.print(grid[r][c] + " ");
            }
        }
        System.out.println("| tam giác dưới");

        BLOCK: {
            System.out.print("trong block ");
            if (grid.length == 3) break BLOCK;   // break có nhãn dùng được với block thường
            System.out.print("không in ");
        }
        System.out.println("| hết block");
    }
}
