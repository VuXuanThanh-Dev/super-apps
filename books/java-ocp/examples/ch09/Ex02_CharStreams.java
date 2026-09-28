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
