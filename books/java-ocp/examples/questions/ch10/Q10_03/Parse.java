import java.text.*;
import java.util.Locale;

public class Parse {
    public static void main(String[] args) throws ParseException {
        NumberFormat nf = NumberFormat.getInstance(Locale.GERMANY);
        Number n1 = nf.parse("1.500,75");
        Number n2 = nf.parse("3,5kg");
        System.out.println(n1 + " " + n2 + " " + n2.getClass().getSimpleName());
    }
}
