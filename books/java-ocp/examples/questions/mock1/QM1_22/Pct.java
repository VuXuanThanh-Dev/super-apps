import java.text.NumberFormat;
import java.util.Locale;

public class Pct {
    public static void main(String[] args) {
        NumberFormat f = NumberFormat.getPercentInstance(Locale.US);
        f.setMinimumFractionDigits(1);
        NumberFormat c = NumberFormat.getCurrencyInstance(Locale.US);
        System.out.println(f.format(0.4567) + " " + c.format(0.125) + " " + c.format(0.135));
    }
}
