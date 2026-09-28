import java.time.*;
import java.time.format.*;
import java.util.Locale;

public class Pattern {
    public static void main(String[] args) {
        LocalDateTime dt = LocalDateTime.of(2024, 3, 5, 14, 7);
        System.out.println(dt.format(DateTimeFormatter.ofPattern("d/M/yyyy h:mm a", Locale.US)));
    }
}
