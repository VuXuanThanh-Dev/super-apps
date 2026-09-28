// objective: 1.4
// LocalDate/LocalTime/LocalDateTime là bất biến; phép cộng trả về object mới.
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

public class Ex10_LocalDate {
    public static void main(String[] args) {
        LocalDate d = LocalDate.of(2024, Month.JANUARY, 31);
        d.plusDays(1);                              // kết quả bị bỏ → d không đổi
        System.out.println(d + " " + d.plusMonths(1) + " " + d.plusMonths(1).plusMonths(1));
        System.out.println(d.getDayOfWeek() + " " + d.isLeapYear() + " " + d.lengthOfMonth());

        LocalTime t = LocalTime.of(23, 30);
        System.out.println(t.plusHours(2) + " " + t.minusMinutes(90) + " " + LocalTime.MIDNIGHT);

        LocalDateTime dt = LocalDateTime.of(d, t);
        System.out.println(dt + " " + dt.plusMinutes(45));
        System.out.println(ChronoUnit.DAYS.between(LocalDate.of(2024, 1, 1), d));
        System.out.println(d.withDayOfMonth(1) + " " + d.with(DayOfWeek.MONDAY));

        LocalDate parsed = LocalDate.parse("2024-02-29");
        System.out.println(parsed.plusYears(1) + " " + parsed.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
        try {
            LocalDate.of(2023, 2, 29);
        } catch (DateTimeException e) {
            System.out.println("DateTimeException: " + e.getMessage());
        }
    }
}
