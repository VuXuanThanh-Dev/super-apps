// objective: 10.2
// MessageFormat: thông điệp có tham số {0}, {1}, kèm định dạng number/date; dấu ' là ký tự escape.
import java.text.MessageFormat;
import java.util.Locale;

public class Ex05_MessageFormat {
    public static void main(String[] args) {
        System.out.println(MessageFormat.format("{0} có {1} tin nhắn mới", "Nobin", 3));
        System.out.println(MessageFormat.format("{1} trước {0}, lặp lại {1}", "A", "B"));
        System.out.println(MessageFormat.format("It''s {0}; '{1}' is literal", "ok", "ignored"));
        MessageFormat mf = new MessageFormat("Total: {0,number,#,##0.00} ({1,number,percent})", Locale.US);
        System.out.println(mf.format(new Object[]{1234.5, 0.07}));
        MessageFormat de = new MessageFormat("Summe: {0,number}", Locale.GERMANY);
        System.out.println(de.format(new Object[]{1234.5}));
        System.out.println(MessageFormat.format("{0} {1} {2}", "only-one"));      // thiếu tham số → in nguyên {1}
        System.out.println(String.format(Locale.GERMANY, "%.2f", 3.14159) + " vs " + String.format(Locale.US, "%.2f", 3.14159)
                + " vs " + String.format(Locale.US, "%,d", 1234567));
    }
}
