import java.io.*;
public class P {
    static int calls = 0;
    static class S implements Serializable { S() { calls++; } }
    public static void main(String[] a) throws Exception {
        var bytes = new ByteArrayOutputStream();
        try (var out = new ObjectOutputStream(bytes)) { out.writeObject(new S()); }
        try (var in = new ObjectInputStream(new ByteArrayInputStream(bytes.toByteArray()))) { in.readObject(); }
        System.out.println(calls);
    }
}
