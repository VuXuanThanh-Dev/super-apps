// objective: 2.1
// Phạm vi biến trong vòng lặp, và continue trong do-while vẫn kiểm tra điều kiện.
public class Ex12_DoWhileScope {
    public static void main(String[] args) {
        int i = 0;
        do {
            i++;
            if (i % 2 == 0) continue;       // continue nhảy tới phần kiểm tra điều kiện
            System.out.print(i + " ");
        } while (i < 7);
        System.out.println();

        for (int j = 0; j < 2; j++) { int local = j * 10; System.out.print(local + " "); }
        // System.out.println(j);          // lỗi: j chỉ sống trong vòng for
        System.out.println();

        int total = 0;
        for (int a = 1; a <= 3; a++)
            for (int b = 1; b <= a; b++)
                total += b;
        System.out.println("total=" + total);
    }
}
