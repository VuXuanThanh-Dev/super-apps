import java.text.*;
import java.util.Locale;

public class Neg {
    public static void main(String[] args) throws ParseException {
        DecimalFormat df = new DecimalFormat("#,##0.00;(#,##0.00)", DecimalFormatSymbols.getInstance(Locale.US));
        System.out.println(df.format(-1234.567) + " " + df.format(0.5) + " " + df.parse("(12.50)"));
    }
}
