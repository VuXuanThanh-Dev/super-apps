import java.io.*;
public class P {
    static class S implements Serializable { static int count = 1; }
    public static void main(String[] a) throws Exception {
        var bytes = new ByteArrayOutputStream();
        try (var out = new ObjectOutputStream(bytes)) { out.writeObject(new S()); }
        S.count = 99;
        try (var in = new ObjectInputStream(new ByteArrayInputStream(bytes.toByteArray()))) { in.readObject(); }
        System.out.println(S.count);
    }
}
