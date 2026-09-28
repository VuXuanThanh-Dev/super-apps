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
