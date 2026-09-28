import java.io.*;
public class P {
    static class Base { }
    static class S extends Base implements Serializable { int v = 7; }
    public static void main(String[] a) throws Exception {
        var bytes = new ByteArrayOutputStream();
        try (var out = new ObjectOutputStream(bytes)) { out.writeObject(new S()); }
        try (var in = new ObjectInputStream(new ByteArrayInputStream(bytes.toByteArray()))) {
            System.out.println(((S) in.readObject()).v);
        }
    }
}
