import java.io.IOException;
import java.nio.file.*;
import java.util.List;
import java.util.stream.Stream;

public class Sum {
    public static void main(String[] args) throws IOException {
        Path p = Path.of("n.txt");
        Files.write(p, List.of("3", "1", "2"));
        try (Stream<String> s = Files.lines(p)) {
            System.out.println(s.mapToInt(Integer::parseInt).sum() + " " + Files.readAllLines(p).get(0)
                    + " " + Files.size(p));
        }
    }
}
