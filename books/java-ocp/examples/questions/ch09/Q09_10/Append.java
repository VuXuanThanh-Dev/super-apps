import java.io.*;
import java.nio.file.*;

public class Append {
    public static void main(String[] args) throws IOException {
        try (var out = new FileOutputStream("a.txt")) { out.write("AB".getBytes()); }
        try (var out = new FileOutputStream("a.txt")) { out.write("C".getBytes()); }
        try (var out = new FileOutputStream("a.txt", true)) { out.write("D".getBytes()); }
        System.out.println(Files.readString(Path.of("a.txt")));
    }
}
