import java.io.*;

public class Catch {
    static void io() throws IOException { }

    public static void main(String[] args) {
        try { io(); } catch (FileNotFoundException | IOException e) { }         // L1
        try { io(); } catch (IOException | RuntimeException e) { }             // L2
        try { io(); } catch (Exception e) { } catch (IOException e) { }        // L3
        try { io(); } catch (IOException e) { throw new RuntimeException(e); } // L4
    }
}
