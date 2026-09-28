import java.io.*;
public class P {
    static class N { }
    public static void main(String[] a) throws Exception {
        try (var out = new ObjectOutputStream(new ByteArrayOutputStream())) { out.writeObject(new N()); }
    }
}
