import java.io.IOException;
import java.nio.file.*;
import java.util.stream.Stream;

public class Walk {
    public static void main(String[] args) throws IOException {
        Path root = Path.of("root");
        Files.createDirectories(root.resolve("sub/deep"));
        Files.writeString(root.resolve("a.txt"), "a");
        Files.writeString(root.resolve("sub/b.txt"), "b");
        Files.writeString(root.resolve("sub/deep/c.txt"), "c");
        try (Stream<Path> w1 = Files.walk(root, 1);
             Stream<Path> w2 = Files.walk(root);
             Stream<Path> l = Files.list(root)) {
            System.out.println(w1.count() + " " + w2.filter(Files::isRegularFile).count() + " " + l.count());
        }
    }
}
