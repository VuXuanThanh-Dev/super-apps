import java.util.Locale;

public class Fmt {
    public static void main(String[] args) {
        System.out.println(String.format(Locale.GERMANY, "%,.2f", 1234.5) + " "
                + String.format(Locale.US, "%,.2f", 1234.5));
    }
}
