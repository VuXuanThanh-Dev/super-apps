import java.text.*;
import java.util.Locale;

public class Patterns {
    public static void main(String[] args) {
        var sym = DecimalFormatSymbols.getInstance(Locale.US);
        System.out.println(new DecimalFormat("#,##0.0#", sym).format(1234.5) + " "
                + new DecimalFormat("00.00", sym).format(3.14159) + " "
                + new DecimalFormat("#.#", sym).format(0.05));
    }
}
