import java.io.*;

public class Impl {
    interface Loader { String load() throws IOException; }

    static class A implements Loader { public String load() { return "a"; } }                                 // L1
    static class B implements Loader { public String load() throws FileNotFoundException { return "b"; } }    // L2
    static class C implements Loader { public String load() throws Exception { return "c"; } }                // L3
    static class D implements Loader { String load() { return "d"; } }                                        // L4

    public static void main(String[] args) { new A().load(); }                                                 // L5
}
