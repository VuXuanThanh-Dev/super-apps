import java.io.*;

public class Ser2 {
    static class Base implements Serializable { int b = 1; }

    static class Sub extends Base {
        int s = 2;
        transient int t = 3;
        static int st = 4;
        Sub() { b = 10; s = 20; t = 30; }
    }

    public static void main(String[] args) throws Exception {
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        try (var out = new ObjectOutputStream(bytes)) { out.writeObject(new Sub()); }
        Sub.st = 40;
        try (var in = new ObjectInputStream(new ByteArrayInputStream(bytes.toByteArray()))) {
            Sub x = (Sub) in.readObject();
            System.out.println(x.b + " " + x.s + " " + x.t + " " + Sub.st);
        }
    }
}
