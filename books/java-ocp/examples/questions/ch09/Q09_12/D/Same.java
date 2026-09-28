import java.io.IOException;
import java.nio.file.*;

public class Same {
    public static void main(String[] args) throws IOException {
        Files.createDirectories(Path.of("data"));
        Files.writeString(Path.of("data/f.txt"), "x");
        Path a = Path.of("data/f.txt");
        Path b = Path.of("data/../data/f.txt");
        System.out.println(a.toString().equals(b.toString()));
    }
}
