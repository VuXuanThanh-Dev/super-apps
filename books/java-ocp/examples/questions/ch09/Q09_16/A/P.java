import java.nio.file.*;
public class P { public static void main(String[] a) throws Exception {
    Files.createDirectory(Path.of("no/parent/here")); } }
