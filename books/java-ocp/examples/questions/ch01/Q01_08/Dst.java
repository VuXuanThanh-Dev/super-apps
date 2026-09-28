import java.time.*;

public class Dst {
    public static void main(String[] args) {
        ZoneId z = ZoneId.of("America/New_York");
        ZonedDateTime t = ZonedDateTime.of(2024, 3, 10, 1, 45, 0, 0, z);
        ZonedDateTime a = t.plusMinutes(30);
        ZonedDateTime b = t.plusDays(1).minusHours(24);
        System.out.println(a.toLocalTime() + " " + b.toLocalTime());
    }
}
