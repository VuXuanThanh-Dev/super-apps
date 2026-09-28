import java.time.*;
import java.time.format.*;
import java.util.Locale;

public class Pattern {
    public static void main(String[] args) {
        LocalDateTime dt = LocalDateTime.of(2024, 3, 5, 14, 7);
        System.out.println(DateTimeFormatter.ofPattern("dd/MM/yyyy hh:mm a", Locale.US).format(dt));
    }
}
