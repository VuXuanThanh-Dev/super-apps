// objective: 9.1, 9.3
// expect: compile-error
// Lỗi hay gặp: Path là interface (không new được); Files.lines trả về Stream<String>, không phải List.
import java.nio.file.*;

public class Ex12_IOCompileErrors {
    public static void main(String[] args) {
        Path p = new Path("a.txt");
        java.util.List<String> lines = Files.lines(Path.of("a.txt"));
    }
}
