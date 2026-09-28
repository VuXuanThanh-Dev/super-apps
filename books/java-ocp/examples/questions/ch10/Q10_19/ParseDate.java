import java.time.LocalDate;
import java.time.format.*;
import java.util.Locale;

public class ParseDate {
    public static void main(String[] args) {
        DateTimeFormatter f = DateTimeFormatter.ofPattern("dd MMM yyyy", Locale.US);
        LocalDate d = LocalDate.parse("07 Jan 2024", f);
        System.out.print(d + " " + d.format(DateTimeFormatter.ofPattern("EEE D", Locale.US)) + " ");
        try {
            LocalDate.parse("07 jan 2024", f);
            System.out.println("ok");
        } catch (DateTimeParseException e) {
            System.out.println("fail");
        }
    }
}
