import java.io.*;
import java.nio.file.*;

public class Twr {
    public static void main(String[] args) throws IOException {
        Files.writeString(Path.of("t.txt"), "x");
        try (var lines = Files.lines(Path.of("t.txt"))) { lines.forEach(System.out::println); }
    }
}
