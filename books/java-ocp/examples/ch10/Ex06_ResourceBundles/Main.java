// objective: 10.1
import java.util.*;

public class Main {
    public static void main(String[] args) {
        Locale.setDefault(Locale.US);                    // không có Messages_en_US / Messages_en
        for (Locale l : List.of(Locale.of("vi", "VN"), Locale.of("vi"), Locale.FRANCE, Locale.JAPAN)) {
            ResourceBundle rb = ResourceBundle.getBundle("Messages", l);
            System.out.printf("%-6s -> greeting=%s | farewell=%s | only.root=%s | bundle locale=[%s]%n",
                    l, rb.getString("greeting"), rb.getString("farewell"), rb.getString("only.root"), rb.getLocale());
        }
        ResourceBundle vi = ResourceBundle.getBundle("Messages", Locale.of("vi", "VN"));
        System.out.println("keys (vi_VN, gồm cả key kế thừa từ bundle cha): " + new TreeSet<>(vi.keySet()));
        try {
            vi.getString("missing.key");
        } catch (MissingResourceException e) {
            System.out.println("MissingResourceException: " + e.getMessage());
        }
        try {
            ResourceBundle.getBundle("NoSuchBundle", Locale.US);
        } catch (MissingResourceException e) {
            System.out.println("MissingResourceException khi không có bundle nào");
        }
    }
}
