// objective: 9.3
// Path: tạo, lấy thành phần, resolve, relativize, normalize (chỉ thao tác chuỗi, không cần file tồn tại).
import java.nio.file.*;

public class Ex05_PathBasics {
    public static void main(String[] args) {
        Path p = Path.of("/home/nobin/projects/app/src/Main.java");
        System.out.println(p.getFileName() + " | " + p.getParent() + " | " + p.getRoot() + " | " + p.getNameCount());
        System.out.println(p.getName(0) + " | " + p.subpath(1, 3) + " | " + p.isAbsolute() + " | " + Path.of("a/b").isAbsolute());
        System.out.println(p.startsWith("/home") + " " + p.startsWith("home") + " " + p.endsWith("Main.java") + " " + p.endsWith(".java"));

        Path base = Path.of("/data/reports");
        System.out.println(base.resolve("2024/jan.csv") + " | " + base.resolve("/tmp/x") + " | " + base.resolveSibling("logs"));
        Path a = Path.of("/data/reports/2024");
        Path b = Path.of("/data/images/logo.png");
        System.out.println(a.relativize(b) + " | " + b.relativize(a));
        System.out.println(Path.of("a/./b/../c/./d").normalize() + " | " + Path.of("../../x").normalize() + " | " + Path.of("a/b/../../..").normalize());
        System.out.println(Path.of("docs", "java", "ocp.md") + " | " + Paths.get("x", "y") + " | " + Path.of("") .getNameCount());
        try {
            Path.of("rel/path").relativize(Path.of("/abs/path"));
        } catch (IllegalArgumentException e) {
            System.out.println("IllegalArgumentException: không relativize giữa path tuyệt đối và tương đối");
        }
        for (Path part : Path.of("x/y/z")) System.out.print("[" + part + "]");
        System.out.println();
    }
}
