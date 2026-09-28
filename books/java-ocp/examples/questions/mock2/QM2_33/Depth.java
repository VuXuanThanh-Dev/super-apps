import java.io.IOException;
import java.nio.file.*;
import java.util.stream.Stream;

public class Depth {
    public static void main(String[] args) throws IOException {
        Path root = Path.of("t");
        Files.createDirectories(root.resolve("b/d"));
        Files.writeString(root.resolve("a.txt"), "1");
        Files.writeString(root.resolve("b/c.txt"), "2");
        Files.writeString(root.resolve("b/d/e.txt"), "3");
        Files.writeString(root.resolve("b/d/f.log"), "4");
        try (Stream<Path> f = Files.find(root, 2, (p, a) -> a.isRegularFile());
             Stream<Path> w = Files.walk(root, 2)) {
            System.out.println(f.map(p -> p.getFileName().toString()).sorted().toList() + " " + w.count());
        }
    }
}
