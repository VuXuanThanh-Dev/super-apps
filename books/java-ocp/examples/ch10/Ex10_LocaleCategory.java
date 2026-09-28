// objective: 10.1, 10.2
// Locale.Category: FORMAT (định dạng số/ngày) và DISPLAY (tên hiển thị) có thể đặt riêng.
import java.text.NumberFormat;
import java.util.Locale;

public class Ex10_LocaleCategory {
    static String show(String s) { return s.replace(' ', '_').replace(' ', '_'); }

    public static void main(String[] args) {
        Locale.setDefault(Locale.US);
        Locale.setDefault(Locale.Category.FORMAT, Locale.GERMANY);
        Locale.setDefault(Locale.Category.DISPLAY, Locale.FRANCE);
        System.out.println("default=" + Locale.getDefault() + " FORMAT=" + Locale.getDefault(Locale.Category.FORMAT)
                + " DISPLAY=" + Locale.getDefault(Locale.Category.DISPLAY));
        System.out.println("NumberFormat.getInstance() dùng FORMAT: " + show(NumberFormat.getInstance().format(1234.5)));
        System.out.println("getDisplayCountry() dùng DISPLAY: " + Locale.JAPAN.getDisplayCountry());
        System.out.println("String.format dùng FORMAT: " + String.format("%.1f", 2.5));
        Locale.setDefault(Locale.US);                                   // đặt lại cả hai category
        System.out.println("sau setDefault(US): " + NumberFormat.getInstance().format(1234.5) + " " + Locale.JAPAN.getDisplayCountry());
    }
}
