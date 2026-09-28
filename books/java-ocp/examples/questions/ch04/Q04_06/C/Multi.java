import java.io.*;

public class Multi {
    static void work() throws IOException { }

    public static void main(String[] args) {
        try {
            work();
        } catch (IOException | IllegalStateException e) { e = null; }
    }
}
