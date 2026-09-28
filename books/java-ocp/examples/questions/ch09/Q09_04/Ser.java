import java.io.*;

public class Ser {
    static class Animal {
        String sound = "?";
        Animal() { sound = "generic"; }
    }

    static class Dog extends Animal implements Serializable {
        String name;
        transient int age;
        Dog(String n, int a) { name = n; age = a; sound = "woof"; }
    }

    public static void main(String[] args) throws Exception {
        try (var out = new ObjectOutputStream(new FileOutputStream("dog.ser"))) {
            out.writeObject(new Dog("Rex", 5));
        }
        try (var in = new ObjectInputStream(new FileInputStream("dog.ser"))) {
            Dog d = (Dog) in.readObject();
            System.out.println(d.name + " " + d.age + " " + d.sound);
        }
    }
}
