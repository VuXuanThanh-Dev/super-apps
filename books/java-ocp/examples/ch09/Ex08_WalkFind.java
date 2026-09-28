// objective: 9.3
// Duyệt cây thư mục: Files.list (1 cấp), Files.walk (đệ quy, có maxDepth), Files.find (có điều kiện).
import java.io.IOException;
import java.nio.file.*;
import java.util.stream.Stream;

public class Ex08_WalkFind {
    public static void main(String[] args) throws IOException {
        Path root = Path.of("tree");
        Files.createDirectories(root.resolve("src/main"));
        Files.createDirectories(root.resolve("docs"));
        Files.writeString(root.resolve("README.md"), "# tree");
        Files.writeString(root.resolve("src/main/App.java"), "class App {}");
        Files.writeString(root.resolve("src/main/Util.java"), "class Util {}");
        Files.writeString(root.resolve("docs/guide.md"), "guide");

        try (Stream<Path> s = Files.list(root)) {                  // Stream phải được đóng!
            System.out.println("list : " + s.map(Path::toString).sorted().toList());
        }
        try (Stream<Path> s = Files.walk(root)) {
            System.out.println("walk : " + s.map(Path::toString).sorted().toList());
        }
        try (Stream<Path> s = Files.walk(root, 1)) {
            System.out.println("depth1: " + s.count() + " paths (gồm cả chính root)");
        }
        try (Stream<Path> s = Files.find(root, 10, (p, attr) -> attr.isRegularFile() && p.toString().endsWith(".java"))) {
            System.out.println("find : " + s.map(p -> p.getFileName().toString()).sorted().toList());
        }
        try (Stream<String> lines = Files.lines(root.resolve("README.md"))) {
            System.out.println("lines: " + lines.toList());
        }
    }
}
