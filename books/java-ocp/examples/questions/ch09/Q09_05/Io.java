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
