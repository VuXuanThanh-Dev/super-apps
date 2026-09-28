import java.time.*;

public class Amounts {
    public static void main(String[] args) {
        Period p = Period.ofMonths(1).ofDays(10);
        Duration d = Duration.ofHours(25);
        System.out.println(p + " " + d);
    }
}
