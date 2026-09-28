import java.io.*;
import java.util.*;

public class Graph {
    static class Node implements Serializable {
        String n;
        Node next;
        Node(String n) { this.n = n; }
    }

    public static void main(String[] args) throws Exception {
        Node a = new Node("a"), b = new Node("b");
        a.next = b;
        b.next = a;
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        try (var out = new ObjectOutputStream(bytes)) { out.writeObject(new ArrayList<>(List.of(a, b))); }
        try (var in = new ObjectInputStream(new ByteArrayInputStream(bytes.toByteArray()))) {
            @SuppressWarnings("unchecked")
            List<Node> r = (List<Node>) in.readObject();
            System.out.println((r.get(0).next == r.get(1)) + " " + (r.get(1).next == r.get(0)) + " " + (r.get(0) == a));
        }
    }
}
