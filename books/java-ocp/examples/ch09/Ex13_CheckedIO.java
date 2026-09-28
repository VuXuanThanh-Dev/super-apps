// objective: 9.1, 9.3
// expect: compile-error
// Hầu hết method của Files và I/O stream ném IOException (checked) → phải catch hoặc khai báo throws.
import java.nio.file.*;

public class Ex13_CheckedIO {
    public static void main(String[] args) {
        String all = Files.readString(Path.of("a.txt"));
        System.out.println(all);
    }
}
