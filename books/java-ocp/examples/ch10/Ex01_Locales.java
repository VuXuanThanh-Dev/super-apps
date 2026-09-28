// objective: 10.1
// Locale: ngôn ngữ (language) + quốc gia (country). Tạo bằng Locale.of (Java 19+), hằng số, hoặc language tag.
import java.util.Locale;

public class Ex01_Locales {
    public static void main(String[] args) {
        Locale vi = Locale.of("vi", "VN");                 // constructor new Locale(...) đã deprecated từ Java 19
        Locale fr = Locale.FRANCE;
        Locale en = Locale.ENGLISH;                        // chỉ có ngôn ngữ, không có quốc gia
        Locale tag = Locale.forLanguageTag("ja-JP");
        Locale built = new Locale.Builder().setLanguage("de").setRegion("CH").build();
        System.out.println(vi + " " + fr + " " + en + " " + tag + " " + built);
        System.out.println(vi.getLanguage() + " " + vi.getCountry() + " [" + en.getCountry() + "] " + vi.toLanguageTag());
        System.out.println(vi.getDisplayName(Locale.US) + " | " + vi.getDisplayName(vi) + " | " + fr.getDisplayCountry(Locale.US));
        System.out.println("default = " + Locale.getDefault());
        Locale.setDefault(vi);                             // chỉ ảnh hưởng JVM này
        System.out.println("default = " + Locale.getDefault() + ", display: " + Locale.GERMANY.getDisplayName());
        System.out.println(Locale.of("VI", "vn") + " (tự chuẩn hoá chữ hoa/thường)");
    }
}
