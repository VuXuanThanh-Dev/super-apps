import java.util.*;

public class Main {
    public static void main(String[] args) {
        Locale.setDefault(Locale.US);
        System.out.println(ResourceBundle.getBundle("Msg", Locale.of("vi", "VN")).getString("bye"));
    }
}
