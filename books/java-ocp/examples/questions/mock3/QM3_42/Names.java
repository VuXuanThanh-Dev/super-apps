import java.util.Locale;

public class Names {
    public static void main(String[] args) {
        Locale vi = Locale.of("vi", "VN");
        System.out.println(Locale.FRANCE.getDisplayCountry(vi) + " | " + vi.getDisplayLanguage(Locale.FRANCE)
                + " | " + Locale.of("vi").getDisplayName(Locale.US));
    }
}
