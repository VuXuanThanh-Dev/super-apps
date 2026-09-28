import java.io.*;

public class Throws {
    static class Reader { void read() throws IOException { } }
    static class A extends Reader { void read() throws FileNotFoundException { } }   // L1
    static class B extends Reader { void read() { } }                                 // L2
    static class C extends Reader { void read() throws Exception { } }                // L3
    static class D extends Reader { void read() throws IllegalStateException { } }    // L4

    public static void main(String[] args) { }
}
