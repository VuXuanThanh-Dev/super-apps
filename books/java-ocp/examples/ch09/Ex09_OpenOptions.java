// objective: 9.1, 9.3
// Files.newBufferedWriter/Reader với StandardOpenOption: CREATE_NEW, APPEND, TRUNCATE_EXISTING.
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;

public class Ex09_OpenOptions {
    public static void main(String[] args) throws IOException {
        Path p = Path.of("log.txt");
        try (BufferedWriter w = Files.newBufferedWriter(p, StandardCharsets.UTF_8, StandardOpenOption.CREATE_NEW)) {
            w.write("line1");
            w.newLine();
        }
        try (BufferedWriter w = Files.newBufferedWriter(p, StandardOpenOption.APPEND)) {
            w.write("line2");
            w.newLine();
        }
        try (BufferedReader r = Files.newBufferedReader(p)) {
            System.out.println(r.lines().toList());
        }
        try {
            Files.newBufferedWriter(p, StandardOpenOption.CREATE_NEW).close();
        } catch (FileAlreadyExistsException e) {
            System.out.println("CREATE_NEW trên file đã có → FileAlreadyExistsException");
        }
        try (BufferedWriter w = Files.newBufferedWriter(p)) {        // mặc định: CREATE + TRUNCATE_EXISTING + WRITE
            w.write("fresh");
        }
        System.out.println(Files.readString(p));
        try {
            Files.newBufferedWriter(Path.of("missing.txt"), StandardOpenOption.APPEND).close();
        } catch (NoSuchFileException e) {
            System.out.println("APPEND không kèm CREATE trên file chưa có → NoSuchFileException");
        }
    }
}
