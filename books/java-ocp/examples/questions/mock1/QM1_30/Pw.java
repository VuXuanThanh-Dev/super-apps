import java.io.*;
import java.nio.file.*;
import java.util.List;

public class Pw {
    public static void main(String[] args) throws IOException {
        try (PrintWriter pw = new PrintWriter(Files.newBufferedWriter(Path.of("o.txt")))) {
            pw.print("a");
            pw.println("b");
            pw.printf("%d-%s%n", 1, "c");
            pw.print("d");
        }
        List<String> lines = Files.readAllLines(Path.of("o.txt"));
        System.out.println(lines.size() + " " + lines);
    }
}
