// objective: 10.2
// Currency và định dạng tiền tệ: mã ISO 4217, ký hiệu theo locale, số chữ số thập phân.
import java.text.NumberFormat;
import java.util.Currency;
import java.util.Locale;

public class Ex09_Currency {
    static String show(String s) { return s.replace(' ', '_').replace(' ', '_'); }

    public static void main(String[] args) {
        Currency vnd = Currency.getInstance(Locale.of("vi", "VN"));
        Currency usd = Currency.getInstance("USD");
        System.out.println(vnd.getCurrencyCode() + " " + vnd.getDefaultFractionDigits() + " " + usd.getDefaultFractionDigits()
                + " " + show(vnd.getSymbol(Locale.of("vi", "VN"))) + " " + usd.getSymbol(Locale.US) + " " + usd.getSymbol(Locale.CANADA));
        NumberFormat f = NumberFormat.getCurrencyInstance(Locale.US);
        f.setCurrency(Currency.getInstance("EUR"));
        System.out.println(f.format(12.5) + " | " + show(NumberFormat.getCurrencyInstance(Locale.of("vi", "VN")).format(12345.678)));
        System.out.println(show(NumberFormat.getCurrencyInstance(Locale.JAPAN).format(1234.5)) + " | "
                + show(NumberFormat.getCurrencyInstance(Locale.of("en", "IN")).format(1234567.8)));
    }
}
