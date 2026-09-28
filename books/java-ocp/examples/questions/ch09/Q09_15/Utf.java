import java.io.IOException;
import java.nio.file.*;

public class Utf {
    public static void main(String[] args) throws IOException {
        String s = "Việt";
        Files.writeString(Path.of("v.txt"), s);
        System.out.println(s.length() + " " + Files.size(Path.of("v.txt")) + " "
                + Files.readString(Path.of("v.txt")).length());
    }
}
