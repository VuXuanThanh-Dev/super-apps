import java.io.*;

public class Re {
    static void io() throws IOException { }

    static void a() throws IOException {
        try { io(); } catch (Exception e) { throw e; }                          // L1
    }
    static void b() throws IOException {
        try { io(); } catch (Exception e) { e = new Exception(); throw e; }     // L2
    }
    static void c() {
        try { io(); } catch (IOException e) { throw new RuntimeException(e); }  // L3
    }

    public static void main(String[] args) { }
}
