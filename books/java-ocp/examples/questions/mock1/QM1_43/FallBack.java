import java.time.*;
import java.time.temporal.ChronoUnit;

public class FallBack {
    public static void main(String[] args) {
        ZoneId z = ZoneId.of("Europe/Paris");
        ZonedDateTime a = ZonedDateTime.of(2024, 10, 27, 1, 30, 0, 0, z);
        ZonedDateTime b = a.plusHours(2);
        System.out.println(b.toLocalTime() + " " + Duration.between(a, b).toMinutes() + " "
                + ChronoUnit.HOURS.between(a.toLocalDateTime(), b.toLocalDateTime()));
    }
}
