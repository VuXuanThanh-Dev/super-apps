import java.nio.file.*;

public class Parts {
    public static void main(String[] args) {
        Path p = Path.of("/var/log/app/server.log");
        System.out.println(p.getFileName() + " " + p.getNameCount() + " " + p.getName(1) + " "
                + p.getParent().getFileName());
    }
}
