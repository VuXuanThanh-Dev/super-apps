import java.time.*;
import java.time.temporal.ChronoUnit;

public class Dates {
    public static void main(String[] args) {
        LocalDate d = LocalDate.of(2024, 1, 31);
        Period p = Period.ofMonths(1).plusDays(1);
        System.out.println(d.plus(p) + " " + d.plusDays(1).plusMonths(1) + " "
                + ChronoUnit.MONTHS.between(d, d.plus(p)));
    }
}
