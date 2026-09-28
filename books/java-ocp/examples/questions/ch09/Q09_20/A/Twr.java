import java.io.*;
import java.nio.file.*;

public class Twr {
    public static void main(String[] args) throws IOException {
        Files.writeString(Path.of("t.txt"), "x");
        try (var r = new BufferedReader(new FileReader("t.txt"))) { System.out.println(r.readLine()); }
    }
}
