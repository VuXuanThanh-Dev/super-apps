import java.io.IOException;
import java.nio.file.*;

public class Copy {
    public static void main(String[] args) throws IOException {
        Path src = Files.writeString(Path.of("s.txt"), "S");
        Path dst = Files.writeString(Path.of("d.txt"), "D");
        try {
            Files.copy(src, dst);
        } catch (FileAlreadyExistsException e) {
            System.out.print("exists ");
        }
        Files.copy(src, dst, StandardCopyOption.REPLACE_EXISTING);
        System.out.print(Files.readString(dst));
    }
}
