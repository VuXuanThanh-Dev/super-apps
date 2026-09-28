import java.nio.file.*;

public class Sub {
    public static void main(String[] args) {
        Path p = Path.of("/usr/local/lib/java/tools.jar");
        System.out.println(p.subpath(1, 3) + " " + p.getName(p.getNameCount() - 2) + " " + p.getRoot() + " "
                + Path.of("a", "..", "b").normalize() + " " + p.getParent().getParent().getFileName());
    }
}
