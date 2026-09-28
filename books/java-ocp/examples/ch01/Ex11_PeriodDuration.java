// objective: 1.4
// Period (năm/tháng/ngày) vs Duration (giây/nano) vs Instant (điểm trên trục thời gian UTC).
import java.time.*;

public class Ex11_PeriodDuration {
    public static void main(String[] args) {
        Period p = Period.of(1, 14, 40);
        System.out.println(p + " normalized=" + p.normalized());
        System.out.println(Period.ofWeeks(2) + " " + Period.ofYears(1).ofMonths(3)); // bẫy: static method!
        System.out.println(Period.between(LocalDate.of(2024, 1, 31), LocalDate.of(2024, 3, 1)));

        Duration du = Duration.ofMinutes(135);
        System.out.println(du + " " + du.toHours() + "h " + du.toMinutesPart() + "m");
        System.out.println(Duration.ofDays(1) + " " + Duration.ofSeconds(90).plusMillis(500));
        System.out.println(Duration.between(LocalTime.of(10, 0), LocalTime.of(8, 30)));

        Instant i = Instant.parse("2024-03-10T06:59:00Z");
        System.out.println(i.plus(Duration.ofMinutes(2)) + " " + i.getEpochSecond());
        try {
            LocalDate.of(2024, 1, 1).plus(Duration.ofDays(1));   // LocalDate không hỗ trợ Duration
        } catch (Exception e) {
            System.out.println(e.getClass().getSimpleName() + ": " + e.getMessage());
        }
        System.out.println(LocalDate.of(2024, 1, 1).plus(Period.ofDays(1)));
    }
}
