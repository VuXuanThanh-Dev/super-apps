// objective: 10.2
// parse số theo locale (ParseException, dừng ở ký tự lạ) và DecimalFormat với pattern.
import java.text.*;
import java.util.Locale;

public class Ex03_ParseAndPatterns {
    public static void main(String[] args) throws ParseException {
        NumberFormat us = NumberFormat.getInstance(Locale.US);
        NumberFormat de = NumberFormat.getInstance(Locale.GERMANY);
        System.out.println(us.parse("1,234.5") + " " + de.parse("1.234,5") + " " + us.parse("1.234,5"));
        System.out.println(us.parse("12abc") + " " + us.parse("42").getClass().getSimpleName()
                + " " + us.parse("4.2").getClass().getSimpleName());
        try {
            us.parse("abc");
        } catch (ParseException e) {
            System.out.println("ParseException: " + e.getMessage() + " at " + e.getErrorOffset());
        }
        NumberFormat money = NumberFormat.getCurrencyInstance(Locale.US);
        System.out.println(money.parse("$9.99") + " " + money.format(-3.456));

        DecimalFormat df1 = new DecimalFormat("#,##0.00", DecimalFormatSymbols.getInstance(Locale.US));
        DecimalFormat df2 = new DecimalFormat("000.#", DecimalFormatSymbols.getInstance(Locale.US));
        DecimalFormat df3 = new DecimalFormat("$#,###.## 'total'", DecimalFormatSymbols.getInstance(Locale.US));
        System.out.println(df1.format(1234.5) + " | " + df1.format(0.126) + " | " + df2.format(5.25) + " | "
                + df2.format(1234.56) + " | " + df3.format(98765.4321));
        System.out.println(new DecimalFormat("0.0%", DecimalFormatSymbols.getInstance(Locale.US)).format(0.4567));
    }
}
