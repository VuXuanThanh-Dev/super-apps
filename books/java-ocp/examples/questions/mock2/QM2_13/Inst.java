import java.time.*;

public class Inst {
    public static void main(String[] args) {
        Instant start = Instant.parse("2024-02-28T22:00:00Z");
        Instant end = start.plus(Duration.ofHours(30));
        Duration d = Duration.between(start, end);
        System.out.println(end + " " + d + " " + d.toDaysPart() + " " + d.toHoursPart());
    }
}
