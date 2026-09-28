import java.io.*;
public class P {
    static class S implements Serializable { transient String t = "set"; }
    public static void main(String[] a) throws Exception {
        var bytes = new ByteArrayOutputStream();
        try (var out = new ObjectOutputStream(bytes)) { out.writeObject(new S()); }
        try (var in = new ObjectInputStream(new ByteArrayInputStream(bytes.toByteArray()))) {
            System.out.println(((S) in.readObject()).t);
        }
    }
}
