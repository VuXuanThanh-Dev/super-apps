import java.time.LocalDate;
import java.time.format.*;
import java.util.Locale;

public class Styles {
    public static void main(String[] args) {
        LocalDate d = LocalDate.of(2024, 12, 25);
        System.out.println(d.format(DateTimeFormatter.ofLocalizedDate(FormatStyle.SHORT).withLocale(Locale.US))
                + " | " + d.format(DateTimeFormatter.ofLocalizedDate(FormatStyle.MEDIUM).withLocale(Locale.US)));
    }
}
