import java.util.Locale;

public class Loc {
    public static void main(String[] args) {
        Locale a = Locale.of("fr", "CA");
        Locale b = Locale.forLanguageTag("vi-VN");
        Locale c = Locale.GERMAN;
        System.out.println(a + " " + b + " " + c + " [" + c.getCountry() + "]");
    }
}
