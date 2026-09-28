// objective: 9.1, 9.2
// DataOutputStream/DataInputStream (ghi primitive nhị phân) và ObjectOutputStream với nhiều object.
import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class Ex10_DataStreams {
    record Item(String name, int qty) implements Serializable { }

    public static void main(String[] args) throws Exception {
        try (DataOutputStream out = new DataOutputStream(new BufferedOutputStream(new FileOutputStream("nums.dat")))) {
            out.writeInt(42);
            out.writeDouble(2.5);
            out.writeUTF("xin chào");
            out.writeBoolean(true);
        }
        System.out.println("nums.dat size = " + new File("nums.dat").length());
        try (DataInputStream in = new DataInputStream(new BufferedInputStream(new FileInputStream("nums.dat")))) {
            System.out.println(in.readInt() + " " + in.readDouble() + " " + in.readUTF() + " " + in.readBoolean());
            try {
                in.readInt();                                 // hết dữ liệu
            } catch (EOFException e) {
                System.out.println("EOFException khi đọc quá cuối file");
            }
        }

        List<Item> cart = new ArrayList<>(List.of(new Item("pen", 2), new Item("book", 1)));
        try (ObjectOutputStream out = new ObjectOutputStream(new FileOutputStream("cart.ser"))) {
            out.writeObject(cart);                            // ArrayList và Item đều Serializable
        }
        try (ObjectInputStream in = new ObjectInputStream(new FileInputStream("cart.ser"))) {
            @SuppressWarnings("unchecked")
            List<Item> back = (List<Item>) in.readObject();
            System.out.println(back + " equals? " + back.equals(cart) + " same? " + (back == cart));
        }
    }
}
