import java.nio.file.*;
public class P { public static void main(String[] a) throws Exception {
    Files.createDirectories(Path.of("x/y")); Files.createDirectories(Path.of("x/y")); System.out.println("ok"); } }
