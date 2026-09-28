import java.util.Locale;

public class Display {
    public static void main(String[] args) {
        Locale vi = Locale.of("vi", "VN");
        System.out.println(vi.getDisplayLanguage(Locale.US) + " " + vi.getDisplayCountry(Locale.US) + " "
                + vi.toLanguageTag());
    }
}
