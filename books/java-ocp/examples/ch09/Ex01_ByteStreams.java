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
