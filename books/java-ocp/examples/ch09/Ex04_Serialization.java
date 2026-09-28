// objective: 9.2
// Serialization: Serializable, transient, static, serialVersionUID; constructor nào chạy khi deserialize?
import java.io.*;

public class Ex04_Serialization {
    static class Base {                                   // KHÔNG Serializable
        String baseName = "unset";
        Base() { System.out.println("  Base() constructor"); baseName = "from Base()"; }
    }

    static class User extends Base implements Serializable {
        private static final long serialVersionUID = 1L;
        static int instances = 0;                         // static: không được serialize
        String name;
        transient String password;                        // transient: bỏ qua
        int age = 18;
        User(String name, String password) {
            System.out.println("  User(...) constructor");
            this.name = name; this.password = password; this.baseName = "set by User";
            instances++;
        }
        { System.out.println("  instance initializer của User"); }
    }

    record Point(int x, int y) implements Serializable {
        Point { System.out.println("  Point canonical constructor"); }
    }

    public static void main(String[] args) throws Exception {
        System.out.println("serialize:");
        User u = new User("nobin", "secret");
        u.age = 30;
        try (ObjectOutputStream out = new ObjectOutputStream(new FileOutputStream("user.ser"))) {
            out.writeObject(u);
            out.writeObject(new Point(1, 2));
        }
        User.instances = 99;
        System.out.println("deserialize:");
        try (ObjectInputStream in = new ObjectInputStream(new FileInputStream("user.ser"))) {
            User back = (User) in.readObject();
            Point p = (Point) in.readObject();
            System.out.println("name=" + back.name + " password=" + back.password + " age=" + back.age
                    + " baseName=" + back.baseName + " instances=" + User.instances + " | " + p);
        }
        try (ObjectOutputStream out = new ObjectOutputStream(new ByteArrayOutputStream())) {
            out.writeObject(new Base());
        } catch (NotSerializableException e) {
            System.out.println("NotSerializableException: " + e.getMessage());
        }
    }
}
