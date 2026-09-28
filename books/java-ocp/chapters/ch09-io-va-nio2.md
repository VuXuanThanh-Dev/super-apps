# Chương 9 — I/O và NIO.2 (Using Java I/O API)

## Mục tiêu

- 9.1 Đọc và ghi dữ liệu console và file bằng I/O stream.
- 9.2 Serialize (tuần tự hoá) và deserialize object.
- 9.3 Tạo, duyệt, tạo mới, đọc, ghi `Path` và thuộc tính của nó bằng API `java.nio.file` (NIO.2).

## Giải thích đơn giản

Java có hai "thế hệ" API cho file:

1. **`java.io`** (cũ): các **stream** — dòng dữ liệu một chiều. Có hai họ:
   - **Byte stream** (`InputStream`/`OutputStream`) cho dữ liệu nhị phân: ảnh, file `.ser`…
   - **Character stream** (`Reader`/`Writer`) cho văn bản, có **encoding** (UTF-8…).
2. **`java.nio.file`** (NIO.2, Java 7+): `Path` (một đường dẫn) và `Files` (các method static để thao tác file:
   đọc, ghi, copy, move, delete, duyệt thư mục). Hiện đại và dễ dùng hơn.

Chú ý: "stream" của I/O **không liên quan** tới Stream API của chương 6 (dù `Files.lines` trả về một `Stream<String>`).

**Serialization** là biến một object thành chuỗi byte (để lưu file hoặc gửi mạng) và ngược lại.

## Ví dụ

Code trong `examples/ch09/`. Chạy lại: `python3 tools/book.py examples ch09`. Mỗi ví dụ chạy trong một thư mục tạm
(file được tạo bằng đường dẫn tương đối). Output thật, JDK 21.0.10.

### 1. Byte stream

<!-- EX:Ex01_ByteStreams -->
`examples/ch09/Ex01_ByteStreams.java`

```java
// objective: 9.1
// Byte stream: FileOutputStream / FileInputStream (+ Buffered...). read() trả về -1 khi hết dữ liệu.
import java.io.*;

public class Ex01_ByteStreams {
    public static void main(String[] args) throws IOException {
        File f = new File("data.bin");
        try (OutputStream out = new BufferedOutputStream(new FileOutputStream(f))) {
            out.write(65);                               // ghi một byte (chỉ 8 bit thấp)
            out.write(new byte[]{66, 67, 68});
            out.write(321);                              // 321 = 256 + 65 → ghi byte 65
        }
        System.out.println("size = " + f.length() + " bytes");

        try (InputStream in = new BufferedInputStream(new FileInputStream(f))) {
            int b;
            StringBuilder sb = new StringBuilder();
            while ((b = in.read()) != -1) sb.append((char) b).append(' ');
            System.out.println("read: " + sb.toString().trim());
        }

        try (InputStream in = new FileInputStream(f)) {
            byte[] buf = new byte[3];
            int n = in.read(buf);                        // đọc tối đa 3 byte, trả về số byte đọc được
            System.out.println("read(buf) = " + n + " -> " + new String(buf, 0, n));
            System.out.println("skip(1) = " + in.skip(1) + ", next = " + (char) in.read() + ", then = " + in.read());
        }

        try (FileOutputStream append = new FileOutputStream(f, true)) {   // true = ghi nối (append)
            append.write('Z');
        }
        try (InputStream in = new FileInputStream(f)) {
            System.out.println("after append: " + new String(in.readAllBytes()));
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
size = 5 bytes
read: A B C D A
read(buf) = 3 -> ABC
skip(1) = 1, next = A, then = -1
after append: ABCDAZ
```
<!-- /EX -->

### 2. Character stream

<!-- EX:Ex02_CharStreams -->
`examples/ch09/Ex02_CharStreams.java`

```java
// objective: 9.1
// Character stream: Writer/Reader cho văn bản (có encoding). BufferedReader.readLine() trả về null khi hết.
import java.io.*;
import java.nio.charset.StandardCharsets;

public class Ex02_CharStreams {
    public static void main(String[] args) throws IOException {
        try (BufferedWriter w = new BufferedWriter(new FileWriter("notes.txt", StandardCharsets.UTF_8))) {
            w.write("Xin chào");
            w.newLine();
            w.write("Java I/O");
        }
        try (PrintWriter pw = new PrintWriter(new FileWriter("notes.txt", StandardCharsets.UTF_8, true))) {
            pw.println();
            pw.printf("%s=%d%n", "total", 3);        // PrintWriter không ném IOException; dùng checkError()
        }
        try (BufferedReader r = new BufferedReader(new FileReader("notes.txt", StandardCharsets.UTF_8))) {
            String line;
            int n = 0;
            while ((line = r.readLine()) != null) System.out.println(++n + ": " + line);
        }
        try (Reader r = new FileReader("notes.txt", StandardCharsets.UTF_8)) {
            char[] buf = new char[8];
            int n = r.read(buf);
            System.out.println("first " + n + " chars: " + new String(buf, 0, n));
        }
        System.out.println("bytes on disk: " + new File("notes.txt").length() + " (tiếng Việt có dấu tốn nhiều byte hơn trong UTF-8)");
        StringWriter sw = new StringWriter();
        try (PrintWriter pw = new PrintWriter(sw)) { pw.print("in memory"); }
        System.out.println(sw);
    }
}
```

Output thật (JDK 21.0.10):

```text
1: Xin chào
2: Java I/O
3: total=3
first 8 chars: Xin chào
bytes on disk: 27 (tiếng Việt có dấu tốn nhiều byte hơn trong UTF-8)
in memory
```
<!-- /EX -->

### 3. Console

<!-- EX:Ex03_Console -->
`examples/ch09/Ex03_Console.java`

```java
// objective: 9.1
// Console: System.console() có thể là null (không có terminal); System.in/out/err là các stream chuẩn.
import java.io.*;

public class Ex03_Console {
    public static void main(String[] args) throws IOException {
        Console c = System.console();
        if (c == null) {
            System.out.println("System.console() == null: chương trình không chạy trong terminal tương tác");
        } else {
            c.printf("Hello %s%n", "console");
        }
        PrintStream out = System.out;
        out.printf("%-6s|%5.2f|%03d%n", "ab", 3.14159, 7);
        out.format("%s %b %c%n", "format", true, 'x');

        // Đọc dữ liệu "console" từ một nguồn giả lập thay cho System.in
        InputStream fakeIn = new ByteArrayInputStream("Nobin\n30\n".getBytes());
        try (BufferedReader in = new BufferedReader(new InputStreamReader(fakeIn))) {
            String name = in.readLine();
            int age = Integer.parseInt(in.readLine());
            System.out.println("name=" + name + ", age+1=" + (age + 1) + ", next=" + in.readLine());
        }
        System.err.flush();
    }
}
```

Output thật (JDK 21.0.10):

```text
System.console() == null: chương trình không chạy trong terminal tương tác
ab    | 3.14|007
format true x
name=Nobin, age+1=31, next=null
```
<!-- /EX -->

### 4. Serialization

<!-- EX:Ex04_Serialization -->
`examples/ch09/Ex04_Serialization.java`

```java
// objective: 9.2
// Serialization: Serializable, transient, static, serialVersionUID; constructor nào chạy khi deserialize?
import java.io.*;

public class Ex04_Serialization {
    static class Base {                                   // KHÔNG Serializable
        String baseName = "unset";
        Base() { System.out.println("  Base() constructor"); baseName = "from Base()"; }
    }

    static class User extends Base implements Serializable {
        private static final long serialVersionUID = 1L;
        static int instances = 0;                         // static: không được serialize
        String name;
        transient String password;                        // transient: bỏ qua
        int age = 18;
        User(String name, String password) {
            System.out.println("  User(...) constructor");
            this.name = name; this.password = password; this.baseName = "set by User";
            instances++;
        }
        { System.out.println("  instance initializer của User"); }
    }

    record Point(int x, int y) implements Serializable {
        Point { System.out.println("  Point canonical constructor"); }
    }

    public static void main(String[] args) throws Exception {
        System.out.println("serialize:");
        User u = new User("nobin", "secret");
        u.age = 30;
        try (ObjectOutputStream out = new ObjectOutputStream(new FileOutputStream("user.ser"))) {
            out.writeObject(u);
            out.writeObject(new Point(1, 2));
        }
        User.instances = 99;
        System.out.println("deserialize:");
        try (ObjectInputStream in = new ObjectInputStream(new FileInputStream("user.ser"))) {
            User back = (User) in.readObject();
            Point p = (Point) in.readObject();
            System.out.println("name=" + back.name + " password=" + back.password + " age=" + back.age
                    + " baseName=" + back.baseName + " instances=" + User.instances + " | " + p);
        }
        try (ObjectOutputStream out = new ObjectOutputStream(new ByteArrayOutputStream())) {
            out.writeObject(new Base());
        } catch (NotSerializableException e) {
            System.out.println("NotSerializableException: " + e.getMessage());
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
serialize:
  Base() constructor
  instance initializer của User
  User(...) constructor
  Point canonical constructor
deserialize:
  Base() constructor
  Point canonical constructor
name=nobin password=null age=30 baseName=from Base() instances=99 | Point[x=1, y=2]
  Base() constructor
NotSerializableException: Ex04_Serialization$Base
```
<!-- /EX -->

### 5. Path

<!-- EX:Ex05_PathBasics -->
`examples/ch09/Ex05_PathBasics.java`

```java
// objective: 9.3
// Path: tạo, lấy thành phần, resolve, relativize, normalize (chỉ thao tác chuỗi, không cần file tồn tại).
import java.nio.file.*;

public class Ex05_PathBasics {
    public static void main(String[] args) {
        Path p = Path.of("/home/nobin/projects/app/src/Main.java");
        System.out.println(p.getFileName() + " | " + p.getParent() + " | " + p.getRoot() + " | " + p.getNameCount());
        System.out.println(p.getName(0) + " | " + p.subpath(1, 3) + " | " + p.isAbsolute() + " | " + Path.of("a/b").isAbsolute());
        System.out.println(p.startsWith("/home") + " " + p.startsWith("home") + " " + p.endsWith("Main.java") + " " + p.endsWith(".java"));

        Path base = Path.of("/data/reports");
        System.out.println(base.resolve("2024/jan.csv") + " | " + base.resolve("/tmp/x") + " | " + base.resolveSibling("logs"));
        Path a = Path.of("/data/reports/2024");
        Path b = Path.of("/data/images/logo.png");
        System.out.println(a.relativize(b) + " | " + b.relativize(a));
        System.out.println(Path.of("a/./b/../c/./d").normalize() + " | " + Path.of("../../x").normalize() + " | " + Path.of("a/b/../../..").normalize());
        System.out.println(Path.of("docs", "java", "ocp.md") + " | " + Paths.get("x", "y") + " | " + Path.of("") .getNameCount());
        try {
            Path.of("rel/path").relativize(Path.of("/abs/path"));
        } catch (IllegalArgumentException e) {
            System.out.println("IllegalArgumentException: không relativize giữa path tuyệt đối và tương đối");
        }
        for (Path part : Path.of("x/y/z")) System.out.print("[" + part + "]");
        System.out.println();
    }
}
```

Output thật (JDK 21.0.10):

```text
Main.java | /home/nobin/projects/app/src | / | 6
home | nobin/projects | true | false
true false true false
/data/reports/2024/jan.csv | /tmp/x | /data/logs
../../images/logo.png | ../../reports/2024
a/c/d | ../../x | ..
docs/java/ocp.md | x/y | 1
IllegalArgumentException: không relativize giữa path tuyệt đối và tương đối
[x][y][z]
```
<!-- /EX -->

### 6. Files: tạo, đọc, ghi, copy, move, delete

<!-- EX:Ex06_FilesOps -->
`examples/ch09/Ex06_FilesOps.java`

```java
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
```

Output thật (JDK 21.0.10):

```text
[buy milk, learn java, sleep] size=26
exists? true, notExists(x)? true
FileAlreadyExistsException: work/copy.txt
moved: work/moved.txt, copy exists? false
NoSuchFileException: work/a/b
DirectoryNotEmptyException: work
deleteIfExists(nothing) = false
readString: 3 lines
```
<!-- /EX -->

### 7. Thuộc tính file

<!-- EX:Ex07_Attributes -->
`examples/ch09/Ex07_Attributes.java`

```java
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
```

Output thật (JDK 21.0.10):

```text
true true false 5 true true
attrs: dir=false file=true size=5 link=false
lastModified = 1970-01-01T00:00:00Z
isSymbolicLink=true isRegularFile(link)=true noFollow=false sameFile=true target=a.txt
Path.of("attr/../attr/a.txt") same as f? true, equals? false
```
<!-- /EX -->

### 8. Duyệt thư mục: list, walk, find, lines

<!-- EX:Ex08_WalkFind -->
`examples/ch09/Ex08_WalkFind.java`

```java
// objective: 9.3
// Duyệt cây thư mục: Files.list (1 cấp), Files.walk (đệ quy, có maxDepth), Files.find (có điều kiện).
import java.io.IOException;
import java.nio.file.*;
import java.util.stream.Stream;

public class Ex08_WalkFind {
    public static void main(String[] args) throws IOException {
        Path root = Path.of("tree");
        Files.createDirectories(root.resolve("src/main"));
        Files.createDirectories(root.resolve("docs"));
        Files.writeString(root.resolve("README.md"), "# tree");
        Files.writeString(root.resolve("src/main/App.java"), "class App {}");
        Files.writeString(root.resolve("src/main/Util.java"), "class Util {}");
        Files.writeString(root.resolve("docs/guide.md"), "guide");

        try (Stream<Path> s = Files.list(root)) {                  // Stream phải được đóng!
            System.out.println("list : " + s.map(Path::toString).sorted().toList());
        }
        try (Stream<Path> s = Files.walk(root)) {
            System.out.println("walk : " + s.map(Path::toString).sorted().toList());
        }
        try (Stream<Path> s = Files.walk(root, 1)) {
            System.out.println("depth1: " + s.count() + " paths (gồm cả chính root)");
        }
        try (Stream<Path> s = Files.find(root, 10, (p, attr) -> attr.isRegularFile() && p.toString().endsWith(".java"))) {
            System.out.println("find : " + s.map(p -> p.getFileName().toString()).sorted().toList());
        }
        try (Stream<String> lines = Files.lines(root.resolve("README.md"))) {
            System.out.println("lines: " + lines.toList());
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
list : [tree/README.md, tree/docs, tree/src]
walk : [tree, tree/README.md, tree/docs, tree/docs/guide.md, tree/src, tree/src/main, tree/src/main/App.java, tree/src/main/Util.java]
depth1: 4 paths (gồm cả chính root)
find : [App.java, Util.java]
lines: [# tree]
```
<!-- /EX -->

### 9. StandardOpenOption

<!-- EX:Ex09_OpenOptions -->
`examples/ch09/Ex09_OpenOptions.java`

```java
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
```

Output thật (JDK 21.0.10):

```text
[line1, line2]
CREATE_NEW trên file đã có → FileAlreadyExistsException
fresh
APPEND không kèm CREATE trên file chưa có → NoSuchFileException
```
<!-- /EX -->

### 10. DataStream và ObjectStream

<!-- EX:Ex10_DataStreams -->
`examples/ch09/Ex10_DataStreams.java`

```java
// objective: 9.1, 9.2
// DataOutputStream/DataInputStream (ghi primitive nhị phân) và ObjectOutputStream với nhiều object.
import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class Ex10_DataStreams {
    record Item(String name, int qty) implements Serializable { }

    public static void main(String[] args) throws Exception {
        try (DataOutputStream out = new DataOutputStream(new BufferedOutputStream(new FileOutputStream("nums.dat")))) {
            out.writeInt(42);
            out.writeDouble(2.5);
            out.writeUTF("xin chào");
            out.writeBoolean(true);
        }
        System.out.println("nums.dat size = " + new File("nums.dat").length());
        try (DataInputStream in = new DataInputStream(new BufferedInputStream(new FileInputStream("nums.dat")))) {
            System.out.println(in.readInt() + " " + in.readDouble() + " " + in.readUTF() + " " + in.readBoolean());
            try {
                in.readInt();                                 // hết dữ liệu
            } catch (EOFException e) {
                System.out.println("EOFException khi đọc quá cuối file");
            }
        }

        List<Item> cart = new ArrayList<>(List.of(new Item("pen", 2), new Item("book", 1)));
        try (ObjectOutputStream out = new ObjectOutputStream(new FileOutputStream("cart.ser"))) {
            out.writeObject(cart);                            // ArrayList và Item đều Serializable
        }
        try (ObjectInputStream in = new ObjectInputStream(new FileInputStream("cart.ser"))) {
            @SuppressWarnings("unchecked")
            List<Item> back = (List<Item>) in.readObject();
            System.out.println(back + " equals? " + back.equals(cart) + " same? " + (back == cart));
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
nums.dat size = 24
42 2.5 xin chào true
EOFException khi đọc quá cuối file
[Item[name=pen, qty=2], Item[name=book, qty=1]] equals? true same? false
```
<!-- /EX -->

### 11. mark/reset, InputStreamReader, transferTo

<!-- EX:Ex11_ReaderUtilities -->
`examples/ch09/Ex11_ReaderUtilities.java`

```java
// objective: 9.1
// mark/reset, skip, transferTo, InputStreamReader (cầu nối byte → char).
import java.io.*;
import java.nio.charset.StandardCharsets;

public class Ex11_ReaderUtilities {
    public static void main(String[] args) throws IOException {
        try (BufferedReader r = new BufferedReader(new StringReader("ABCDEFG"))) {
            System.out.print((char) r.read());          // A
            r.mark(10);                                  // đánh dấu vị trí hiện tại
            System.out.print((char) r.read());          // B
            System.out.print((char) r.read());          // C
            r.reset();                                   // quay lại chỗ mark
            System.out.print((char) r.read());          // B
            r.skip(2);                                   // bỏ C, D
            System.out.println((char) r.read() + " markSupported=" + r.markSupported());   // E
        }
        byte[] utf8 = "đẹp".getBytes(StandardCharsets.UTF_8);
        System.out.println("bytes=" + utf8.length + " chars=" + new String(utf8, StandardCharsets.UTF_8).length());
        try (Reader r = new InputStreamReader(new ByteArrayInputStream(utf8), StandardCharsets.UTF_8)) {
            System.out.println("first char via InputStreamReader: " + (char) r.read());
        }
        ByteArrayOutputStream sink = new ByteArrayOutputStream();
        long n = new ByteArrayInputStream("copy me".getBytes()).transferTo(sink);
        System.out.println("transferTo copied " + n + " bytes: " + sink);
    }
}
```

Output thật (JDK 21.0.10):

```text
ABCBE markSupported=true
bytes=6 chars=3
first char via InputStreamReader: đ
transferTo copied 7 bytes: copy me
```
<!-- /EX -->

### 12. Lỗi biên dịch với Path và Files.lines

<!-- EX:Ex12_IOCompileErrors -->
`examples/ch09/Ex12_IOCompileErrors.java`

```java
// objective: 9.1, 9.3
// expect: compile-error
// Lỗi hay gặp: Path là interface (không new được); Files.lines trả về Stream<String>, không phải List.
import java.nio.file.*;

public class Ex12_IOCompileErrors {
    public static void main(String[] args) {
        Path p = new Path("a.txt");
        java.util.List<String> lines = Files.lines(Path.of("a.txt"));
    }
}
```

Output thật của `javac` (JDK 21.0.10) — cố ý không biên dịch được:

```text
Ex12_IOCompileErrors.java:8: error: Path is abstract; cannot be instantiated
        Path p = new Path("a.txt");
                 ^
Ex12_IOCompileErrors.java:9: error: incompatible types: Stream<String> cannot be converted to List<String>
        java.util.List<String> lines = Files.lines(Path.of("a.txt"));
                                                  ^
2 errors
```
<!-- /EX -->

### 13. IOException là checked exception

<!-- EX:Ex13_CheckedIO -->
`examples/ch09/Ex13_CheckedIO.java`

```java
// objective: 9.1, 9.3
// expect: compile-error
// Hầu hết method của Files và I/O stream ném IOException (checked) → phải catch hoặc khai báo throws.
import java.nio.file.*;

public class Ex13_CheckedIO {
    public static void main(String[] args) {
        String all = Files.readString(Path.of("a.txt"));
        System.out.println(all);
    }
}
```

Output thật của `javac` (JDK 21.0.10) — cố ý không biên dịch được:

```text
Ex13_CheckedIO.java:8: error: unreported exception IOException; must be caught or declared to be thrown
        String all = Files.readString(Path.of("a.txt"));
                                     ^
1 error
```
<!-- /EX -->

## Đi sâu

### Các lớp stream hay gặp

| Loại | Đọc | Ghi | Ghi chú |
|---|---|---|---|
| Byte, file | `FileInputStream` | `FileOutputStream(name, append)` | `read()` trả về `int` 0..255, hoặc -1 khi hết |
| Byte, đệm | `BufferedInputStream` | `BufferedOutputStream` | Bọc (wrap) stream khác |
| Byte, primitive | `DataInputStream` | `DataOutputStream` | `readInt`/`writeInt`, `readUTF`… hết dữ liệu → `EOFException` |
| Byte, object | `ObjectInputStream` | `ObjectOutputStream` | `readObject()` ném thêm `ClassNotFoundException` |
| Char, file | `FileReader` | `FileWriter(name, append)` | Có constructor nhận `Charset` (Java 11+) |
| Char, đệm | `BufferedReader` (`readLine()` → `null` khi hết) | `BufferedWriter` (`newLine()`) | |
| Char, định dạng | — | `PrintWriter` (`println`, `printf`, `format`) | Không ném `IOException`; dùng `checkError()` |
| Cầu nối | `InputStreamReader` (byte → char) | `OutputStreamWriter` (char → byte) | Chỉ định charset |
| Bộ nhớ | `ByteArrayInputStream`, `StringReader` | `ByteArrayOutputStream`, `StringWriter` | Hữu ích để test |

Method chung: `close()` (dùng try-with-resources), `flush()` (ghi phần đệm ra đích), `skip(n)`, `mark(limit)` /
`reset()` (kiểm tra `markSupported()`), `readAllBytes()`, `transferTo(out)`.

Console: `System.in` (`InputStream`), `System.out`/`System.err` (`PrintStream`), `System.console()` có thể trả về
`null` khi không có terminal; `Console` có `readLine()`, `readPassword()` (trả `char[]`), `printf`, `writer()`, `reader()`.

### Serialization (9.2)

1. Lớp phải `implements Serializable` (interface đánh dấu, không có method). Mọi field được lưu cũng phải serialize
   được (hoặc là `transient`), nếu không → `NotSerializableException`.
2. `transient` và `static` **không** được lưu. Sau deserialize: field `transient` có giá trị mặc định.
3. Khi deserialize: constructor của lớp Serializable **không** chạy, khởi tạo field và instance initializer của nó
   cũng không chạy. Constructor **không tham số** của lớp cha **đầu tiên không Serializable** thì **có** chạy (nó phải
   truy cập được).
4. `private static final long serialVersionUID` — "phiên bản" của lớp; khác nhau khi đọc → `InvalidClassException`.
5. **Record** được deserialize qua **canonical constructor** (nên validation trong constructor vẫn chạy).
6. Tuỳ biến: `writeObject`/`readObject` private, `readResolve`, `writeReplace` (ít gặp trong đề).

### Path (9.3)

- Tạo: `Path.of("a", "b")`, `Paths.get(...)`, `file.toPath()`; ngược lại `path.toFile()`.
- Thành phần: `getFileName()`, `getParent()` (null nếu không có), `getRoot()` (null nếu tương đối), `getNameCount()`,
  `getName(i)` (gốc không tính), `subpath(begin, end)`, `isAbsolute()`, `toAbsolutePath()`, `iterator` (for-each).
- `resolve(other)`: nối; nếu `other` tuyệt đối → trả về `other`. `resolveSibling`.
- `relativize(other)`: đường đi từ path này tới `other`; cả hai phải cùng tuyệt đối hoặc cùng tương đối, nếu không →
  `IllegalArgumentException`.
- `normalize()`: bỏ `.` và `tên/..` (chỉ thao tác chuỗi). `toRealPath()`: hỏi hệ thống file (file phải tồn tại,
  giải quyết symbolic link).
- `equals`/`startsWith`/`endsWith` so sánh theo **thành phần path** (không phải chuỗi con): `p.endsWith(".java")` là
  `false` với `Main.java`. `Files.isSameFile` mới hỏi hệ thống file.

### Files (9.3)

| Nhóm | Method |
|---|---|
| Kiểm tra | `exists`, `notExists`, `isDirectory`, `isRegularFile`, `isSymbolicLink`, `isReadable`, `isWritable`, `isExecutable`, `isHidden`, `isSameFile` |
| Tạo | `createFile` (đã có → `FileAlreadyExistsException`), `createDirectory` (cha thiếu → `NoSuchFileException`), `createDirectories`, `createTempFile` |
| Đọc | `readString`, `readAllLines` (→ `List`), `readAllBytes`, `lines` (→ `Stream`, phải đóng), `newBufferedReader`, `newInputStream` |
| Ghi | `writeString`, `write(path, bytes|lines, options...)`, `newBufferedWriter`, `newOutputStream` |
| Copy / move / xoá | `copy` (đích đã có → `FileAlreadyExistsException`, trừ khi `REPLACE_EXISTING`), `move` (`ATOMIC_MOVE`), `delete` (không có → `NoSuchFileException`; thư mục không rỗng → `DirectoryNotEmptyException`), `deleteIfExists` (→ `boolean`) |
| Thuộc tính | `size`, `getLastModifiedTime`, `setLastModifiedTime`, `readAttributes(path, BasicFileAttributes.class)`, `getAttribute`, `getFileAttributeView` |
| Duyệt | `list` (1 cấp), `walk(start[, maxDepth])` (gồm cả `start`, depth-first), `find(start, maxDepth, BiPredicate<Path, BasicFileAttributes>)` |

`StandardOpenOption`: `CREATE`, `CREATE_NEW`, `APPEND`, `TRUNCATE_EXISTING`, `READ`, `WRITE`. Mặc định khi ghi:
`CREATE` + `TRUNCATE_EXISTING` + `WRITE`. `LinkOption.NOFOLLOW_LINKS` để không đi theo symbolic link.
Hầu hết method của `Files` ném `IOException` (checked).

## Lỗi và bẫy thường gặp (Exam traps)

1. `read()` trả về `int`; hết dữ liệu là `-1` (byte/char stream) — nhưng `readLine()` trả về `null` và `DataInputStream`
   ném `EOFException`.
2. `new FileOutputStream(f)` ghi đè; cần `new FileOutputStream(f, true)` để nối.
3. `PrintWriter`/`PrintStream` không ném `IOException`.
4. `System.console()` có thể là `null`.
5. `transient` và `static` không được serialize; constructor lớp Serializable không chạy khi deserialize.
6. `readObject()` ném cả `ClassNotFoundException`.
7. `Path` là interface: không `new Path(...)`.
8. `getName(0)` là phần đầu **sau** gốc; `getNameCount()` không tính gốc.
9. `resolve` với path tuyệt đối trả về chính path đó; `relativize` trộn tuyệt đối/tương đối → exception.
10. `normalize()` không kiểm tra file tồn tại; `Path.equals` không normalize.
11. `Files.walk` gồm cả thư mục bắt đầu; `Files.list` thì không.
12. `Files.lines`, `list`, `walk`, `find` trả về `Stream` phải đóng (try-with-resources).
13. `Files.copy`/`createFile` trên đích đã có → `FileAlreadyExistsException`.
14. `Files.delete` thư mục không rỗng → `DirectoryNotEmptyException`.

## Góc nhìn từ TypeScript

| Node.js / TypeScript | Java | Ghi chú |
|---|---|---|
| `fs.readFileSync(p, "utf8")` | `Files.readString(p)` | Java mặc định UTF-8 (Java 18+) |
| `fs.writeFileSync(p, s)` | `Files.writeString(p, s)` | |
| `fs.appendFileSync` | `Files.writeString(p, s, StandardOpenOption.APPEND)` | |
| `path.join`, `path.resolve`, `path.relative`, `path.normalize` | `Path.resolve`, `toAbsolutePath`, `relativize`, `normalize` | `path.resolve("/a", "b")` ~ `Path.of("/a").resolve("b")` |
| `fs.readdirSync(dir, { recursive: true })` | `Files.walk(dir)` | |
| `fs.createReadStream` + `pipe` | `InputStream` + `transferTo(out)` | |
| `JSON.stringify(obj)` | Java serialization (nhị phân) — hoặc thư viện JSON như Jackson | Serialization của Java khó đọc bằng mắt và có rủi ro bảo mật |
| Lỗi file: `ENOENT`, `EEXIST` | `NoSuchFileException`, `FileAlreadyExistsException` | Checked exception trong Java |

## Tóm tắt

- `java.io`: byte stream vs character stream; bọc bằng Buffered/Data/Object/Print; đóng bằng try-with-resources.
- Hết dữ liệu: `-1` (`read`), `null` (`readLine`), `EOFException` (`DataInputStream`).
- Serialization: `Serializable`, `transient`, `static` không lưu, constructor lớp cha không Serializable chạy.
- NIO.2: `Path` (thao tác chuỗi) + `Files` (thao tác thật trên đĩa, ném `IOException`).
- Duyệt: `list` (1 cấp), `walk` (đệ quy, gồm start), `find` (có điều kiện); nhớ đóng Stream.

## Bài tập (có lời giải)

Mọi đáp án đã được `tools/book.py` biên dịch và chạy để xác nhận (code: `examples/questions/ch09/`).
Mỗi câu chạy trong thư mục tạm riêng.

### Câu hỏi

<!-- QUESTIONS:ch09 -->
#### Câu 09-01 · Dễ · objective 9.3

Chương trình sau in ra gì?

```java
import java.nio.file.*;

public class Parts {
    public static void main(String[] args) {
        Path p = Path.of("/var/log/app/server.log");
        System.out.println(p.getFileName() + " " + p.getNameCount() + " " + p.getName(1) + " "
                + p.getParent().getFileName());
    }
}
```

- **A.** `server.log 5 var app`
- **B.** `server.log 4 var log`
- **C.** `/server.log 4 log app`
- **D.** `server.log 4 log app`

#### Câu 09-02 · Vừa · objective 9.3

Chương trình sau in ra gì?

```java
import java.nio.file.*;

public class Rel {
    public static void main(String[] args) {
        Path a = Path.of("/a/b/c");
        Path b = Path.of("/a/x");
        System.out.println(a.relativize(b) + " " + a.resolve("../d").normalize() + " " + b.resolve("/y"));
    }
}
```

- **A.** `../x /a/b/d /a/x/y`
- **B.** `../../x /a/b/c/d /y`
- **C.** `../../x /a/b/d /y`
- **D.** `x /a/d /y`

#### Câu 09-03 · Vừa · objective 9.1

Chương trình sau in ra gì?

```java
import java.io.*;
import java.nio.file.*;

public class Lines {
    public static void main(String[] args) throws IOException {
        Files.writeString(Path.of("f.txt"), "one\n\ntwo\n");
        try (BufferedReader r = Files.newBufferedReader(Path.of("f.txt"))) {
            String line;
            int n = 0;
            while ((line = r.readLine()) != null) n++;
            System.out.println(n);
        }
    }
}
```

- **A.** `2`
- **B.** `3`
- **C.** `4`
- **D.** Ném `EOFException`

#### Câu 09-04 · Khó · objective 9.2

Chương trình sau in ra gì?

```java
import java.io.*;

public class Ser {
    static class Animal {
        String sound = "?";
        Animal() { sound = "generic"; }
    }

    static class Dog extends Animal implements Serializable {
        String name;
        transient int age;
        Dog(String n, int a) { name = n; age = a; sound = "woof"; }
    }

    public static void main(String[] args) throws Exception {
        try (var out = new ObjectOutputStream(new FileOutputStream("dog.ser"))) {
            out.writeObject(new Dog("Rex", 5));
        }
        try (var in = new ObjectInputStream(new FileInputStream("dog.ser"))) {
            Dog d = (Dog) in.readObject();
            System.out.println(d.name + " " + d.age + " " + d.sound);
        }
    }
}
```

- **A.** `Rex 5 woof`
- **B.** `Rex 0 woof`
- **C.** `Rex 0 generic`
- **D.** `null 0 generic`

#### Câu 09-05 · Vừa · objective 9.1, 9.3

Những dòng nào gây lỗi biên dịch?

```java
import java.io.*;
import java.nio.file.*;

public class Io {
    static void a() throws IOException { Files.readString(Path.of("x")); }   // L1
    static void b() { Files.exists(Path.of("x")); }                            // L2
    static void c() { new FileReader("x"); }                                   // L3
    static void d() { Path.of("x").resolve("y"); }                             // L4
    static void e() { Files.delete(Path.of("x")); }                            // L5

    public static void main(String[] args) { }
}
```

- **A.** Chỉ L3
- **B.** L3 và L5
- **C.** L2 và L3
- **D.** L2, L3 và L5
- **E.** Chỉ L5

#### Câu 09-06 · Vừa · objective 9.3

Chèn dòng nào vào chỗ `// INSERT CODE HERE` thì chương trình biên dịch được? **(Chọn 3 đáp án.)**

```java
import java.io.File;
import java.nio.file.*;

public class Make {
    public static void main(String[] args) {
        // INSERT CODE HERE
    }
}
```

- **A.** `Path p = Path.of("a", "b");`
- **B.** `Path p = Paths.get("a/b");`
- **C.** `Path p = new Path("a/b");`
- **D.** `Path p = new File("a/b").toPath();`
- **E.** `Path p = Path.get("a/b");`

#### Câu 09-07 · Vừa · objective 9.3

Chương trình sau in ra gì?

```java
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
```

- **A.** `exists S`
- **B.** `S`
- **C.** `exists D`
- **D.** `D`

#### Câu 09-08 · Khó · objective 9.3

Chương trình sau in ra gì?

```java
import java.io.IOException;
import java.nio.file.*;
import java.util.stream.Stream;

public class Walk {
    public static void main(String[] args) throws IOException {
        Path root = Path.of("root");
        Files.createDirectories(root.resolve("sub/deep"));
        Files.writeString(root.resolve("a.txt"), "a");
        Files.writeString(root.resolve("sub/b.txt"), "b");
        Files.writeString(root.resolve("sub/deep/c.txt"), "c");
        try (Stream<Path> w1 = Files.walk(root, 1);
             Stream<Path> w2 = Files.walk(root);
             Stream<Path> l = Files.list(root)) {
            System.out.println(w1.count() + " " + w2.filter(Files::isRegularFile).count() + " " + l.count());
        }
    }
}
```

- **A.** `2 3 2`
- **B.** `3 3 3`
- **C.** `2 2 2`
- **D.** `3 3 2`

#### Câu 09-09 · Vừa · objective 9.2

Hai phát biểu nào đúng về serialization? **(Chọn 2 đáp án.)**

- **A.** Field `static` được lưu và khôi phục khi serialize/deserialize.
- **B.** Field `transient` nhận giá trị mặc định sau khi deserialize.
- **C.** Serialize object của lớp không implements `Serializable` ném `NotSerializableException`.
- **D.** Constructor của lớp `Serializable` được gọi khi deserialize.
- **E.** Mọi lớp cha của một lớp `Serializable` cũng phải là `Serializable`.

#### Câu 09-10 · Dễ · objective 9.1

Chương trình sau in ra gì?

```java
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
```

- **A.** `ABCD`
- **B.** `CD`
- **C.** `D`
- **D.** `ABD`

#### Câu 09-11 · Vừa · objective 9.3

Chương trình sau in ra gì?

```java
import java.nio.file.*;

public class Norm {
    public static void main(String[] args) {
        System.out.println(Path.of("./a/../../b").normalize() + " " + Path.of("/../x").normalize() + " "
                + Path.of("a/b/./c/..").normalize().getNameCount());
    }
}
```

- **A.** `b /../x 2`
- **B.** `../b /x 3`
- **C.** `../b /x 2`
- **D.** `b /x 2`

#### Câu 09-12 · Khó · objective 9.3

Chèn dòng nào vào chỗ `// INSERT CODE HERE` thì chương trình in ra `true`? **(Chọn 2 đáp án.)**

```java
import java.io.IOException;
import java.nio.file.*;

public class Same {
    public static void main(String[] args) throws IOException {
        Files.createDirectories(Path.of("data"));
        Files.writeString(Path.of("data/f.txt"), "x");
        Path a = Path.of("data/f.txt");
        Path b = Path.of("data/../data/f.txt");
        // INSERT CODE HERE
    }
}
```

- **A.** `System.out.println(a.equals(b));`
- **B.** `System.out.println(Files.isSameFile(a, b));`
- **C.** `System.out.println(a.equals(b.normalize()));`
- **D.** `System.out.println(a.toString().equals(b.toString()));`
- **E.** `System.out.println(a.compareTo(b) == 0);`

#### Câu 09-13 · Vừa · objective 9.2

Dòng nào gây lỗi biên dịch?

```java
import java.io.*;

public class Read {
    static Object a(ObjectInputStream in) throws IOException { return in.readObject(); }                           // L1
    static Object b(ObjectInputStream in) throws IOException, ClassNotFoundException { return in.readObject(); }   // L2
    static Object c(ObjectInputStream in) throws Exception { return in.readObject(); }                             // L3
    static void d(ObjectOutputStream out) throws IOException { out.writeObject("x"); }                             // L4

    public static void main(String[] args) { }
}
```

- **A.** L1
- **B.** L2
- **C.** L3
- **D.** L1 và L3
- **E.** Không dòng nào

#### Câu 09-14 · Vừa · objective 9.1, 9.3

Chương trình sau in ra gì?

```java
import java.io.IOException;
import java.nio.file.*;
import java.util.List;
import java.util.stream.Stream;

public class Sum {
    public static void main(String[] args) throws IOException {
        Path p = Path.of("n.txt");
        Files.write(p, List.of("3", "1", "2"));
        try (Stream<String> s = Files.lines(p)) {
            System.out.println(s.mapToInt(Integer::parseInt).sum() + " " + Files.readAllLines(p).get(0)
                    + " " + Files.size(p));
        }
    }
}
```

- **A.** `6 3 3`
- **B.** `321 3 6`
- **C.** `6 1 6`
- **D.** `6 3 6`

#### Câu 09-15 · Khó · objective 9.1

File mã nguồn được lưu bằng UTF-8. Chương trình sau in ra gì?

```java
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
```

- **A.** `4 4 4`
- **B.** `4 6 4`
- **C.** `6 6 6`
- **D.** `4 6 6`

#### Câu 09-16 · Vừa · objective 9.3

Hai phát biểu nào đúng về lớp `Files`? **(Chọn 2 đáp án.)**

- **A.** `Files.createDirectory` ném exception nếu thư mục cha chưa tồn tại.
- **B.** `Files.createDirectories` ném exception nếu thư mục đã tồn tại.
- **C.** `Files.delete` trên file không tồn tại ném `NoSuchFileException`.
- **D.** `Files.deleteIfExists` ném exception nếu file không tồn tại.
- **E.** `Files.move` giữ lại file nguồn.

#### Câu 09-17 · Dễ · objective 9.1

Chương trình được chạy với output chuyển hướng vào file (`java Cons > out.txt`). Nội dung `out.txt` là gì?

```java
import java.io.Console;

public class Cons {
    public static void main(String[] args) {
        Console c = System.console();
        System.out.println(c == null ? "no console" : "console");
    }
}
```

- **A.** `no console`
- **B.** `console`
- **C.** Ném `NullPointerException`
- **D.** Không biên dịch được vì `Console` không có constructor public

#### Câu 09-18 · Khó · objective 9.1

Chương trình sau in ra gì?

```java
import java.io.*;

public class Mark {
    public static void main(String[] args) throws IOException {
        try (Reader r = new BufferedReader(new StringReader("12345"))) {
            r.read();
            r.mark(5);
            r.read();
            r.read();
            r.reset();
            r.skip(1);
            System.out.println((char) r.read());
        }
    }
}
```

- **A.** `2`
- **B.** `4`
- **C.** `3`
- **D.** `1`

#### Câu 09-19 · Vừa · objective 9.1

Chương trình sau in ra gì?

```java
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
```

- **A.** `3`
- **B.** `12`
- **C.** `24`
- **D.** `13`

#### Câu 09-20 · Vừa · objective 9.1, 4.1

Chèn dòng nào vào chỗ `// INSERT CODE HERE` thì chương trình biên dịch và in ra `x`? **(Chọn 3 đáp án.)**

```java
import java.io.*;
import java.nio.file.*;

public class Twr {
    public static void main(String[] args) throws IOException {
        Files.writeString(Path.of("t.txt"), "x");
        // INSERT CODE HERE
    }
}
```

- **A.** `try (var r = new BufferedReader(new FileReader("t.txt"))) { System.out.println(r.readLine()); }`
- **B.** `try (Path p = Path.of("t.txt")) { System.out.println(Files.readString(p)); }`
- **C.** `try (var in = Files.newInputStream(Path.of("t.txt"))) { System.out.println((char) in.read()); }`
- **D.** `try (String s = Files.readString(Path.of("t.txt"))) { System.out.println(s); }`
- **E.** `try (var lines = Files.lines(Path.of("t.txt"))) { lines.forEach(System.out::println); }`
<!-- /QUESTIONS -->

### Lời giải

<!-- ANSWERS:ch09 -->
#### Câu 09-01 — Đáp án: **D** (Dễ · objective 9.3)

- **Vì sao đúng:** Các thành phần tên (name elements) là `var`, `log`, `app`, `server.log` — gốc `/` **không** tính. Vậy có 4 phần, `getName(1)` là `log` (chỉ số từ 0). `getParent()` là `/var/log/app`, tên cuối của nó là `app`.
- **A sai:** Gốc `/` không phải một name element nên chỉ có 4 phần.
- **B sai:** `getName(0)` là `var`, nên `getName(1)` là `log`; `getParent().getFileName()` là `app`.
- **C sai:** `getFileName()` chỉ trả về phần cuối, không có `/`.
- *Kiểm chứng:* `examples/questions/ch09/Q09_01/` — output confirmed (`python3 tools/book.py questions ch09`).

#### Câu 09-02 — Đáp án: **C** (Vừa · objective 9.3)

- **Vì sao đúng:** `a.relativize(b)`: từ `/a/b/c` đi lên 2 cấp tới `/a`, rồi vào `x` → `../../x`. `resolve("../d")` cho `/a/b/c/../d`, `normalize()` bỏ `c/..` → `/a/b/d`. `resolve` với path **tuyệt đối** trả về chính path đó → `/y`.
- **A sai:** Phải đi lên 2 cấp (`c` và `b`); và `resolve("/y")` trả về `/y`, không nối.
- **B sai:** `normalize()` xoá cặp `c/..`, nên không còn `c`.
- **D sai:** `relativize` cần `../..` để đi lên từ `/a/b/c`.
- *Kiểm chứng:* `examples/questions/ch09/Q09_02/` — output confirmed (`python3 tools/book.py questions ch09`).

#### Câu 09-03 — Đáp án: **B** (Vừa · objective 9.1)

- **Vì sao đúng:** `readLine()` trả về `"one"`, `""` (dòng trống vẫn là một dòng), `"two"`, rồi `null`. Ký tự xuống dòng cuối cùng không tạo thêm dòng.
- **A sai:** Dòng trống được `readLine()` trả về là chuỗi rỗng `""`, không phải `null`, nên vẫn được đếm.
- **C sai:** `\n` cuối file chỉ kết thúc dòng `two`, không tạo dòng thứ tư.
- **D sai:** `readLine()` báo hết dữ liệu bằng `null`, không ném exception.
- *Kiểm chứng:* `examples/questions/ch09/Q09_03/` — output confirmed (`python3 tools/book.py questions ch09`).

#### Câu 09-04 — Đáp án: **C** (Khó · objective 9.2)

- **Vì sao đúng:** Khi deserialize, constructor của lớp Serializable (`Dog`) **không** chạy; field của nó lấy từ dữ liệu đã lưu (`name`), trừ `transient` (`age` = 0). Lớp cha **không** Serializable (`Animal`) thì constructor không tham số của nó **có** chạy, nên field `sound` của `Animal` được khởi tạo lại thành `"generic"`.
- **A sai:** `transient` không được lưu → `age` = 0; và `sound` thuộc lớp cha không Serializable nên không được lưu.
- **B sai:** Field `sound` khai báo ở `Animal` (không Serializable) nên được tạo lại bởi `Animal()` → `generic`.
- **D sai:** `name` là field của `Dog` (Serializable) nên được khôi phục.
- *Kiểm chứng:* `examples/questions/ch09/Q09_04/` — output confirmed (`python3 tools/book.py questions ch09`).

#### Câu 09-05 — Đáp án: **B** (Vừa · objective 9.1, 9.3)

- **Vì sao đúng:** Constructor `FileReader(String)` ném `FileNotFoundException` và `Files.delete` ném `IOException` — cả hai là checked nên phải catch hoặc khai báo (L3, L5). `Files.exists` và các method thao tác chuỗi của `Path` không ném checked exception.
- **A sai:** `Files.delete` cũng ném `IOException` (checked).
- **C sai:** `Files.exists` trả về `boolean`, không ném checked exception.
- **D sai:** L2 hợp lệ (xem C).
- **E sai:** `new FileReader("x")` ném `FileNotFoundException` (checked).
- *Kiểm chứng:* `examples/questions/ch09/Q09_05/` — compile error confirmed at ['L3', 'L5'] (`python3 tools/book.py questions ch09`).

#### Câu 09-06 — Đáp án: **A, B, D** (Vừa · objective 9.3)

- **Vì sao đúng:** `Path` là interface, tạo bằng factory: `Path.of(...)` (Java 11+), `Paths.get(...)`, hoặc chuyển từ `File` bằng `toPath()`.
- **C sai:** `Path` là interface, không `new` được.
- **E sai:** `Path` không có method `get`; đó là `Paths.get` hoặc `Path.of`.
- *Kiểm chứng:* `examples/questions/ch09/Q09_06/` — variants: ABD satisfy compiles (`python3 tools/book.py questions ch09`).

#### Câu 09-07 — Đáp án: **A** (Vừa · objective 9.3)

- **Vì sao đúng:** `Files.copy` mặc định **không ghi đè**: đích đã tồn tại → `FileAlreadyExistsException`. Lần copy thứ hai có `REPLACE_EXISTING` nên ghi đè → nội dung `S`.
- **B sai:** Lần copy đầu ném exception vì `d.txt` đã có.
- **C sai:** Lần copy thứ hai với `REPLACE_EXISTING` đã ghi đè nội dung.
- **D sai:** Như C.
- *Kiểm chứng:* `examples/questions/ch09/Q09_07/` — output confirmed (`python3 tools/book.py questions ch09`).

#### Câu 09-08 — Đáp án: **D** (Khó · objective 9.3)

- **Vì sao đúng:** `walk(root, 1)` gồm **chính root** và các mục con trực tiếp: `root`, `a.txt`, `sub` → 3. `walk(root)` đi hết độ sâu; có 3 file thường. `list(root)` chỉ liệt kê con trực tiếp, **không** gồm root: `a.txt`, `sub` → 2.
- **A sai:** `Files.walk` luôn trả về cả path bắt đầu (root).
- **B sai:** `Files.list` không bao gồm chính thư mục root.
- **C sai:** `walk` đệ quy toàn bộ nên thấy cả `c.txt` trong `sub/deep`; và `walk(root, 1)` có 3 phần tử.
- *Kiểm chứng:* `examples/questions/ch09/Q09_08/` — output confirmed (`python3 tools/book.py questions ch09`).

#### Câu 09-09 — Đáp án: **B, C** (Vừa · objective 9.2)

- **Vì sao đúng:** B: `transient` không được ghi, nên khi đọc lại nhận giá trị mặc định (`null` cho object). C: chỉ lớp implements `Serializable` mới serialize được.
- **A sai:** `static` thuộc về lớp, không thuộc object → không được lưu (giá trị 99 được giữ nguyên).
- **D sai:** Constructor của lớp Serializable không chạy khi deserialize (đếm chỉ tăng 1 lần lúc `new`).
- **E sai:** Lớp cha không Serializable vẫn được, miễn là có constructor không tham số truy cập được.
- *Kiểm chứng:* `examples/questions/ch09/Q09_09/` — each option proven true/false by a program (`python3 tools/book.py questions ch09`).

#### Câu 09-10 — Đáp án: **B** (Dễ · objective 9.1)

- **Vì sao đúng:** `new FileOutputStream(name)` mặc định **ghi đè** (xoá nội dung cũ): còn `C`. Tham số thứ hai `true` là chế độ **append**: thêm `D` vào cuối → `CD`.
- **A sai:** Lần mở thứ hai (không append) đã xoá `AB`.
- **C sai:** Lần cuối mở ở chế độ append nên giữ `C`.
- **D sai:** Lần mở thứ hai ghi đè `AB` bằng `C`.
- *Kiểm chứng:* `examples/questions/ch09/Q09_10/` — output confirmed (`python3 tools/book.py questions ch09`).

#### Câu 09-11 — Đáp án: **C** (Vừa · objective 9.3)

- **Vì sao đúng:** `normalize()` bỏ `.` và triệt tiêu `tên/..`. `./a/../../b` → `a/..` mất, còn `../b` (không có gì để triệt tiêu `..` còn lại trong path tương đối). Với path tuyệt đối, `..` ngay sau gốc bị bỏ → `/x`. `a/b/./c/..` → `a/b` (2 phần).
- **A sai:** Path tương đối giữ `..` không triệt tiêu được; path tuyệt đối thì bỏ `..` sau gốc.
- **B sai:** `c/..` triệt tiêu nhau nên còn `a/b` — 2 phần.
- **D sai:** `..` thừa trong path tương đối được giữ lại: `../b`.
- *Kiểm chứng:* `examples/questions/ch09/Q09_11/` — output confirmed (`python3 tools/book.py questions ch09`).

#### Câu 09-12 — Đáp án: **B, C** (Khó · objective 9.3)

- **Vì sao đúng:** `Path.equals`/`compareTo` so sánh **chuỗi đường dẫn**, không nhìn hệ thống file. `normalize()` biến `b` thành `data/f.txt` nên C đúng. `Files.isSameFile` hỏi hệ thống file xem hai path có trỏ cùng một file không → B đúng.
- **A sai:** Hai chuỗi path khác nhau nên `equals` là `false`.
- **D sai:** Chuỗi `data/f.txt` khác `data/../data/f.txt`.
- **E sai:** `compareTo` so sánh chuỗi, khác 0.
- *Kiểm chứng:* `examples/questions/ch09/Q09_12/` — variants: BC satisfy output (`python3 tools/book.py questions ch09`).

#### Câu 09-13 — Đáp án: **A** (Vừa · objective 9.2)

- **Vì sao đúng:** `readObject()` khai báo `throws IOException, ClassNotFoundException`. `ClassNotFoundException` **không** phải lớp con của `IOException`, nên L1 thiếu nó → lỗi. L2 khai báo đủ, L3 khai báo `Exception` (bao cả hai).
- **B sai:** L2 khai báo đủ cả hai checked exception.
- **C sai:** `throws Exception` bao gồm cả `IOException` và `ClassNotFoundException`.
- **D sai:** L3 hợp lệ (xem C).
- **E sai:** L1 thiếu `ClassNotFoundException`.
- *Kiểm chứng:* `examples/questions/ch09/Q09_13/` — compile error confirmed at ['L1'] (`python3 tools/book.py questions ch09`).

#### Câu 09-14 — Đáp án: **D** (Vừa · objective 9.1, 9.3)

- **Vì sao đúng:** `Files.write(path, lines)` ghi mỗi phần tử kèm ký tự xuống dòng: `3\n1\n2\n` = 6 byte. `Files.lines` trả về `Stream<String>` (lười, cần đóng); tổng = 6. `readAllLines` trả về `List` theo thứ tự trong file → phần tử đầu `3`.
- **A sai:** Mỗi dòng có thêm ký tự `\n`, nên file có 6 byte.
- **B sai:** `mapToInt(Integer::parseInt).sum()` cộng số, không nối chuỗi.
- **C sai:** `readAllLines` giữ thứ tự của file; dòng đầu là `3`.
- *Kiểm chứng:* `examples/questions/ch09/Q09_14/` — output confirmed (`python3 tools/book.py questions ch09`).

#### Câu 09-15 — Đáp án: **B** (Khó · objective 9.1)

- **Vì sao đúng:** `String.length()` đếm **ký tự** (char): V, i, ệ, t → 4. `Files.writeString` mặc định dùng UTF-8; ký tự `ệ` cần 3 byte nên file có 1 + 1 + 3 + 1 = 6 **byte**. Đọc lại bằng UTF-8 được đúng 4 ký tự.
- **A sai:** Kích thước file tính bằng byte; `ệ` chiếm 3 byte trong UTF-8.
- **C sai:** `length()` của `String` đếm ký tự, không đếm byte.
- **D sai:** `readString` giải mã UTF-8 lại thành 4 ký tự.
- *Kiểm chứng:* `examples/questions/ch09/Q09_15/` — output confirmed (`python3 tools/book.py questions ch09`).

#### Câu 09-16 — Đáp án: **A, C** (Vừa · objective 9.3)

- **Vì sao đúng:** A: `createDirectory` chỉ tạo **một** cấp; cha thiếu → `NoSuchFileException`. C: `delete` bắt buộc file phải tồn tại.
- **B sai:** `createDirectories` tạo mọi cấp còn thiếu và không lỗi khi thư mục đã có.
- **D sai:** `deleteIfExists` trả về `false` khi không có gì để xoá.
- **E sai:** `move` di chuyển (đổi tên) nên file nguồn không còn.
- *Kiểm chứng:* `examples/questions/ch09/Q09_16/` — each option proven true/false by a program (`python3 tools/book.py questions ch09`).

#### Câu 09-17 — Đáp án: **A** (Dễ · objective 9.1)

- **Vì sao đúng:** `System.console()` trả về `null` khi JVM không gắn với một terminal tương tác (ví dụ output bị chuyển hướng hoặc chạy trong script). Vì vậy code dùng `Console` luôn phải kiểm tra `null`.
- **B sai:** Khi output bị chuyển hướng, không có console tương tác.
- **C sai:** Code chỉ so sánh `c == null`, không gọi method trên `c`.
- **D sai:** Code không `new Console()`; nó lấy qua `System.console()`.
- *Kiểm chứng:* `examples/questions/ch09/Q09_17/` — output confirmed (`python3 tools/book.py questions ch09`).

#### Câu 09-18 — Đáp án: **C** (Khó · objective 9.1)

- **Vì sao đúng:** Đọc `1` → `mark` tại vị trí của `2`. Đọc `2`, `3`. `reset()` quay về chỗ `mark` (trước `2`). `skip(1)` bỏ `2`. Lần đọc tiếp theo là `3`.
- **A sai:** `skip(1)` bỏ qua `2` sau khi reset.
- **B sai:** `reset()` quay lại vị trí mark, không tiếp tục từ `4`.
- **D sai:** Mark đặt sau khi đã đọc `1`, nên reset không quay về `1`.
- *Kiểm chứng:* `examples/questions/ch09/Q09_18/` — output confirmed (`python3 tools/book.py questions ch09`).

#### Câu 09-19 — Đáp án: **D** (Vừa · objective 9.1)

- **Vì sao đúng:** `DataOutputStream` ghi dạng nhị phân với kích thước cố định: `int` 4 byte, `long` 8 byte, `byte` 1 byte → 13 byte.
- **A sai:** Không ghi dạng chữ số; mỗi kiểu có kích thước nhị phân cố định.
- **B sai:** `long` chiếm 8 byte, `int` 4 byte và `byte` 1 byte: tổng 13.
- **C sai:** Không có đệm (padding); tổng là 4 + 8 + 1.
- *Kiểm chứng:* `examples/questions/ch09/Q09_19/` — output confirmed (`python3 tools/book.py questions ch09`).

#### Câu 09-20 — Đáp án: **A, C, E** (Vừa · objective 9.1, 4.1)

- **Vì sao đúng:** Tài nguyên trong try-with-resources phải là `AutoCloseable`: `BufferedReader` (A), `InputStream` (C) và `Stream` (E, `Stream` implements `AutoCloseable` — `Files.lines` nên luôn được đóng).
- **B sai:** `Path` không implements `AutoCloseable`.
- **D sai:** `String` không implements `AutoCloseable`.
- *Kiểm chứng:* `examples/questions/ch09/Q09_20/` — variants: ACE satisfy output (`python3 tools/book.py questions ch09`).
<!-- /ANSWERS -->

## Đọc thêm (link chính thức — bị chặn trong sandbox nên mình chưa mở được)

- Javadoc `java.nio.file.Files`: https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/nio/file/Files.html
- Java Object Serialization Specification: https://docs.oracle.com/en/java/javase/21/docs/specs/serialization/index.html

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:

- `Files.java`: https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/nio/file/Files.java
- `Path.java` (`resolve`, `relativize`, `normalize`, `endsWith`): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/nio/file/Path.java
- `ObjectInputStream.java` (deserialize record qua canonical constructor, constructor lớp cha không Serializable): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/io/ObjectInputStream.java
- `Serializable.java`: https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/io/Serializable.java
