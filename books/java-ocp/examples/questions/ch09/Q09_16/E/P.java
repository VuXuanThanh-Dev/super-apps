import java.nio.file.*;
public class P { public static void main(String[] a) throws Exception {
    Path s = Files.writeString(Path.of("s.txt"), "x");
    Files.move(s, Path.of("t.txt"));
    System.out.println(Files.exists(s) + " " + Files.exists(Path.of("t.txt"))); } }
