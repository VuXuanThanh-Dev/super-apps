// objective: 2.1
// while, do-while (luôn chạy ít nhất 1 lần), for nhiều biến, for-each.
public class Ex05_Loops {
    public static void main(String[] args) {
        int i = 10;
        while (i < 10) { System.out.println("while"); i++; }
        do { System.out.println("do-while chạy 1 lần, i=" + i); i++; } while (i < 10);

        for (int a = 0, b = 10; a < b; a += 3, b -= 3) {
            System.out.print("(" + a + "," + b + ") ");
        }
        System.out.println();

        int[] nums = {1, 2, 3};
        for (int n : nums) { n *= 10; }             // n là bản sao: mảng không đổi
        System.out.println(nums[0] + " " + nums[1] + " " + nums[2]);

        int count = 0;
        for (;;) {                                  // vòng lặp vô hạn, thoát bằng break
            if (++count == 4) break;
        }
        System.out.println("count=" + count);

        int k = 0;
        while (k++ < 3) System.out.print(k + " ");
        System.out.println("-> k=" + k);
    }
}
