import java.nio.file.*;

public class Paths1 {
    public static void main(String[] args) {
        Path base = Path.of("/app/config");
        Path p = base.resolve("../logs/./app.log").normalize();
        System.out.println(p + " " + p.getNameCount() + " " + base.relativize(p) + " " + p.startsWith("/app"));
    }
}
