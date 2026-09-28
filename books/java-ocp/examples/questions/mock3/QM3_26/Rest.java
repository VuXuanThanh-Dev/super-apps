import java.io.*;
import java.nio.file.*;
import java.util.List;
import java.util.stream.Collectors;

public class Rest {
    public static void main(String[] args) throws IOException {
        Files.write(Path.of("in.txt"), List.of("alpha", "beta", "gamma"));
        try (BufferedReader r = Files.newBufferedReader(Path.of("in.txt"))) {
            r.readLine();
            String rest = r.lines().map(s -> s.substring(0, 1)).collect(Collectors.joining());
            System.out.println(rest + " " + r.readLine());
        }
    }
}
