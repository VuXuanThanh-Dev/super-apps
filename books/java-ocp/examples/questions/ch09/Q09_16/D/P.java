import java.nio.file.*;
public class P { public static void main(String[] a) throws Exception {
    System.out.println(Files.deleteIfExists(Path.of("ghost.txt"))); } }
