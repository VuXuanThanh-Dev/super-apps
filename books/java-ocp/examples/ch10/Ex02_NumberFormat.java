// objective: 10.2
// Định dạng số, tiền tệ, phần trăm theo locale. Lưu ý: nhiều locale dùng khoảng trắng KHÔNG NGẮT (U+00A0 / U+202F);
// ở đây in chúng thành '_' để dễ nhìn.
import java.text.NumberFormat;
import java.util.Locale;

public class Ex02_NumberFormat {
    static String show(String s) { return s.replace(' ', '_').replace(' ', '_'); }

    public static void main(String[] args) {
        double value = 1234567.891;
        Locale[] locales = {Locale.US, Locale.of("vi", "VN"), Locale.GERMANY, Locale.FRANCE, Locale.JAPAN};
        for (Locale l : locales) {
            System.out.printf("%-6s number=%-14s currency=%-18s percent=%s%n", l,
                    show(NumberFormat.getInstance(l).format(value)),
                    show(NumberFormat.getCurrencyInstance(l).format(value)),
                    show(NumberFormat.getPercentInstance(l).format(0.256)));
        }
        NumberFormat integer = NumberFormat.getIntegerInstance(Locale.US);
        System.out.println(integer.format(2.5) + " " + integer.format(3.5) + " " + integer.format(-2.5));   // HALF_EVEN
        NumberFormat nf = NumberFormat.getInstance(Locale.US);
        nf.setMaximumFractionDigits(1);
        nf.setMinimumFractionDigits(1);
        System.out.println(nf.format(0.25) + " " + nf.format(0.35) + " " + nf.format(7));
        NumberFormat compact = NumberFormat.getCompactNumberInstance(Locale.US, NumberFormat.Style.SHORT);
        NumberFormat compactLong = NumberFormat.getCompactNumberInstance(Locale.US, NumberFormat.Style.LONG);
        System.out.println(compact.format(1_500) + " " + compact.format(2_345_678) + " " + compactLong.format(2_345_678));
    }
}
