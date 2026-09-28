import java.io.IOException;
import java.nio.file.*;

public class Replace {
    public static void main(String[] args) throws IOException {
        Path a = Files.createFile(Path.of("a.txt"));
        Path b = Files.writeString(Path.of("b.txt"), "B");
        try {
            Files.createFile(a);
        } catch (FileAlreadyExistsException e) {
            System.out.print("exists ");
        }
        Files.move(b, a, StandardCopyOption.REPLACE_EXISTING);
        System.out.println(Files.readString(a) + " " + Files.exists(b) + " " + Files.size(a));
    }
}
