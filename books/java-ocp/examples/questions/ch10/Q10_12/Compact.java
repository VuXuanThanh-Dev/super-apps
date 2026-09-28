import java.text.NumberFormat;
import java.util.Locale;

public class Compact {
    public static void main(String[] args) {
        NumberFormat s = NumberFormat.getCompactNumberInstance(Locale.US, NumberFormat.Style.SHORT);
        NumberFormat l = NumberFormat.getCompactNumberInstance(Locale.US, NumberFormat.Style.LONG);
        System.out.println(s.format(1_250_000) + " " + l.format(3_000));
    }
}
