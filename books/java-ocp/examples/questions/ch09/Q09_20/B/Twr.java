import java.io.*;
import java.nio.file.*;

public class Twr {
    public static void main(String[] args) throws IOException {
        Files.writeString(Path.of("t.txt"), "x");
        try (Path p = Path.of("t.txt")) { System.out.println(Files.readString(p)); }
    }
}
