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
