import java.time.*;

public class AddDuration {
    public static void main(String[] args) {
        LocalDate d = LocalDate.of(2024, 5, 20);
        LocalDate e = d.plus(Duration.ofDays(2));
        System.out.println(e);
    }
}
