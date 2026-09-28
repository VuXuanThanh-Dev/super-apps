import java.util.*;

public class Main {
    public static void main(String[] args) {
        ResourceBundle rb = ResourceBundle.getBundle("Messages", Locale.CANADA_FRENCH);
        System.out.print(rb.getString("a") + " " + rb.getString("b") + " ");
        try {
            System.out.println(rb.getString("c"));
        } catch (MissingResourceException e) {
            System.out.println("missing");
        }
    }
}
