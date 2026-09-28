import java.util.*;

public class Main {
    public static void main(String[] args) {
        Locale.setDefault(Locale.US);
        ResourceBundle rb = ResourceBundle.getBundle("Prices", Locale.of("vi"));
        double vat = (Double) rb.getObject("vat");
        int[] tiers = (int[]) rb.getObject("tiers");          // kế thừa từ bundle cha Prices
        System.out.println("vat=" + vat + " currency=" + rb.getString("currency") + " tiers=" + Arrays.toString(tiers));
        try {
            rb.getString("vat");                               // giá trị không phải String
        } catch (ClassCastException e) {
            System.out.println("ClassCastException: getString trên giá trị Double");
        }
    }
}
