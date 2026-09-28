import java.io.*;

public class Unreported {
    static void save() throws IOException { }
    static void run() { save(); }                                      // L1
    static void run2() throws Exception { save(); }                    // L2
    static void run3() { try { save(); } catch (Exception e) { } }     // L3

    public static void main(String[] args) { }
}
