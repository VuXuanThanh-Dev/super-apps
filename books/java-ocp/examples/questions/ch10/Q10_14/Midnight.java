import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

public class Midnight {
    public static void main(String[] args) {
        LocalTime t = LocalTime.of(0, 5);
        System.out.println(t.format(DateTimeFormatter.ofPattern("hh:mm a", Locale.US)) + " "
                + t.format(DateTimeFormatter.ofPattern("HH:mm")));
    }
}
