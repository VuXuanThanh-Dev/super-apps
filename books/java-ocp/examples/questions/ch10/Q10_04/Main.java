import java.util.*;

public class Main {
    public static void main(String[] args) {
        Locale.setDefault(Locale.of("en", "US"));
        String a = ResourceBundle.getBundle("Menu", Locale.of("vi")).getString("title");
        String b = ResourceBundle.getBundle("Menu", Locale.of("vi", "VN")).getString("title");
        System.out.println(a + " " + b);
    }
}
