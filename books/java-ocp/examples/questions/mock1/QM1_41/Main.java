import java.util.*;
public class Main {
    public static void main(String[] args) {
        Locale.setDefault(Locale.FRANCE);
        ResourceBundle rb = ResourceBundle.getBundle("App", Locale.of("de", "CH"));
        System.out.println(rb.getString("hi") + " " + rb.getString("bye"));
    }
}
