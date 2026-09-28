// objective: 10.1
import java.util.ListResourceBundle;

// Bundle dạng lớp Java: giá trị có thể là object bất kỳ, không chỉ String.
public class Prices extends ListResourceBundle {
    @Override protected Object[][] getContents() {
        return new Object[][]{{"vat", 0.10}, {"currency", "USD"}, {"tiers", new int[]{10, 20}}};
    }
}
