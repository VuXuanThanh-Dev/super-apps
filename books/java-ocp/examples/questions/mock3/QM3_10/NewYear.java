import java.time.*;
import java.time.temporal.ChronoUnit;

public class NewYear {
    public static void main(String[] args) {
        LocalDateTime t = LocalDateTime.of(2024, 12, 31, 23, 59, 45);
        LocalDateTime u = t.plusSeconds(20).truncatedTo(ChronoUnit.MINUTES);
        System.out.println(u + " " + u.getDayOfWeek() + " " + u.getDayOfYear() + " " + t.toLocalDate().isLeapYear());
    }
}
