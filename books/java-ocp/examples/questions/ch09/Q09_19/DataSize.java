import java.io.*;
import java.nio.file.*;

public class DataSize {
    public static void main(String[] args) throws IOException {
        try (var out = new DataOutputStream(new FileOutputStream("d.bin"))) {
            out.writeInt(1);
            out.writeLong(2);
            out.writeByte(3);
        }
        System.out.println(Files.size(Path.of("d.bin")));
    }
}
