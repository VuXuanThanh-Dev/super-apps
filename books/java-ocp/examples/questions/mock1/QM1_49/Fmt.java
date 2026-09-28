import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

public class Fmt {
    public static void main(String[] args) {
        LocalDateTime t = LocalDateTime.of(2024, 7, 4, 9, 5);
        System.out.println(t.format(DateTimeFormatter.ofPattern("EEE, MMM d yyyy 'at' h:mm a", Locale.US)));
    }
}
