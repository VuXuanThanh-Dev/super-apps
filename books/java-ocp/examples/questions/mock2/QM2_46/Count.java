import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;

public class Count {
    public static void main(String[] args) throws IOException {
        Files.writeString(Path.of("u.txt"), "hé");
        try (InputStream in = new FileInputStream("u.txt");
             Reader r = new FileReader("u.txt", StandardCharsets.UTF_8)) {
            int bytes = 0, chars = 0;
            while (in.read() != -1) bytes++;
            while (r.read() != -1) chars++;
            System.out.println(bytes + " " + chars);
        }
    }
}
