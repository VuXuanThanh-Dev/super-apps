// objective: 4.1
// Multi-catch: một khối catch cho nhiều loại exception không liên quan kế thừa.
import java.io.IOException;

public class Ex03_MultiCatch {
    static void risky(int k) throws IOException {
        switch (k) {
            case 1 -> throw new IOException("disk");
            case 2 -> throw new IllegalStateException("state");
            case 3 -> throw new ArrayIndexOutOfBoundsException(9);
            default -> System.out.println("ok " + k);
        }
    }

    public static void main(String[] args) {
        for (int k = 0; k <= 3; k++) {
            try {
                risky(k);
            } catch (IOException | IllegalStateException e) {
                // e = new IOException();   // lỗi: biến của multi-catch ngầm final
                System.out.println("multi-catch: " + e.getMessage());
            } catch (RuntimeException e) {
                System.out.println("runtime: " + e);
            }
        }
        // catch (FileNotFoundException | IOException e) → lỗi: hai kiểu có quan hệ cha-con
    }
}
