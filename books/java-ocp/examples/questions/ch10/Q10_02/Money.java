import java.text.NumberFormat;
import java.util.Locale;

public class Money {
    public static void main(String[] args) {
        NumberFormat c = NumberFormat.getCurrencyInstance(Locale.US);
        NumberFormat p = NumberFormat.getPercentInstance(Locale.US);
        System.out.println(c.format(1234.567) + " " + p.format(0.125) + " " + c.format(-5));
    }
}
