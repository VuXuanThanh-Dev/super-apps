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
