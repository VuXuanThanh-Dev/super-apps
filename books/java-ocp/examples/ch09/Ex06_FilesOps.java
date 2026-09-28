// objective: 9.3
// Files: tạo thư mục, đọc/ghi, copy, move, delete và các exception thường gặp.
import java.io.IOException;
import java.nio.file.*;
import java.util.List;

public class Ex06_FilesOps {
    public static void main(String[] args) throws IOException {
        Path dir = Path.of("work/in");
        Files.createDirectories(dir);                          // tạo cả thư mục cha, không lỗi nếu đã có
        Path file = dir.resolve("todo.txt");
        Files.writeString(file, "buy milk\nlearn java\n");
        Files.write(file, List.of("sleep"), StandardOpenOption.APPEND);
        System.out.println(Files.readAllLines(file) + " size=" + Files.size(file));
        System.out.println("exists? " + Files.exists(file) + ", notExists(x)? " + Files.notExists(dir.resolve("x")));

        Path copy = Path.of("work/copy.txt");
        Files.copy(file, copy);
        try {
            Files.copy(file, copy);                            // đích đã tồn tại
        } catch (FileAlreadyExistsException e) {
            System.out.println("FileAlreadyExistsException: " + e.getMessage());
        }
        Files.copy(file, copy, StandardCopyOption.REPLACE_EXISTING);

        Path moved = Files.move(copy, Path.of("work/moved.txt"));
        System.out.println("moved: " + moved + ", copy exists? " + Files.exists(copy));
        try {
            Files.createDirectory(Path.of("work/a/b"));        // cha "work/a" chưa có
        } catch (NoSuchFileException e) {
            System.out.println("NoSuchFileException: " + e.getMessage());
        }
        try {
            Files.delete(Path.of("work"));                     // thư mục không rỗng
        } catch (DirectoryNotEmptyException e) {
            System.out.println("DirectoryNotEmptyException: " + e.getMessage());
        }
        System.out.println("deleteIfExists(nothing) = " + Files.deleteIfExists(Path.of("work/nothing")));
        Files.delete(moved);
        System.out.println("readString: " + Files.readString(file).lines().count() + " lines");
    }
}
