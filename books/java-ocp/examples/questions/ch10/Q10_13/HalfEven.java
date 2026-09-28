import java.text.NumberFormat;
import java.util.Locale;

public class HalfEven {
    public static void main(String[] args) {
        NumberFormat nf = NumberFormat.getIntegerInstance(Locale.US);
        System.out.println(nf.format(12.5) + " " + nf.format(13.5));
    }
}
