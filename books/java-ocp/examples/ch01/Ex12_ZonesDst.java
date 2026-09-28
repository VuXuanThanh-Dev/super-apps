// objective: 1.4
// ZonedDateTime và giờ mùa hè (daylight saving time, DST) ở America/New_York.
import java.time.*;

public class Ex12_ZonesDst {
    public static void main(String[] args) {
        ZoneId ny = ZoneId.of("America/New_York");
        // 2024-03-10: đồng hồ nhảy từ 02:00 lên 03:00 (gap) → 02:30 không tồn tại
        ZonedDateTime gap = ZonedDateTime.of(LocalDateTime.of(2024, 3, 10, 2, 30), ny);
        System.out.println("gap     : " + gap);
        ZonedDateTime before = ZonedDateTime.of(LocalDateTime.of(2024, 3, 10, 1, 30), ny);
        System.out.println("+1h     : " + before.plusHours(1));
        System.out.println("+1 day  : " + before.plusDays(1));          // giữ giờ địa phương
        System.out.println("+24h    : " + before.plusHours(24));        // cộng đúng 24 giờ thật

        // 2024-11-03: đồng hồ lùi từ 02:00 về 01:00 (overlap) → 01:30 xảy ra 2 lần
        ZonedDateTime overlap = ZonedDateTime.of(LocalDateTime.of(2024, 11, 3, 1, 30), ny);
        System.out.println("overlap : " + overlap + " / later: " + overlap.withLaterOffsetAtOverlap());
        System.out.println("hours in 2024-11-03: " + Duration.between(
                ZonedDateTime.of(LocalDate.of(2024, 11, 3), LocalTime.MIDNIGHT, ny),
                ZonedDateTime.of(LocalDate.of(2024, 11, 4), LocalTime.MIDNIGHT, ny)).toHours());

        ZonedDateTime hanoi = before.withZoneSameInstant(ZoneId.of("Asia/Ho_Chi_Minh"));
        System.out.println("same instant in VN: " + hanoi);
        System.out.println("same local in VN  : " + before.withZoneSameLocal(ZoneId.of("Asia/Ho_Chi_Minh")));
        System.out.println(OffsetDateTime.of(2024, 1, 1, 12, 0, 0, 0, ZoneOffset.ofHours(7)).toInstant());
    }
}
