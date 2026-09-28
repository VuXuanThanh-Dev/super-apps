import java.io.*;
import java.nio.file.*;

public class Lines {
    public static void main(String[] args) throws IOException {
        Files.writeString(Path.of("f.txt"), "one\n\ntwo\n");
        try (BufferedReader r = Files.newBufferedReader(Path.of("f.txt"))) {
            String line;
            int n = 0;
            while ((line = r.readLine()) != null) n++;
            System.out.println(n);
        }
    }
}
