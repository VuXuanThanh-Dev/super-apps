import java.io.Console;

public class Cons {
    public static void main(String[] args) {
        Console c = System.console();
        System.out.println(c == null ? "no console" : "console");
    }
}
