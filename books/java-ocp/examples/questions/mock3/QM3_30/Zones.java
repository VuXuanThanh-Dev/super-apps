import java.time.*;

public class Zones {
    public static void main(String[] args) {
        ZonedDateTime hcm = ZonedDateTime.of(LocalDateTime.of(2024, 6, 1, 1, 0), ZoneId.of("Asia/Ho_Chi_Minh"));
        ZonedDateTime la = hcm.withZoneSameInstant(ZoneId.of("America/Los_Angeles"));
        System.out.println(la.toLocalDateTime() + " " + la.getOffset() + " " + hcm.toInstant().equals(la.toInstant())
                + " " + hcm.isEqual(la) + " " + hcm.equals(la));
    }
}
