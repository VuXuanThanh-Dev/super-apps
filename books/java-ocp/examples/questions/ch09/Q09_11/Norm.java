import java.nio.file.*;

public class Norm {
    public static void main(String[] args) {
        System.out.println(Path.of("./a/../../b").normalize() + " " + Path.of("/../x").normalize() + " "
                + Path.of("a/b/./c/..").normalize().getNameCount());
    }
}
