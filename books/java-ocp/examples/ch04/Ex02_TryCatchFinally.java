// objective: 4.1
// Luồng chạy của try / catch / finally; catch đầu tiên khớp sẽ được chọn.
public class Ex02_TryCatchFinally {
    static void run(String input) {
        System.out.print(input + ": ");
        try {
            System.out.print("try ");
            int n = Integer.parseInt(input);
            System.out.print("parsed ");
            System.out.print(10 / n + " ");
        } catch (NumberFormatException e) {
            System.out.print("NFE ");
        } catch (RuntimeException e) {                 // lớp cha phải đứng SAU lớp con
            System.out.print(e.getClass().getSimpleName() + " ");
        } finally {
            System.out.print("finally");               // luôn chạy
        }
        System.out.println();
    }

    public static void main(String[] args) {
        run("5");
        run("abc");
        run("0");
    }
}
