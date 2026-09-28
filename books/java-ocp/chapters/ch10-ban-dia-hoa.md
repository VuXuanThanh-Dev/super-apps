# Chương 10 — Bản địa hoá (Implementing Localization)

## Mục tiêu

- 10.1 Bản địa hoá (localization) bằng `Locale` và `ResourceBundle`.
- 10.2 Parse (đọc) và format (định dạng) thông điệp, ngày, giờ, số — kể cả tiền tệ và phần trăm.

## Giải thích đơn giản

**Internationalization (i18n)** là thiết kế chương trình để hỗ trợ nhiều ngôn ngữ/vùng. **Localization (l10n)** là
việc làm cho chương trình hiển thị đúng với một vùng cụ thể: ngôn ngữ, cách viết số (`1,234.5` hay `1.234,5`),
tiền tệ (`$` hay `₫`), ngày tháng (`12/25/24` hay `25/12/24`).

- **`Locale`** mô tả "vùng": ngôn ngữ (`vi`) + quốc gia (`VN`) → `vi_VN`.
- **`ResourceBundle`** chứa các chuỗi dịch theo từng locale (`Messages_vi.properties`…). Code chỉ gọi
  `bundle.getString("greeting")`.
- **`NumberFormat`**, **`DateTimeFormatter`**, **`MessageFormat`** định dạng số, ngày giờ, thông điệp theo locale.

## Ví dụ

Code trong `examples/ch10/`. Chạy lại: `python3 tools/book.py examples ch10`. Output thật, JDK 21.0.10 (dữ liệu
locale CLDR đi kèm JDK). Nhiều locale dùng **khoảng trắng không ngắt** (U+00A0, U+202F); trong ví dụ, chúng được in
thành `_` cho dễ nhìn.

### 1. Locale

<!-- EX:Ex01_Locales -->
`examples/ch10/Ex01_Locales.java`

```java
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
```

Output thật (JDK 21.0.10):

```text
vi_VN fr_FR en ja_JP de_CH
vi VN [] vi-VN
Vietnamese (Vietnam) | Tiếng Việt (Việt Nam) | France
default = en_US
default = vi_VN, display: Tiếng Đức (Đức)
vi_VN (tự chuẩn hoá chữ hoa/thường)
```
<!-- /EX -->

### 2. NumberFormat: số, tiền tệ, phần trăm, compact

Để ý dòng `2 4 -2` và `0.2 0.3 7.0`: `NumberFormat` làm tròn kiểu **HALF_EVEN** (nửa về số chẵn), và `0.35` thật ra
là `0.34999…` trong hệ nhị phân nên thành `0.3`.

<!-- EX:Ex02_NumberFormat -->
`examples/ch10/Ex02_NumberFormat.java`

```java
// objective: 10.2
// Định dạng số, tiền tệ, phần trăm theo locale. Lưu ý: nhiều locale dùng khoảng trắng KHÔNG NGẮT (U+00A0 / U+202F);
// ở đây in chúng thành '_' để dễ nhìn.
import java.text.NumberFormat;
import java.util.Locale;

public class Ex02_NumberFormat {
    static String show(String s) { return s.replace(' ', '_').replace(' ', '_'); }

    public static void main(String[] args) {
        double value = 1234567.891;
        Locale[] locales = {Locale.US, Locale.of("vi", "VN"), Locale.GERMANY, Locale.FRANCE, Locale.JAPAN};
        for (Locale l : locales) {
            System.out.printf("%-6s number=%-14s currency=%-18s percent=%s%n", l,
                    show(NumberFormat.getInstance(l).format(value)),
                    show(NumberFormat.getCurrencyInstance(l).format(value)),
                    show(NumberFormat.getPercentInstance(l).format(0.256)));
        }
        NumberFormat integer = NumberFormat.getIntegerInstance(Locale.US);
        System.out.println(integer.format(2.5) + " " + integer.format(3.5) + " " + integer.format(-2.5));   // HALF_EVEN
        NumberFormat nf = NumberFormat.getInstance(Locale.US);
        nf.setMaximumFractionDigits(1);
        nf.setMinimumFractionDigits(1);
        System.out.println(nf.format(0.25) + " " + nf.format(0.35) + " " + nf.format(7));
        NumberFormat compact = NumberFormat.getCompactNumberInstance(Locale.US, NumberFormat.Style.SHORT);
        NumberFormat compactLong = NumberFormat.getCompactNumberInstance(Locale.US, NumberFormat.Style.LONG);
        System.out.println(compact.format(1_500) + " " + compact.format(2_345_678) + " " + compactLong.format(2_345_678));
    }
}
```

Output thật (JDK 21.0.10):

```text
en_US  number=1,234,567.891  currency=$1,234,567.89      percent=26%
vi_VN  number=1.234.567,891  currency=1.234.568_₫        percent=26%
de_DE  number=1.234.567,891  currency=1.234.567,89_€     percent=26_%
fr_FR  number=1_234_567,891  currency=1_234_567,89_€     percent=26_%
ja_JP  number=1,234,567.891  currency=￥1,234,568         percent=26%
2 4 -2
0.2 0.3 7.0
2K 2M 2 million
```
<!-- /EX -->

### 3. Parse số và DecimalFormat

<!-- EX:Ex03_ParseAndPatterns -->
`examples/ch10/Ex03_ParseAndPatterns.java`

```java
// objective: 10.2
// parse số theo locale (ParseException, dừng ở ký tự lạ) và DecimalFormat với pattern.
import java.text.*;
import java.util.Locale;

public class Ex03_ParseAndPatterns {
    public static void main(String[] args) throws ParseException {
        NumberFormat us = NumberFormat.getInstance(Locale.US);
        NumberFormat de = NumberFormat.getInstance(Locale.GERMANY);
        System.out.println(us.parse("1,234.5") + " " + de.parse("1.234,5") + " " + us.parse("1.234,5"));
        System.out.println(us.parse("12abc") + " " + us.parse("42").getClass().getSimpleName()
                + " " + us.parse("4.2").getClass().getSimpleName());
        try {
            us.parse("abc");
        } catch (ParseException e) {
            System.out.println("ParseException: " + e.getMessage() + " at " + e.getErrorOffset());
        }
        NumberFormat money = NumberFormat.getCurrencyInstance(Locale.US);
        System.out.println(money.parse("$9.99") + " " + money.format(-3.456));

        DecimalFormat df1 = new DecimalFormat("#,##0.00", DecimalFormatSymbols.getInstance(Locale.US));
        DecimalFormat df2 = new DecimalFormat("000.#", DecimalFormatSymbols.getInstance(Locale.US));
        DecimalFormat df3 = new DecimalFormat("$#,###.## 'total'", DecimalFormatSymbols.getInstance(Locale.US));
        System.out.println(df1.format(1234.5) + " | " + df1.format(0.126) + " | " + df2.format(5.25) + " | "
                + df2.format(1234.56) + " | " + df3.format(98765.4321));
        System.out.println(new DecimalFormat("0.0%", DecimalFormatSymbols.getInstance(Locale.US)).format(0.4567));
    }
}
```

Output thật (JDK 21.0.10):

```text
1234.5 1234.5 1.234
12 Long Double
ParseException: Unparseable number: "abc" at 0
9.99 -$3.46
1,234.50 | 0.13 | 005.2 | 1234.6 | $98,765.43 total
45.7%
```
<!-- /EX -->

### 4. DateTimeFormatter

<!-- EX:Ex04_DateTimeFormatter -->
`examples/ch10/Ex04_DateTimeFormatter.java`

```java
// objective: 10.2
// DateTimeFormatter: pattern (chữ hoa/thường khác nghĩa!), locale, FormatStyle, parse.
import java.time.*;
import java.time.format.*;
import java.time.temporal.UnsupportedTemporalTypeException;
import java.util.Locale;

public class Ex04_DateTimeFormatter {
    public static void main(String[] args) {
        LocalDateTime dt = LocalDateTime.of(2024, 3, 5, 14, 7, 9);
        System.out.println(dt.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss")));
        System.out.println(dt.format(DateTimeFormatter.ofPattern("d/M/yy h:mm a", Locale.US)));
        System.out.println(dt.format(DateTimeFormatter.ofPattern("EEEE, MMMM d", Locale.US)) + " | "
                + dt.format(DateTimeFormatter.ofPattern("EEEE, d MMMM", Locale.of("vi", "VN"))) + " | "
                + dt.format(DateTimeFormatter.ofPattern("EEE d MMM", Locale.FRANCE)));
        System.out.println(dt.format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm 'o''clock'")));
        System.out.println(dt.format(DateTimeFormatter.ofPattern("mm")) + " vs " + dt.format(DateTimeFormatter.ofPattern("MM"))
                + " | " + DateTimeFormatter.ISO_LOCAL_DATE.format(dt) + " | " + DateTimeFormatter.BASIC_ISO_DATE.format(dt));

        for (FormatStyle st : new FormatStyle[]{FormatStyle.SHORT, FormatStyle.MEDIUM, FormatStyle.LONG, FormatStyle.FULL}) {
            System.out.println(st + ": " + dt.toLocalDate().format(DateTimeFormatter.ofLocalizedDate(st).withLocale(Locale.US))
                    + " | " + dt.toLocalDate().format(DateTimeFormatter.ofLocalizedDate(st).withLocale(Locale.of("vi", "VN"))));
        }
        LocalDate parsed = LocalDate.parse("05.03.2024", DateTimeFormatter.ofPattern("dd.MM.yyyy"));
        System.out.println("parsed: " + parsed);
        try {
            LocalDate.parse("2024/03/05");
        } catch (DateTimeParseException e) {
            System.out.println("DateTimeParseException: " + e.getMessage());
        }
        try {
            LocalDate.of(2024, 3, 5).format(DateTimeFormatter.ofPattern("HH:mm"));
        } catch (UnsupportedTemporalTypeException e) {
            System.out.println("UnsupportedTemporalTypeException: LocalDate không có giờ");
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
05/03/2024 14:07:09
5/3/24 2:07 PM
Tuesday, March 5 | Thứ Ba, 5 tháng 3 | mar. 5 mars
2024-03-05T14:07 o'clock
07 vs 03 | 2024-03-05 | 20240305
SHORT: 3/5/24 | 05/03/2024
MEDIUM: Mar 5, 2024 | 5 thg 3, 2024
LONG: March 5, 2024 | 5 tháng 3, 2024
FULL: Tuesday, March 5, 2024 | Thứ Ba, 5 tháng 3, 2024
parsed: 2024-03-05
DateTimeParseException: Text '2024/03/05' could not be parsed at index 4
UnsupportedTemporalTypeException: LocalDate không có giờ
```
<!-- /EX -->

### 5. MessageFormat và String.format

<!-- EX:Ex05_MessageFormat -->
`examples/ch10/Ex05_MessageFormat.java`

```java
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
```

Output thật (JDK 21.0.10):

```text
Nobin có 3 tin nhắn mới
B trước A, lặp lại B
It's ok; {1} is literal
Total: 1,234.50 (7%)
Summe: 1.234,5
only-one {1} {2}
3,14 vs 3.14 vs 1,234,567
```
<!-- /EX -->

### 6. ResourceBundle (.properties)

<!-- EX:Ex06_ResourceBundles -->
`Ex06_ResourceBundles/Main.java`

```java
// objective: 10.1
import java.util.*;

public class Main {
    public static void main(String[] args) {
        Locale.setDefault(Locale.US);                    // không có Messages_en_US / Messages_en
        for (Locale l : List.of(Locale.of("vi", "VN"), Locale.of("vi"), Locale.FRANCE, Locale.JAPAN)) {
            ResourceBundle rb = ResourceBundle.getBundle("Messages", l);
            System.out.printf("%-6s -> greeting=%s | farewell=%s | only.root=%s | bundle locale=[%s]%n",
                    l, rb.getString("greeting"), rb.getString("farewell"), rb.getString("only.root"), rb.getLocale());
        }
        ResourceBundle vi = ResourceBundle.getBundle("Messages", Locale.of("vi", "VN"));
        System.out.println("keys (vi_VN, gồm cả key kế thừa từ bundle cha): " + new TreeSet<>(vi.keySet()));
        try {
            vi.getString("missing.key");
        } catch (MissingResourceException e) {
            System.out.println("MissingResourceException: " + e.getMessage());
        }
        try {
            ResourceBundle.getBundle("NoSuchBundle", Locale.US);
        } catch (MissingResourceException e) {
            System.out.println("MissingResourceException khi không có bundle nào");
        }
    }
}
```

`Ex06_ResourceBundles/Messages.properties`

```properties
# bundle gốc (default / root)
greeting=Hello
farewell=Goodbye
only.root=from root
```

`Ex06_ResourceBundles/Messages_fr.properties`

```properties
greeting=Bonjour
```

`Ex06_ResourceBundles/Messages_vi.properties`

```properties
greeting=Xin chào
farewell=Tạm biệt
```

`Ex06_ResourceBundles/Messages_vi_VN.properties`

```properties
greeting=Chào bạn (vi_VN)
```

`Ex06_ResourceBundles/common.sh`

```bash
# Helper sourced by every run.sh in ch07: prints each command, then its output with the temp path hidden.
unset JAVA_TOOL_OPTIONS
run() {
  echo "\$ $*"
  "$@" 2>&1 | sed "s|$PWD|.|g"
  return 0
}
```

`Ex06_ResourceBundles/run.sh`

```bash
#!/usr/bin/env bash
# objective: 10.1
# ResourceBundle dạng .properties: tìm theo thứ tự vi_VN → vi → (locale mặc định) → gốc.
source ./common.sh
run javac -d out Main.java
cp *.properties out/
run java -cp out Main
```

Output thật (chạy `bash run.sh`, JDK 21.0.10):

```text
$ javac -d out Main.java
$ java -cp out Main
vi_VN  -> greeting=Chào bạn (vi_VN) | farewell=Tạm biệt | only.root=from root | bundle locale=[vi_VN]
vi     -> greeting=Xin chào | farewell=Tạm biệt | only.root=from root | bundle locale=[vi]
fr_FR  -> greeting=Bonjour | farewell=Goodbye | only.root=from root | bundle locale=[fr]
ja_JP  -> greeting=Hello | farewell=Goodbye | only.root=from root | bundle locale=[]
keys (vi_VN, gồm cả key kế thừa từ bundle cha): [farewell, greeting, only.root]
MissingResourceException: Can't find resource for bundle java.util.PropertyResourceBundle, key missing.key
MissingResourceException khi không có bundle nào
```
<!-- /EX -->

### 7. Locale mặc định trong việc tìm bundle

<!-- EX:Ex07_DefaultLocaleFallback -->
`Ex07_DefaultLocaleFallback/Labels.properties`

```properties
title=Root title
```

`Ex07_DefaultLocaleFallback/Labels_de.properties`

```properties
title=Deutscher Titel
```

`Ex07_DefaultLocaleFallback/Labels_en.properties`

```properties
title=English title
```

`Ex07_DefaultLocaleFallback/Main.java`

```java
// objective: 10.1
import java.util.*;

public class Main {
    public static void main(String[] args) {
        Locale.setDefault(Locale.GERMANY);
        // Tìm cho ja_JP: Labels_ja_JP → Labels_ja → (mặc định) Labels_de_DE → Labels_de → Labels (gốc)
        System.out.println("ja_JP, default de_DE -> " + ResourceBundle.getBundle("Labels", Locale.JAPAN).getString("title"));
        System.out.println("en_US, default de_DE -> " + ResourceBundle.getBundle("Labels", Locale.US).getString("title"));
        Locale.setDefault(Locale.JAPAN);
        System.out.println("fr_FR, default ja_JP -> " + ResourceBundle.getBundle("Labels", Locale.FRANCE).getString("title"));
        ResourceBundle.Control noFallback = ResourceBundle.Control.getNoFallbackControl(ResourceBundle.Control.FORMAT_DEFAULT);
        Locale.setDefault(Locale.GERMANY);
        System.out.println("ja_JP, no fallback -> " + ResourceBundle.getBundle("Labels", Locale.JAPAN, noFallback).getString("title"));
    }
}
```

`Ex07_DefaultLocaleFallback/common.sh`

```bash
# Helper sourced by every run.sh in ch07: prints each command, then its output with the temp path hidden.
unset JAVA_TOOL_OPTIONS
run() {
  echo "\$ $*"
  "$@" 2>&1 | sed "s|$PWD|.|g"
  return 0
}
```

`Ex07_DefaultLocaleFallback/run.sh`

```bash
#!/usr/bin/env bash
# objective: 10.1
# Vai trò của locale mặc định khi không tìm thấy bundle cho locale được yêu cầu.
source ./common.sh
run javac -d out Main.java
cp *.properties out/
run java -cp out Main
```

Output thật (chạy `bash run.sh`, JDK 21.0.10):

```text
$ javac -d out Main.java
$ java -cp out Main
ja_JP, default de_DE -> Deutscher Titel
en_US, default de_DE -> English title
fr_FR, default ja_JP -> Root title
ja_JP, no fallback -> Root title
```
<!-- /EX -->

### 8. ListResourceBundle (bundle là lớp Java)

<!-- EX:Ex08_ListResourceBundle -->
`Ex08_ListResourceBundle/Main.java`

```java
import java.util.*;

public class Main {
    public static void main(String[] args) {
        Locale.setDefault(Locale.US);
        ResourceBundle rb = ResourceBundle.getBundle("Prices", Locale.of("vi"));
        double vat = (Double) rb.getObject("vat");
        int[] tiers = (int[]) rb.getObject("tiers");          // kế thừa từ bundle cha Prices
        System.out.println("vat=" + vat + " currency=" + rb.getString("currency") + " tiers=" + Arrays.toString(tiers));
        try {
            rb.getString("vat");                               // giá trị không phải String
        } catch (ClassCastException e) {
            System.out.println("ClassCastException: getString trên giá trị Double");
        }
    }
}
```

`Ex08_ListResourceBundle/Prices.java`

```java
// objective: 10.1
import java.util.ListResourceBundle;

// Bundle dạng lớp Java: giá trị có thể là object bất kỳ, không chỉ String.
public class Prices extends ListResourceBundle {
    @Override protected Object[][] getContents() {
        return new Object[][]{{"vat", 0.10}, {"currency", "USD"}, {"tiers", new int[]{10, 20}}};
    }
}
```

`Ex08_ListResourceBundle/Prices_vi.java`

```java
import java.util.ListResourceBundle;

public class Prices_vi extends ListResourceBundle {
    @Override protected Object[][] getContents() {
        return new Object[][]{{"vat", 0.08}, {"currency", "VND"}};
    }
}
```

`Ex08_ListResourceBundle/Prices_vi.properties`

```properties
# Cùng tên với lớp Prices_vi: lớp Java được ưu tiên, file này bị bỏ qua
currency=FROM PROPERTIES
```

`Ex08_ListResourceBundle/common.sh`

```bash
# Helper sourced by every run.sh in ch07: prints each command, then its output with the temp path hidden.
unset JAVA_TOOL_OPTIONS
run() {
  echo "\$ $*"
  "$@" 2>&1 | sed "s|$PWD|.|g"
  return 0
}
```

`Ex08_ListResourceBundle/run.sh`

```bash
#!/usr/bin/env bash
# objective: 10.1
# ListResourceBundle (lớp Java) và thứ tự ưu tiên lớp > .properties.
source ./common.sh
run javac -d out Prices.java Prices_vi.java Main.java
cp *.properties out/
run java -cp out Main
```

Output thật (chạy `bash run.sh`, JDK 21.0.10):

```text
$ javac -d out Prices.java Prices_vi.java Main.java
$ java -cp out Main
vat=0.08 currency=VND tiers=[10, 20]
ClassCastException: getString trên giá trị Double
```
<!-- /EX -->

### 9. Currency

<!-- EX:Ex09_Currency -->
`examples/ch10/Ex09_Currency.java`

```java
// objective: 10.2
// Currency và định dạng tiền tệ: mã ISO 4217, ký hiệu theo locale, số chữ số thập phân.
import java.text.NumberFormat;
import java.util.Currency;
import java.util.Locale;

public class Ex09_Currency {
    static String show(String s) { return s.replace(' ', '_').replace(' ', '_'); }

    public static void main(String[] args) {
        Currency vnd = Currency.getInstance(Locale.of("vi", "VN"));
        Currency usd = Currency.getInstance("USD");
        System.out.println(vnd.getCurrencyCode() + " " + vnd.getDefaultFractionDigits() + " " + usd.getDefaultFractionDigits()
                + " " + show(vnd.getSymbol(Locale.of("vi", "VN"))) + " " + usd.getSymbol(Locale.US) + " " + usd.getSymbol(Locale.CANADA));
        NumberFormat f = NumberFormat.getCurrencyInstance(Locale.US);
        f.setCurrency(Currency.getInstance("EUR"));
        System.out.println(f.format(12.5) + " | " + show(NumberFormat.getCurrencyInstance(Locale.of("vi", "VN")).format(12345.678)));
        System.out.println(show(NumberFormat.getCurrencyInstance(Locale.JAPAN).format(1234.5)) + " | "
                + show(NumberFormat.getCurrencyInstance(Locale.of("en", "IN")).format(1234567.8)));
    }
}
```

Output thật (JDK 21.0.10):

```text
VND 0 2 ₫ $ US$
€12.50 | 12.346_₫
￥1,234 | ₹1,234,567.80
```
<!-- /EX -->

### 10. Locale.Category

<!-- EX:Ex10_LocaleCategory -->
`examples/ch10/Ex10_LocaleCategory.java`

```java
// objective: 10.1, 10.2
// Locale.Category: FORMAT (định dạng số/ngày) và DISPLAY (tên hiển thị) có thể đặt riêng.
import java.text.NumberFormat;
import java.util.Locale;

public class Ex10_LocaleCategory {
    static String show(String s) { return s.replace(' ', '_').replace(' ', '_'); }

    public static void main(String[] args) {
        Locale.setDefault(Locale.US);
        Locale.setDefault(Locale.Category.FORMAT, Locale.GERMANY);
        Locale.setDefault(Locale.Category.DISPLAY, Locale.FRANCE);
        System.out.println("default=" + Locale.getDefault() + " FORMAT=" + Locale.getDefault(Locale.Category.FORMAT)
                + " DISPLAY=" + Locale.getDefault(Locale.Category.DISPLAY));
        System.out.println("NumberFormat.getInstance() dùng FORMAT: " + show(NumberFormat.getInstance().format(1234.5)));
        System.out.println("getDisplayCountry() dùng DISPLAY: " + Locale.JAPAN.getDisplayCountry());
        System.out.println("String.format dùng FORMAT: " + String.format("%.1f", 2.5));
        Locale.setDefault(Locale.US);                                   // đặt lại cả hai category
        System.out.println("sau setDefault(US): " + NumberFormat.getInstance().format(1234.5) + " " + Locale.JAPAN.getDisplayCountry());
    }
}
```

Output thật (JDK 21.0.10):

```text
default=en_US FORMAT=de_DE DISPLAY=fr_FR
NumberFormat.getInstance() dùng FORMAT: 1.234,5
getDisplayCountry() dùng DISPLAY: Japon
String.format dùng FORMAT: 2,5
sau setDefault(US): 1,234.5 Japan
```
<!-- /EX -->

## Đi sâu

### Locale

- Tạo: `Locale.of("vi", "VN")` (Java 19+; constructor `new Locale(...)` đã deprecated), hằng số (`Locale.US`,
  `Locale.FRANCE`, `Locale.GERMAN` — chỉ ngôn ngữ), `Locale.forLanguageTag("vi-VN")`, `new Locale.Builder()`.
- `toString()` → `vi_VN`; `toLanguageTag()` → `vi-VN`. Ngôn ngữ viết thường, quốc gia viết hoa (tự chuẩn hoá).
- `getLanguage()`, `getCountry()` (có thể `""`), `getDisplayName([inLocale])`, `getDisplayLanguage`, `getDisplayCountry`.
- `Locale.getDefault()` / `setDefault(locale)`; `Locale.Category.FORMAT` (số, ngày) và `DISPLAY` (tên hiển thị) đặt
  riêng được: `setDefault(Category, locale)`.

### ResourceBundle

- Tên file: `BaseName_ngônngữ_QUỐCGIA.properties` (hoặc lớp `BaseName_ngônngữ_QUỐCGIA` kế thừa `ListResourceBundle`).
  File `.properties` được đọc bằng UTF-8 (Java 9+).
- `ResourceBundle.getBundle("Messages", locale)` tìm theo thứ tự (với locale yêu cầu `fr_CA`, mặc định `en_US`):

```text
Messages_fr_CA → Messages_fr → Messages_en_US → Messages_en → Messages (gốc)
   (yêu cầu)                    (locale mặc định)
```

  Bundle **đầu tiên tìm thấy** được chọn. Trong mỗi bước, lớp Java được thử trước file `.properties`.

```mermaid
graph LR
    A[Messages_fr_CA] -->|không có| B[Messages_fr]
    B -->|không có| C[Messages_en_US - locale mặc định]
    C -->|không có| D[Messages_en]
    D -->|không có| E[Messages - gốc]
    E -->|không có| F[MissingResourceException]
```

- Sau khi chọn, key được tìm trong bundle đó rồi **lên các bundle cha** của nó (chỉ theo locale đã chọn, ví dụ
  `fr_CA` → `fr` → gốc) — **không** tìm trong bundle của locale mặc định.
- Không tìm thấy bundle nào → `MissingResourceException`; không tìm thấy key → `MissingResourceException`.
- `getString(key)` (giá trị phải là `String`, nếu không → `ClassCastException`), `getObject(key)`, `keySet()`,
  `containsKey`, `getLocale()`.
- `Properties` (không phải bundle): `getProperty(key)` trả về `null` nếu thiếu, `getProperty(key, default)`.

### NumberFormat và DecimalFormat

| Factory | Ví dụ (US) |
|---|---|
| `NumberFormat.getInstance(l)` / `getNumberInstance` | `1,234.567` (tối đa 3 chữ số thập phân) |
| `getIntegerInstance(l)` | `1,235` (HALF_EVEN) |
| `getCurrencyInstance(l)` | `$1,234.57` |
| `getPercentInstance(l)` | `26%` (nhân 100) |
| `getCompactNumberInstance(l, Style.SHORT/LONG)` | `2M`, `2 million` |

- Làm tròn mặc định: **HALF_EVEN**. Chỉnh: `setMaximumFractionDigits`, `setMinimumFractionDigits`, `setRoundingMode`.
- `parse(String)` trả về `Number` (`Long` nếu không có phần lẻ, `Double` nếu có), đọc từ đầu và **dừng** ở ký tự lạ;
  không đọc được gì → `ParseException` (checked). Dấu `,`/`.` hiểu theo locale.
- `DecimalFormat("#,##0.00")`: `0` bắt buộc, `#` tuỳ chọn, `,` phân cách nhóm, `.` thập phân, `%` nhân 100,
  `'text'` là chữ nguyên văn.

### DateTimeFormatter

| Chữ | Ý nghĩa | Ví dụ |
|---|---|---|
| `y` / `yy` / `yyyy` | năm | `2024`, `24` |
| `M` / `MM` / `MMM` / `MMMM` | **tháng** | `3`, `03`, `Mar`, `March` |
| `d` / `dd` / `D` | ngày trong tháng / ngày trong năm | `5`, `05`, `65` |
| `E` / `EEEE` | thứ | `Tue`, `Tuesday` |
| `H` / `HH` | giờ 0–23 | `14` |
| `h` / `hh` + `a` | giờ 1–12 + AM/PM | `02 PM` |
| `m` / `mm` | **phút** | `07` |
| `s`, `S` | giây, phần giây | |
| `'...'`, `''` | chữ nguyên văn, dấu nháy | `'T'` |

- `DateTimeFormatter.ofPattern(pattern[, locale])`, `ofLocalizedDate/Time/DateTime(FormatStyle)` + `withLocale`,
  hằng ISO (`ISO_LOCAL_DATE`, `BASIC_ISO_DATE`…).
- `date.format(f)` ≡ `f.format(date)`; `LocalDate.parse(text, f)`. Sai định dạng → `DateTimeParseException`
  (unchecked). Pattern có giờ mà format `LocalDate` → `UnsupportedTemporalTypeException`.
- Parse văn bản mặc định phân biệt hoa thường.

### MessageFormat

- `MessageFormat.format("{0} có {1} tin", a, b)`; kiểu con: `{0,number}`, `{0,number,#.##}`, `{0,number,percent}`,
  `{0,date,short}`…
- `'` là ký tự escape: `'{0}'` in nguyên văn `{0}`; `''` in một dấu `'`. Thiếu tham số → in nguyên `{n}`.
- `new MessageFormat(pattern, locale)` để định dạng số theo locale.

## Lỗi và bẫy thường gặp (Exam traps)

1. `Locale.GERMAN` (chỉ ngôn ngữ) ≠ `Locale.GERMANY` (`de_DE`).
2. `toString()` dùng `_`, `toLanguageTag()` dùng `-`.
3. Locale mặc định được thử **trước** bundle gốc.
4. Key được thừa kế từ bundle cha của bundle đã chọn, không từ bundle của locale mặc định.
5. Lớp Java bundle thắng file `.properties` cùng tên.
6. Thiếu key → `MissingResourceException`, không trả `null` (khác `Properties.getProperty`).
7. `NumberFormat` là abstract; `parse` trả `Number` và ném `ParseException` (checked).
8. `parse("12abc")` → 12, không lỗi; `parse("abc")` → `ParseException`.
9. HALF_EVEN: `12.5` → `12`, `13.5` → `14`; percent `0.125` → `12%`.
10. `MM` tháng vs `mm` phút; `HH` 24h vs `hh` 12h.
11. `'` trong `MessageFormat` và `DateTimeFormatter`.
12. Dấu phân cách theo locale: `1,5` với US là 15.

## Góc nhìn từ TypeScript

| TypeScript / JavaScript | Java | Ghi chú |
|---|---|---|
| `new Intl.NumberFormat("vi-VN").format(n)` | `NumberFormat.getInstance(Locale.of("vi", "VN")).format(n)` | Cùng dùng dữ liệu CLDR |
| `Intl.NumberFormat(l, { style: "currency", currency: "VND" })` | `NumberFormat.getCurrencyInstance(l)` + `setCurrency` | |
| `Intl.NumberFormat(l, { notation: "compact" })` | `NumberFormat.getCompactNumberInstance(l, SHORT)` | |
| `new Intl.DateTimeFormat(l, { dateStyle: "short" })` | `DateTimeFormatter.ofLocalizedDate(FormatStyle.SHORT).withLocale(l)` | |
| Angular i18n (`$localize`, file `.xlf`) / ngx-translate (`vi.json`) | `ResourceBundle` + `Messages_vi.properties` | Cùng ý tưởng: key → chuỗi dịch |
| ICU message format `{count, plural, ...}` | `MessageFormat` (`ChoiceFormat` cho số nhiều) | |
| `navigator.language` | `Locale.getDefault()` | |

## Tóm tắt

- `Locale.of(lang, country)`, `forLanguageTag`, hằng số; `toString` (`_`) vs `toLanguageTag` (`-`).
- `ResourceBundle.getBundle`: locale yêu cầu → locale mặc định → gốc; key thừa kế từ bundle cha; lớp Java trước `.properties`.
- `NumberFormat`: number/integer/currency/percent/compact; HALF_EVEN; `parse` trả `Number`, `ParseException`.
- `DateTimeFormatter`: pattern (M/m, H/h, `'`), `FormatStyle` + `withLocale`, `DateTimeParseException`.
- `MessageFormat`: `{0}`, `{0,number,...}`, `'` escape.

## Bài tập (có lời giải)

Mọi đáp án đã được `tools/book.py` biên dịch và chạy để xác nhận (code: `examples/questions/ch10/`); các câu về bundle
dùng script tạo đúng file `.properties` rồi chạy chương trình.

### Câu hỏi

<!-- QUESTIONS:ch10 -->
#### Câu 10-01 · Dễ · objective 10.1

Chương trình sau in ra gì?

```java
import java.util.Locale;

public class Loc {
    public static void main(String[] args) {
        Locale a = Locale.of("fr", "CA");
        Locale b = Locale.forLanguageTag("vi-VN");
        Locale c = Locale.GERMAN;
        System.out.println(a + " " + b + " " + c + " [" + c.getCountry() + "]");
    }
}
```

- **A.** `fr_CA vi_VN de []`
- **B.** `fr-CA vi-VN de_DE [DE]`
- **C.** `fr_CA vi-VN de []`
- **D.** `CA_fr VN_vi de []`

#### Câu 10-02 · Vừa · objective 10.2

Chương trình sau in ra gì?

```java
import java.text.NumberFormat;
import java.util.Locale;

public class Money {
    public static void main(String[] args) {
        NumberFormat c = NumberFormat.getCurrencyInstance(Locale.US);
        NumberFormat p = NumberFormat.getPercentInstance(Locale.US);
        System.out.println(c.format(1234.567) + " " + p.format(0.125) + " " + c.format(-5));
    }
}
```

- **A.** `$1,234.57 13% -$5.00`
- **B.** `$1,234.57 12% -$5.00`
- **C.** `$1,234.56 12% ($5.00)`
- **D.** `$1234.57 12.5% -$5.00`

#### Câu 10-03 · Vừa · objective 10.2

Kết quả của chương trình là gì?

```java
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
```

- **A.** In ra `1.50075 3.5 Double`
- **B.** Ném `ParseException` vì có chữ `kg`
- **C.** In ra `1500.75 3 Long`
- **D.** In ra `1500.75 3.5 Double`

#### Câu 10-04 · Khó · objective 10.1

Classpath có các file bundle dưới đây. Chương trình `Main` in ra gì?

`Menu.properties`

```text
title=Root
```

`Menu_en.properties`

```text
title=English
```

`Menu_vi_VN.properties`

```text
title=VN
```

`Main.java`

```java
import java.util.*;

public class Main {
    public static void main(String[] args) {
        Locale.setDefault(Locale.of("en", "US"));
        String a = ResourceBundle.getBundle("Menu", Locale.of("vi")).getString("title");
        String b = ResourceBundle.getBundle("Menu", Locale.of("vi", "VN")).getString("title");
        System.out.println(a + " " + b);
    }
}
```

- **A.** `Root VN`
- **B.** `VN VN`
- **C.** Ném `MissingResourceException`
- **D.** `English VN`

#### Câu 10-05 · Vừa · objective 10.1

Với các bundle dưới đây, chương trình in ra gì?

`Messages.properties`

```text
a=root-a
b=root-b
```

`Messages_fr.properties`

```text
a=fr-a
```

`Messages_fr_CA.properties`

```text
b=ca-b
```

`Main.java`

```java
import java.util.*;

public class Main {
    public static void main(String[] args) {
        ResourceBundle rb = ResourceBundle.getBundle("Messages", Locale.CANADA_FRENCH);
        System.out.print(rb.getString("a") + " " + rb.getString("b") + " ");
        try {
            System.out.println(rb.getString("c"));
        } catch (MissingResourceException e) {
            System.out.println("missing");
        }
    }
}
```

- **A.** `root-a ca-b missing`
- **B.** `fr-a root-b missing`
- **C.** `fr-a ca-b missing`
- **D.** `fr-a ca-b null`

#### Câu 10-06 · Vừa · objective 10.2

Chèn dòng nào vào chỗ `// INSERT CODE HERE` thì chương trình in ra `05/03/2024 02:07 PM`? **(Chọn 2 đáp án.)**

```java
import java.time.*;
import java.time.format.*;
import java.util.Locale;

public class Pattern {
    public static void main(String[] args) {
        LocalDateTime dt = LocalDateTime.of(2024, 3, 5, 14, 7);
        // INSERT CODE HERE
    }
}
```

- **A.** `System.out.println(dt.format(DateTimeFormatter.ofPattern("dd/MM/yyyy hh:mm a", Locale.US)));`
- **B.** `System.out.println(dt.format(DateTimeFormatter.ofPattern("dd/mm/yyyy hh:mm a", Locale.US)));`
- **C.** `System.out.println(dt.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm a", Locale.US)));`
- **D.** `System.out.println(DateTimeFormatter.ofPattern("dd/MM/yyyy hh:mm a", Locale.US).format(dt));`
- **E.** `System.out.println(dt.format(DateTimeFormatter.ofPattern("d/M/yyyy h:mm a", Locale.US)));`

#### Câu 10-07 · Khó · objective 10.2

Chương trình sau in ra gì?

```java
import java.text.MessageFormat;

public class Quotes {
    public static void main(String[] args) {
        System.out.println(MessageFormat.format("'{0}' = {0}, it''s {1}", "x"));
    }
}
```

- **A.** `x = x, it's {1}`
- **B.** `'x' = x, it''s null`
- **C.** `{0} = x, it's {1}`
- **D.** `{0} = x, it's null`

#### Câu 10-08 · Vừa · objective 10.2

Chương trình sau in ra gì?

```java
import java.time.LocalDate;
import java.time.format.*;
import java.util.Locale;

public class Styles {
    public static void main(String[] args) {
        LocalDate d = LocalDate.of(2024, 12, 25);
        System.out.println(d.format(DateTimeFormatter.ofLocalizedDate(FormatStyle.SHORT).withLocale(Locale.US))
                + " | " + d.format(DateTimeFormatter.ofLocalizedDate(FormatStyle.MEDIUM).withLocale(Locale.US)));
    }
}
```

- **A.** `25/12/24 | 25 Dec 2024`
- **B.** `12/25/2024 | December 25, 2024`
- **C.** `2024-12-25 | Dec 25, 2024`
- **D.** `12/25/24 | Dec 25, 2024`

#### Câu 10-09 · Vừa · objective 10.1, 10.2

Hai phát biểu nào đúng? **(Chọn 2 đáp án.)**

- **A.** `Locale.of("vi").getCountry()` trả về chuỗi rỗng.
- **B.** `ResourceBundle.getBundle` ném exception khi không có bundle cho đúng locale yêu cầu, kể cả khi có bundle gốc.
- **C.** Locale mặc định của JVM có thể đổi lúc chạy bằng `Locale.setDefault`.
- **D.** Key trong `ResourceBundle` không phân biệt hoa thường.
- **E.** `NumberFormat.getInstance(Locale.US).parse("1,5")` trả về 1.5.

#### Câu 10-10 · Khó · objective 10.1

Có cả lớp `Prices_vi` (một `ListResourceBundle`) và file `Prices_vi.properties` trên classpath. Chương trình in ra gì?

`Prices.java`

```java
import java.util.ListResourceBundle;
public class Prices extends ListResourceBundle {
    protected Object[][] getContents() { return new Object[][]{{"currency", "USD"}}; }
}
```

`Prices_vi.java`

```java
import java.util.ListResourceBundle;
public class Prices_vi extends ListResourceBundle {
    protected Object[][] getContents() { return new Object[][]{{"currency", "VND"}}; }
}
```

`Prices_vi.properties`

```text
currency=FROM PROPERTIES
```

`Main.java`

```java
import java.util.*;
public class Main {
    public static void main(String[] args) {
        System.out.println(ResourceBundle.getBundle("Prices", Locale.of("vi")).getString("currency"));
    }
}
```

- **A.** `FROM PROPERTIES`
- **B.** `VND`
- **C.** `USD`
- **D.** Ném `MissingResourceException`

#### Câu 10-11 · Vừa · objective 10.2

Chương trình sau in ra gì?

```java
import java.text.*;
import java.util.Locale;

public class Patterns {
    public static void main(String[] args) {
        var sym = DecimalFormatSymbols.getInstance(Locale.US);
        System.out.println(new DecimalFormat("#,##0.0#", sym).format(1234.5) + " "
                + new DecimalFormat("00.00", sym).format(3.14159) + " "
                + new DecimalFormat("#.#", sym).format(0.05));
    }
}
```

- **A.** `1,234.50 3.14 .1`
- **B.** `1,234.5 03.14 .05`
- **C.** `1,234.5 03.14 0.1`
- **D.** `1234.5 03.14 0.1`

#### Câu 10-12 · Vừa · objective 10.2

Chương trình sau in ra gì?

```java
import java.text.NumberFormat;
import java.util.Locale;

public class Compact {
    public static void main(String[] args) {
        NumberFormat s = NumberFormat.getCompactNumberInstance(Locale.US, NumberFormat.Style.SHORT);
        NumberFormat l = NumberFormat.getCompactNumberInstance(Locale.US, NumberFormat.Style.LONG);
        System.out.println(s.format(1_250_000) + " " + l.format(3_000));
    }
}
```

- **A.** `1.25M 3 thousand`
- **B.** `1M 3 thousand`
- **C.** `1M 3K`
- **D.** `1,250K 3 thousand`

#### Câu 10-13 · Vừa · objective 10.2

Chương trình sau in ra gì?

```java
import java.text.NumberFormat;
import java.util.Locale;

public class HalfEven {
    public static void main(String[] args) {
        NumberFormat nf = NumberFormat.getIntegerInstance(Locale.US);
        System.out.println(nf.format(12.5) + " " + nf.format(13.5));
    }
}
```

- **A.** `13 14`
- **B.** `12 13`
- **C.** `12 14`
- **D.** `13 13`

#### Câu 10-14 · Dễ · objective 10.2

Chương trình sau in ra gì?

```java
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

public class Midnight {
    public static void main(String[] args) {
        LocalTime t = LocalTime.of(0, 5);
        System.out.println(t.format(DateTimeFormatter.ofPattern("hh:mm a", Locale.US)) + " "
                + t.format(DateTimeFormatter.ofPattern("HH:mm")));
    }
}
```

- **A.** `12:05 AM 00:05`
- **B.** `00:05 AM 00:05`
- **C.** `12:05 AM 12:05`
- **D.** `0:05 AM 00:05`

#### Câu 10-15 · Vừa · objective 10.1, 10.2

Những dòng nào gây lỗi biên dịch?

```java
import java.text.*;
import java.util.*;

public class L10n {
    public static void main(String[] args) throws ParseException {
        Locale a = Locale.of("en", "US");                               // L1
        Locale b = new Locale.Builder().setLanguage("en").build();      // L2
        Locale c = Locale.US.of("fr");                                  // L3
        NumberFormat d = new NumberFormat();                            // L4
        NumberFormat e = NumberFormat.getInstance(Locale.US);           // L5
        double f = e.parse("1.5");                                      // L6
    }
}
```

- **A.** Chỉ L4
- **B.** L4 và L6
- **C.** L3 và L4
- **D.** L3, L4 và L6
- **E.** Chỉ L6

#### Câu 10-16 · Khó · objective 10.1

Có các bundle `Msg.properties` (`bye=Goodbye`), `Msg_vi.properties` (`bye=Tạm biệt`), `Msg_vi_VN.properties` (`hello=Chào`). Chèn biểu thức nào vào chỗ `// INSERT CODE HERE` thì chương trình in ra `Tạm biệt`? **(Chọn 3 đáp án.)**

`Main.java`

```java
import java.util.*;

public class Main {
    public static void main(String[] args) {
        Locale.setDefault(Locale.US);
        System.out.println(// INSERT CODE HERE);
    }
}
```

- **A.** `ResourceBundle.getBundle("Msg", Locale.of("vi", "VN")).getString("bye")`
- **B.** `ResourceBundle.getBundle("Msg", Locale.of("vi")).getString("bye")`
- **C.** `ResourceBundle.getBundle("Msg", Locale.US).getString("bye")`
- **D.** `ResourceBundle.getBundle("Msg").getString("bye")`
- **E.** `ResourceBundle.getBundle("Msg", Locale.of("vi", "US")).getString("bye")`

#### Câu 10-17 · Vừa · objective 10.2

Chương trình sau in ra gì?

```java
import java.util.Locale;

public class Fmt {
    public static void main(String[] args) {
        System.out.println(String.format(Locale.GERMANY, "%,.2f", 1234.5) + " "
                + String.format(Locale.US, "%,.2f", 1234.5));
    }
}
```

- **A.** `1,234.50 1.234,50`
- **B.** `1234,50 1234.50`
- **C.** `1.234,5 1,234.5`
- **D.** `1.234,50 1,234.50`

#### Câu 10-18 · Dễ · objective 10.1

Chương trình sau in ra gì?

```java
import java.util.Locale;

public class Display {
    public static void main(String[] args) {
        Locale vi = Locale.of("vi", "VN");
        System.out.println(vi.getDisplayLanguage(Locale.US) + " " + vi.getDisplayCountry(Locale.US) + " "
                + vi.toLanguageTag());
    }
}
```

- **A.** `Vietnamese Vietnam vi-VN`
- **B.** `Vietnamese Vietnam vi_VN`
- **C.** `vi VN vi-VN`
- **D.** `Tiếng Việt Việt Nam vi-VN`

#### Câu 10-19 · Khó · objective 10.2, 1.4

Chương trình sau in ra gì?

```java
import java.time.LocalDate;
import java.time.format.*;
import java.util.Locale;

public class ParseDate {
    public static void main(String[] args) {
        DateTimeFormatter f = DateTimeFormatter.ofPattern("dd MMM yyyy", Locale.US);
        LocalDate d = LocalDate.parse("07 Jan 2024", f);
        System.out.print(d + " " + d.format(DateTimeFormatter.ofPattern("EEE D", Locale.US)) + " ");
        try {
            LocalDate.parse("07 jan 2024", f);
            System.out.println("ok");
        } catch (DateTimeParseException e) {
            System.out.println("fail");
        }
    }
}
```

- **A.** `2024-01-07 Sun 7 fail`
- **B.** `2024-01-07 Sun 7 ok`
- **C.** `2024-07-01 Mon 183 fail`
- **D.** `2024-01-07 Sun 07 ok`

#### Câu 10-20 · Vừa · objective 10.1

Có các bundle `Labels.properties` (`title=Root title`), `Labels_de.properties` (`title=Deutscher Titel`), `Labels_en.properties` (`title=English title`). Locale mặc định là `ja_JP`. `getBundle("Labels", Locale.FRANCE)` trả về giá trị `title` nào?

`Labels.properties`

```text
title=Root title
```

`Labels_de.properties`

```text
title=Deutscher Titel
```

`Labels_en.properties`

```text
title=English title
```

`Main.java`

```java
import java.util.*;
public class Main {
    public static void main(String[] args) {
        Locale.setDefault(Locale.JAPAN);
        System.out.println(ResourceBundle.getBundle("Labels", Locale.FRANCE).getString("title"));
    }
}
```

- **A.** `Root title`
- **B.** `Deutscher Titel`
- **C.** `English title`
- **D.** Ném `MissingResourceException`
<!-- /QUESTIONS -->

### Lời giải

<!-- ANSWERS:ch10 -->
#### Câu 10-01 — Đáp án: **A** (Dễ · objective 10.1)

- **Vì sao đúng:** `Locale.toString()` có dạng `ngôn ngữ_QUỐC GIA` (dấu gạch dưới). `forLanguageTag("vi-VN")` đọc tag có gạch ngang nhưng `toString()` vẫn in `vi_VN`. `Locale.GERMAN` chỉ có ngôn ngữ, quốc gia là chuỗi rỗng.
- **B sai:** `toString()` dùng `_`; `Locale.GERMAN` (khác `Locale.GERMANY`) không có quốc gia.
- **C sai:** Dạng có gạch ngang là của `toLanguageTag()`, không phải `toString()`.
- **D sai:** Ngôn ngữ đứng trước quốc gia.
- *Kiểm chứng:* `examples/questions/ch10/Q10_01/` — output confirmed (`python3 tools/book.py questions ch10`).

#### Câu 10-02 — Đáp án: **B** (Vừa · objective 10.2)

- **Vì sao đúng:** Tiền tệ US: 2 chữ số thập phân, có dấu phân cách hàng nghìn → `$1,234.57`. Percent nhân 100 và mặc định không có chữ số thập phân; `NumberFormat` làm tròn kiểu **HALF_EVEN** (nửa về số chẵn) → 12.5 thành `12%`. Số âm in `-$5.00`.
- **A sai:** Chế độ làm tròn mặc định là HALF_EVEN: 12.5 → 12 (số chẵn gần nhất).
- **C sai:** 1234.567 làm tròn thành .57; và số âm hiển thị bằng dấu `-` (không phải ngoặc) với CLDR hiện tại.
- **D sai:** Có dấu phân cách hàng nghìn, và percent mặc định không có phần thập phân.
- *Kiểm chứng:* `examples/questions/ch10/Q10_02/` — output confirmed (`python3 tools/book.py questions ch10`).

#### Câu 10-03 — Đáp án: **D** (Vừa · objective 10.2)

- **Vì sao đúng:** Ở Đức, `.` là dấu phân cách hàng nghìn và `,` là dấu thập phân → 1500.75. `parse(String)` đọc từ đầu chuỗi và **dừng** ở ký tự không hợp lệ đầu tiên (`k`), không ném exception → 3.5 (kiểu `Double` vì có phần thập phân).
- **A sai:** Với locale Đức, dấu `.` là phân cách hàng nghìn, không phải dấu thập phân.
- **B sai:** `parse` chỉ ném `ParseException` khi **không đọc được gì** ở đầu chuỗi.
- **C sai:** `,5` là phần thập phân theo locale Đức; kết quả có phần lẻ nên là `Double`.
- *Kiểm chứng:* `examples/questions/ch10/Q10_03/` — output confirmed (`python3 tools/book.py questions ch10`).

#### Câu 10-04 — Đáp án: **D** (Khó · objective 10.1)

- **Vì sao đúng:** Với `vi`: tìm `Menu_vi` (không có) → chuyển sang **locale mặc định** `en_US`: `Menu_en_US` (không có), `Menu_en` (có) → `English`. Locale mặc định được thử **trước** bundle gốc. Với `vi_VN`: có `Menu_vi_VN` → `VN`.
- **A sai:** Bundle gốc chỉ dùng khi cả locale yêu cầu lẫn locale mặc định đều không có bundle.
- **B sai:** `Menu_vi_VN` là bundle **con** của `vi`; tìm cho `vi` không đi xuống bundle con.
- **C sai:** Luôn có ít nhất bundle gốc `Menu`, nên không lỗi.
- *Kiểm chứng:* `examples/questions/ch10/Q10_04/` — script output confirmed (`python3 tools/book.py questions ch10`).

#### Câu 10-05 — Đáp án: **C** (Vừa · objective 10.1)

- **Vì sao đúng:** Bundle được chọn là `Messages_fr_CA`, với chuỗi cha (parent chain) `Messages_fr` → `Messages`. Một key không có ở bundle con thì được tìm lên bundle cha: `a` lấy từ `fr`, `b` từ `fr_CA`. Không có ở đâu → `MissingResourceException`.
- **A sai:** `Messages_fr` định nghĩa `a`, và nó gần hơn bundle gốc.
- **B sai:** `Messages_fr_CA` định nghĩa `b`, được ưu tiên hơn bundle gốc.
- **D sai:** `getString` ném exception khi không tìm thấy key, không trả về `null`.
- *Kiểm chứng:* `examples/questions/ch10/Q10_05/` — script output confirmed (`python3 tools/book.py questions ch10`).

#### Câu 10-06 — Đáp án: **A, D** (Vừa · objective 10.2)

- **Vì sao đúng:** `MM` = tháng (2 chữ số), `mm` = phút, `hh` = giờ 1–12 (2 chữ số), `HH` = giờ 0–23, `a` = AM/PM. Có thể gọi `dt.format(formatter)` hoặc `formatter.format(dt)` — cùng kết quả.
- **B sai:** `mm` là phút: in `05/07/2024 ...`.
- **C sai:** `HH` là giờ 24h: in `14:07 PM`.
- **E sai:** Một chữ cái (`d`, `M`, `h`) không thêm số 0 ở đầu: `5/3/2024 2:07 PM`.
- *Kiểm chứng:* `examples/questions/ch10/Q10_06/` — variants: AD satisfy output (`python3 tools/book.py questions ch10`).

#### Câu 10-07 — Đáp án: **C** (Khó · objective 10.2)

- **Vì sao đúng:** Trong `MessageFormat`, dấu `'` bao quanh phần văn bản được in nguyên văn: `'{0}'` → `{0}`. Hai dấu `''` → một dấu `'`. Placeholder không có tham số tương ứng (`{1}`) được in nguyên văn `{1}`.
- **A sai:** `'{0}'` nằm trong dấu nháy đơn nên không được thay thế.
- **B sai:** Dấu `'` là ký tự escape, không được in ra; và thiếu tham số không in `null`.
- **D sai:** Placeholder thiếu tham số giữ nguyên `{1}`.
- *Kiểm chứng:* `examples/questions/ch10/Q10_07/` — output confirmed (`python3 tools/book.py questions ch10`).

#### Câu 10-08 — Đáp án: **D** (Vừa · objective 10.2)

- **Vì sao đúng:** Với `Locale.US`: `SHORT` là `M/d/yy` → `12/25/24`; `MEDIUM` là `MMM d, y` → `Dec 25, 2024`. (`LONG` sẽ là `December 25, 2024`.)
- **A sai:** Đó là thứ tự ngày/tháng của locale như `en_GB`; US để tháng trước.
- **B sai:** `SHORT` dùng năm 2 chữ số; tháng đầy đủ là của `LONG`.
- **C sai:** `2024-12-25` là định dạng ISO (`ISO_LOCAL_DATE`), không phụ thuộc locale.
- *Kiểm chứng:* `examples/questions/ch10/Q10_08/` — output confirmed (`python3 tools/book.py questions ch10`).

#### Câu 10-09 — Đáp án: **A, C** (Vừa · objective 10.1, 10.2)

- **Vì sao đúng:** A: locale chỉ có ngôn ngữ thì quốc gia là `""`. C: `Locale.setDefault` đổi locale mặc định cho JVM hiện tại.
- **B sai:** Nếu không có bundle cho locale yêu cầu (và locale mặc định), bundle gốc được dùng.
- **D sai:** Key phân biệt hoa thường: `Greeting` ≠ `greeting` → `MissingResourceException`.
- **E sai:** Với US, `,` là dấu phân cách hàng nghìn nên `1,5` được đọc thành 15.
- *Kiểm chứng:* `examples/questions/ch10/Q10_09/` — each option proven true/false by a program (`python3 tools/book.py questions ch10`).

#### Câu 10-10 — Đáp án: **B** (Khó · objective 10.1)

- **Vì sao đúng:** Với cùng một tên bundle, `ResourceBundle` (định dạng mặc định) tìm **lớp Java** trước, rồi mới tới file `.properties`. Lớp `Prices_vi` tồn tại nên được dùng.
- **A sai:** File `.properties` chỉ được dùng khi không có lớp cùng tên.
- **C sai:** Bundle `vi` có key `currency`, nên không cần lên bundle cha `Prices`.
- **D sai:** Bundle và key đều tồn tại.
- *Kiểm chứng:* `examples/questions/ch10/Q10_10/` — script output confirmed (`python3 tools/book.py questions ch10`).

#### Câu 10-11 — Đáp án: **C** (Vừa · objective 10.2)

- **Vì sao đúng:** Trong pattern, `0` = chữ số bắt buộc (thêm số 0 nếu thiếu), `#` = chữ số tuỳ chọn. `0.0#` → ít nhất 1, nhiều nhất 2 chữ số thập phân → `1,234.5`. `00.00` → `03.14`. `#.#` → một chữ số thập phân: 0.05 (giá trị double thật hơi lớn hơn 0.05) làm tròn thành `0.1`.
- **A sai:** `#` ở vị trí thập phân thứ hai là tuỳ chọn nên không in `0` thừa; `00.00` bắt buộc 2 chữ số phần nguyên.
- **B sai:** `#.#` chỉ giữ một chữ số thập phân.
- **D sai:** `#,##0` có dấu phân cách hàng nghìn.
- *Kiểm chứng:* `examples/questions/ch10/Q10_11/` — output confirmed (`python3 tools/book.py questions ch10`).

#### Câu 10-12 — Đáp án: **B** (Vừa · objective 10.2)

- **Vì sao đúng:** Compact number format (Java 12+) rút gọn số theo locale: `SHORT` → `K`, `M`…; `LONG` → `thousand`, `million`… Mặc định không có chữ số thập phân nên 1.25M làm tròn thành `1M`.
- **A sai:** Mặc định số chữ số thập phân tối đa là 0 → không in `.25`.
- **C sai:** Style `LONG` dùng chữ đầy đủ: `3 thousand`.
- **D sai:** Đơn vị được chọn là lớn nhất phù hợp: triệu (`M`).
- *Kiểm chứng:* `examples/questions/ch10/Q10_12/` — output confirmed (`python3 tools/book.py questions ch10`).

#### Câu 10-13 — Đáp án: **C** (Vừa · objective 10.2)

- **Vì sao đúng:** `NumberFormat` mặc định dùng `RoundingMode.HALF_EVEN`: khi đúng nửa, làm tròn về số **chẵn** gần nhất. 12.5 → 12, 13.5 → 14. (Khác `Math.round`, luôn làm tròn nửa lên.)
- **A sai:** Đó là cách làm tròn HALF_UP (như `Math.round`), không phải mặc định của `NumberFormat`.
- **B sai:** 13.5 làm tròn về 14 (số chẵn).
- **D sai:** 12.5 → 12 và 13.5 → 14.
- *Kiểm chứng:* `examples/questions/ch10/Q10_13/` — output confirmed (`python3 tools/book.py questions ch10`).

#### Câu 10-14 — Đáp án: **A** (Dễ · objective 10.2)

- **Vì sao đúng:** `hh` là giờ theo đồng hồ 12 giờ (1–12): 0 giờ là `12` AM. `HH` là giờ 0–23: `00`.
- **B sai:** `hh` không bao giờ in `00`; nửa đêm là `12 AM`.
- **C sai:** `HH` là giờ 24h, nên 0 giờ là `00`.
- **D sai:** `hh` có 2 chữ số và dùng dải 1–12 (`K` mới là 0–11).
- *Kiểm chứng:* `examples/questions/ch10/Q10_14/` — output confirmed (`python3 tools/book.py questions ch10`).

#### Câu 10-15 — Đáp án: **B** (Vừa · objective 10.1, 10.2)

- **Vì sao đúng:** `NumberFormat` là lớp **abstract** → không `new` được (L4); dùng factory `getInstance`… `parse` trả về `Number` (có thể là `Long` hoặc `Double`), không gán thẳng cho `double` được (L6); cần `.doubleValue()`. L3 gọi method static qua một object — kiểu viết xấu nhưng hợp lệ.
- **A sai:** L6 cũng lỗi: `Number` không tự unboxing thành `double`.
- **C sai:** Gọi method static `Locale.of` qua biến `Locale.US` vẫn biên dịch được (chỉ là cảnh báo về style).
- **D sai:** L3 hợp lệ (xem C).
- **E sai:** L4 cũng lỗi: `NumberFormat` là abstract.
- *Kiểm chứng:* `examples/questions/ch10/Q10_15/` — compile error confirmed at ['L4', 'L6'] (`python3 tools/book.py questions ch10`).

#### Câu 10-16 — Đáp án: **A, B, E** (Khó · objective 10.1)

- **Vì sao đúng:** A: bundle `vi_VN` không có `bye` nên lấy từ bundle cha `vi`. B: dùng thẳng `Msg_vi`. E: không có `Msg_vi_US`, nên lùi về `Msg_vi` (cùng ngôn ngữ).
- **C sai:** `Locale.US`: không có `Msg_en_US`/`Msg_en` → dùng bundle gốc → `Goodbye`.
- **D sai:** Không truyền locale → dùng locale mặc định `en_US` → bundle gốc → `Goodbye`.
- *Kiểm chứng:* `examples/questions/ch10/Q10_16/` — script variants: ABE in ra 'Tạm biệt' (`python3 tools/book.py questions ch10`).

#### Câu 10-17 — Đáp án: **D** (Vừa · objective 10.2)

- **Vì sao đúng:** `String.format(Locale, ...)` dùng ký hiệu của locale: Đức dùng `.` cho hàng nghìn và `,` cho thập phân; US ngược lại. Cờ `,` bật phân cách hàng nghìn, `.2f` in đúng 2 chữ số thập phân.
- **A sai:** Đảo ngược: locale Đức đứng trước trong chuỗi.
- **B sai:** Cờ `,` trong `%,.2f` bật dấu phân cách hàng nghìn.
- **C sai:** `.2f` luôn in đủ 2 chữ số thập phân.
- *Kiểm chứng:* `examples/questions/ch10/Q10_17/` — output confirmed (`python3 tools/book.py questions ch10`).

#### Câu 10-18 — Đáp án: **A** (Dễ · objective 10.1)

- **Vì sao đúng:** `getDisplayXxx(Locale inLocale)` trả về tên hiển thị **bằng ngôn ngữ của `inLocale`** (ở đây tiếng Anh). `toLanguageTag()` dùng dạng BCP 47 với gạch ngang: `vi-VN`.
- **B sai:** `toLanguageTag()` dùng `-`; `_` là của `toString()`.
- **C sai:** `getDisplayLanguage` trả tên đầy đủ; mã ngắn là `getLanguage()`.
- **D sai:** Tên được hiển thị bằng ngôn ngữ của tham số (`Locale.US`), không phải tiếng Việt.
- *Kiểm chứng:* `examples/questions/ch10/Q10_18/` — output confirmed (`python3 tools/book.py questions ch10`).

#### Câu 10-19 — Đáp án: **A** (Khó · objective 10.2, 1.4)

- **Vì sao đúng:** `MMM` với `Locale.US` đọc tên tháng viết tắt `Jan`. `EEE` = thứ viết tắt (`Sun`), `D` = ngày thứ mấy trong năm (7). Mặc định việc parse văn bản **phân biệt hoa thường**, nên `jan` không khớp → `DateTimeParseException`.
- **B sai:** Parse mặc định phân biệt hoa thường (muốn khác phải dùng `DateTimeFormatterBuilder.parseCaseInsensitive()`).
- **C sai:** `dd` là ngày, `MMM` là tháng: 7 tháng 1.
- **D sai:** `D` một chữ cái không thêm số 0; và `jan` không parse được.
- *Kiểm chứng:* `examples/questions/ch10/Q10_19/` — output confirmed (`python3 tools/book.py questions ch10`).

#### Câu 10-20 — Đáp án: **A** (Vừa · objective 10.1)

- **Vì sao đúng:** Thứ tự thử: `Labels_fr_FR`, `Labels_fr` (không có) → locale mặc định `Labels_ja_JP`, `Labels_ja` (không có) → bundle gốc `Labels`. Bundle `de` và `en` không liên quan tới cả `fr` lẫn `ja`.
- **B sai:** Không locale nào trong chuỗi tìm kiếm là tiếng Đức.
- **C sai:** Tiếng Anh không nằm trong chuỗi tìm kiếm (locale mặc định là `ja_JP`).
- **D sai:** Bundle gốc tồn tại nên luôn có kết quả.
- *Kiểm chứng:* `examples/questions/ch10/Q10_20/` — script output confirmed (`python3 tools/book.py questions ch10`).
<!-- /ANSWERS -->

## Đọc thêm (link chính thức — bị chặn trong sandbox nên mình chưa mở được)

- Javadoc `ResourceBundle` (thuật toán tìm bundle): https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/ResourceBundle.html
- Javadoc `DateTimeFormatter` (bảng chữ cái pattern): https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/time/format/DateTimeFormatter.html

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:

- `ResourceBundle.java` (candidate locales, fallback locale, lớp trước properties): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/util/ResourceBundle.java
- `NumberFormat.java` (HALF_EVEN, `parse`, compact number): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/text/NumberFormat.java
- `DateTimeFormatter.java` (bảng pattern letters): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/time/format/DateTimeFormatter.java
- `Locale.java` (`Locale.of`, constructor deprecated từ Java 19): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/util/Locale.java
