// objective: 9.3
// Thuộc tính file: isDirectory, isRegularFile, size, BasicFileAttributes, isSameFile, symbolic link.
import java.io.IOException;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.nio.file.attribute.FileTime;

public class Ex07_Attributes {
    public static void main(String[] args) throws IOException {
        Path dir = Files.createDirectories(Path.of("attr"));
        Path f = Files.writeString(dir.resolve("a.txt"), "12345");
        System.out.println(Files.isDirectory(dir) + " " + Files.isRegularFile(f) + " " + Files.isRegularFile(dir)
                + " " + Files.size(f) + " " + Files.isReadable(f) + " " + Files.isHidden(Path.of(".hidden")));

        BasicFileAttributes attrs = Files.readAttributes(f, BasicFileAttributes.class);
        System.out.println("attrs: dir=" + attrs.isDirectory() + " file=" + attrs.isRegularFile() + " size=" + attrs.size()
                + " link=" + attrs.isSymbolicLink());

        FileTime t = FileTime.fromMillis(0);
        Files.setLastModifiedTime(f, t);
        System.out.println("lastModified = " + Files.getLastModifiedTime(f));

        Path link = dir.resolve("link.txt");
        Files.createSymbolicLink(link, f.getFileName());         // link tương đối trỏ tới a.txt
        System.out.println("isSymbolicLink=" + Files.isSymbolicLink(link) + " isRegularFile(link)=" + Files.isRegularFile(link)
                + " noFollow=" + Files.isRegularFile(link, LinkOption.NOFOLLOW_LINKS) + " sameFile=" + Files.isSameFile(link, f)
                + " target=" + Files.readSymbolicLink(link));
        System.out.println("Path.of(\"attr/../attr/a.txt\") same as f? " + Files.isSameFile(Path.of("attr/../attr/a.txt"), f)
                + ", equals? " + Path.of("attr/../attr/a.txt").equals(f));
    }
}
