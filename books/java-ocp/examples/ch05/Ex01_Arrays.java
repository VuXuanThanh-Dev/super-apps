// objective: 5.1
// Khai báo, khởi tạo mảng; giá trị mặc định; mảng nhiều chiều (có thể "răng cưa" - jagged).
import java.util.Arrays;

public class Ex01_Arrays {
    public static void main(String[] args) {
        int[] a = new int[3];                  // mặc định 0
        int b[] = {5, 6, 7};                   // cú pháp C, vẫn hợp lệ
        String[] names = new String[2];        // mặc định null
        int[] c = new int[]{1, 2};             // không được ghi kích thước khi có {..}
        System.out.println(Arrays.toString(a) + " " + Arrays.toString(b) + " "
                + Arrays.toString(names) + " " + c.length);

        int[][] grid = new int[2][3];
        int[][] jagged = {{1}, {2, 3}, {4, 5, 6}};
        int[][] lazy = new int[2][];           // chiều thứ hai chưa tạo
        lazy[0] = new int[]{9};
        System.out.println(grid[1].length + " " + jagged[2][1] + " " + Arrays.deepToString(jagged)
                + " " + lazy[1]);

        int[] ids, other;                      // cả hai là int[]
        int[] x, y[];                          // x là int[], y là int[][]
        y = new int[1][1];
        System.out.println(y[0][0] + " " + a.getClass().getSimpleName() + " " + (b instanceof Object));
        try {
            System.out.println(b[3]);
        } catch (ArrayIndexOutOfBoundsException e) {
            System.out.println(e.getMessage());
        }
    }
}
