import java.util.*;
public class Main {
    public static void main(String[] args) {
        System.out.println(ResourceBundle.getBundle("Prices", Locale.of("vi")).getString("currency"));
    }
}
