import java.text.MessageFormat;
import java.util.Locale;

public class Msg {
    public static void main(String[] args) {
        String a = MessageFormat.format("{0} of {1} ({2,number,percent})", 3, 4, 0.75);
        String b = new MessageFormat("{0,number,#.#}|{0,number,integer}", Locale.US).format(new Object[]{2.55});
        System.out.println(a + " " + b);
    }
}
