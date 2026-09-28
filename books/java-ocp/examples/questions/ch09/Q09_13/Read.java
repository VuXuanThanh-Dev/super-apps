import java.io.*;

public class Read {
    static Object a(ObjectInputStream in) throws IOException { return in.readObject(); }                           // L1
    static Object b(ObjectInputStream in) throws IOException, ClassNotFoundException { return in.readObject(); }   // L2
    static Object c(ObjectInputStream in) throws Exception { return in.readObject(); }                             // L3
    static void d(ObjectOutputStream out) throws IOException { out.writeObject("x"); }                             // L4

    public static void main(String[] args) { }
}
