import java.time.LocalDate;

public class Months {
    public static void main(String[] args) {
        LocalDate d = LocalDate.of(2023, 1, 31);
        d.plusDays(1);
        LocalDate e = d.plusMonths(1);
        System.out.println(d + " " + e);
    }
}
