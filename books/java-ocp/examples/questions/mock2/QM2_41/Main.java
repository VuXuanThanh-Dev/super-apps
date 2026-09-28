import java.util.*;
public class Main {
    public static void main(String[] args) {
        Locale.setDefault(Locale.FRANCE);
        ResourceBundle rb = ResourceBundle.getBundle("Msg", Locale.UK);
        System.out.println(rb.getString("t") + " " + rb.getLocale());
    }
}
