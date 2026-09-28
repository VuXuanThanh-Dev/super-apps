import java.util.*;
public class Main {
    public static void main(String[] args) {
        Locale.setDefault(Locale.JAPAN);
        System.out.println(ResourceBundle.getBundle("Labels", Locale.FRANCE).getString("title"));
    }
}
