import java.nio.file.*;

public class Rel {
    public static void main(String[] args) {
        Path a = Path.of("/a/b/c");
        Path b = Path.of("/a/x");
        System.out.println(a.relativize(b) + " " + a.resolve("../d").normalize() + " " + b.resolve("/y"));
    }
}
