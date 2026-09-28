// objective: 10.2
// DateTimeFormatter: pattern (chữ hoa/thường khác nghĩa!), locale, FormatStyle, parse.
import java.time.*;
import java.time.format.*;
import java.time.temporal.UnsupportedTemporalTypeException;
import java.util.Locale;

public class Ex04_DateTimeFormatter {
    public static void main(String[] args) {
        LocalDateTime dt = LocalDateTime.of(2024, 3, 5, 14, 7, 9);
        System.out.println(dt.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss")));
        System.out.println(dt.format(DateTimeFormatter.ofPattern("d/M/yy h:mm a", Locale.US)));
        System.out.println(dt.format(DateTimeFormatter.ofPattern("EEEE, MMMM d", Locale.US)) + " | "
                + dt.format(DateTimeFormatter.ofPattern("EEEE, d MMMM", Locale.of("vi", "VN"))) + " | "
                + dt.format(DateTimeFormatter.ofPattern("EEE d MMM", Locale.FRANCE)));
        System.out.println(dt.format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm 'o''clock'")));
        System.out.println(dt.format(DateTimeFormatter.ofPattern("mm")) + " vs " + dt.format(DateTimeFormatter.ofPattern("MM"))
                + " | " + DateTimeFormatter.ISO_LOCAL_DATE.format(dt) + " | " + DateTimeFormatter.BASIC_ISO_DATE.format(dt));

        for (FormatStyle st : new FormatStyle[]{FormatStyle.SHORT, FormatStyle.MEDIUM, FormatStyle.LONG, FormatStyle.FULL}) {
            System.out.println(st + ": " + dt.toLocalDate().format(DateTimeFormatter.ofLocalizedDate(st).withLocale(Locale.US))
                    + " | " + dt.toLocalDate().format(DateTimeFormatter.ofLocalizedDate(st).withLocale(Locale.of("vi", "VN"))));
        }
        LocalDate parsed = LocalDate.parse("05.03.2024", DateTimeFormatter.ofPattern("dd.MM.yyyy"));
        System.out.println("parsed: " + parsed);
        try {
            LocalDate.parse("2024/03/05");
        } catch (DateTimeParseException e) {
            System.out.println("DateTimeParseException: " + e.getMessage());
        }
        try {
            LocalDate.of(2024, 3, 5).format(DateTimeFormatter.ofPattern("HH:mm"));
        } catch (UnsupportedTemporalTypeException e) {
            System.out.println("UnsupportedTemporalTypeException: LocalDate không có giờ");
        }
    }
}
