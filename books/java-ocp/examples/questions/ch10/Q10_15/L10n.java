import java.text.*;
import java.util.*;

public class L10n {
    public static void main(String[] args) throws ParseException {
        Locale a = Locale.of("en", "US");                               // L1
        Locale b = new Locale.Builder().setLanguage("en").build();      // L2
        Locale c = Locale.US.of("fr");                                  // L3
        NumberFormat d = new NumberFormat();                            // L4
        NumberFormat e = NumberFormat.getInstance(Locale.US);           // L5
        double f = e.parse("1.5");                                      // L6
    }
}
