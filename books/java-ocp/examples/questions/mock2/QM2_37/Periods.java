import java.time.*;
import java.time.temporal.TemporalAdjusters;

public class Periods {
    public static void main(String[] args) {
        LocalDate a = LocalDate.of(2023, 11, 30), b = LocalDate.of(2025, 2, 28);
        Period p = Period.between(a, b);
        System.out.println(p + " " + p.toTotalMonths() + " " + a.with(TemporalAdjusters.lastDayOfMonth()) + " "
                + a.withMonth(2));
    }
}
