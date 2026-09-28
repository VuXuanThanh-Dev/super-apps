# Chương 7 — Module, đóng gói và triển khai (Packaging and Deploying Java Code)

## Mục tiêu

- 7.1 Định nghĩa module và "mở" nội dung của nó (kể cả cho reflection); khai báo phụ thuộc; định nghĩa **service**,
  **provider** và **consumer**.
- 7.2 Biên dịch code, tạo JAR modular và non-modular, tạo **runtime image** (jlink), và chuyển đổi (migration) sang
  module bằng **unnamed module** và **automatic module**.

## Giải thích đơn giản

Trước Java 9, mọi lớp `public` đều dùng được từ bất cứ đâu trên classpath. **Java Platform Module System (JPMS)**
thêm một lớp nữa phía trên package: **module** = một nhóm package + file mô tả `module-info.java`.

```java
module com.shop {              // tên module
    requires java.sql;         // tôi cần module này
    exports com.shop.api;      // package này cho người khác dùng
}
```

Ba lợi ích: **đóng gói mạnh** (package không `exports` thì bên ngoài không dùng được, dù lớp là `public`),
**phụ thuộc rõ ràng** (thiếu module → lỗi ngay khi khởi động, không đợi `ClassNotFoundException`), và
**runtime nhỏ** (jlink chỉ gói các module cần).

Ba "vùng" code:

| Loại | Ở đâu | Có tên? | Đọc được gì | Export gì |
|---|---|---|---|---|
| **Named module** | Module path, có `module-info` | Có | Chỉ module được `requires` (+ transitive) | Chỉ package `exports` |
| **Automatic module** | Module path, JAR **không** có `module-info` | Có (suy ra từ tên file hoặc MANIFEST) | Mọi module + unnamed module | **Tất cả** package |
| **Unnamed module** | Classpath | Không | Mọi module | Tất cả package, nhưng named module **không** `requires` được nó |

## Ví dụ

Mỗi ví dụ là một thư mục trong `examples/ch07/` có script `run.sh`. Output bên dưới là output thật của script
(JDK 21.0.10); đường dẫn tạm của máy được thay bằng `.`. Chạy lại: `python3 tools/book.py examples ch07`.

### 1. Module đầu tiên

<!-- EX:Ex01_FirstModule -->
`Ex01_FirstModule/common.sh`

```bash
# Helper sourced by every run.sh in ch07: prints each command, then its output with the temp path hidden.
unset JAVA_TOOL_OPTIONS
run() {
  echo "\$ $*"
  "$@" 2>&1 | sed "s|$PWD|.|g"
  return 0
}
```

`Ex01_FirstModule/src/com.greet/com/greet/Main.java`

```java
package com.greet;

public class Main {
    public static void main(String[] args) {
        Module m = Main.class.getModule();
        System.out.println("Hello from module " + m.getName());
        System.out.println("named? " + m.isNamed() + ", requires java.logging? "
                + m.getDescriptor().requires().stream().anyMatch(r -> r.name().equals("java.logging")));
    }
}
```

`Ex01_FirstModule/src/com.greet/module-info.java`

```java
// objective: 7.1, 7.2
module com.greet {            // tên module: thường theo tên package gốc
    requires java.logging;    // java.base luôn được requires ngầm
}
```

`Ex01_FirstModule/run.sh`

```bash
#!/usr/bin/env bash
# objective: 7.1, 7.2
# Biên dịch và chạy một module đơn giản.
source ./common.sh
run javac -d out --module-source-path src -m com.greet
run find out -name "*.class" | sort
run java --module-path out --module com.greet/com.greet.Main
run java -p out -m com.greet/com.greet.Main
run java -p out --describe-module com.greet
```

Output thật (chạy `bash run.sh`, JDK 21.0.10):

```text
$ javac -d out --module-source-path src -m com.greet
$ find out -name *.class
out/com.greet/com/greet/Main.class
out/com.greet/module-info.class
$ java --module-path out --module com.greet/com.greet.Main
Hello from module com.greet
named? true, requires java.logging? true
$ java -p out -m com.greet/com.greet.Main
Hello from module com.greet
named? true, requires java.logging? true
$ java -p out --describe-module com.greet
com.greet file://./out/com.greet/
requires java.base mandated
requires java.logging
contains com.greet
```
<!-- /EX -->

### 2. requires / exports

<!-- EX:Ex02_RequiresExports -->
`Ex02_RequiresExports/bad/com.app/com/app/App.java`

```java
package com.app;

import com.util.internal.Helper;     // package không được export

public class App {
    public static void main(String[] args) {
        System.out.println(Helper.clean(" x "));
    }
}
```

`Ex02_RequiresExports/bad/com.app/module-info.java`

```java
module com.app {
    requires com.util;
}
```

`Ex02_RequiresExports/common.sh`

```bash
# Helper sourced by every run.sh in ch07: prints each command, then its output with the temp path hidden.
unset JAVA_TOOL_OPTIONS
run() {
  echo "\$ $*"
  "$@" 2>&1 | sed "s|$PWD|.|g"
  return 0
}
```

`Ex02_RequiresExports/src/com.app/com/app/App.java`

```java
package com.app;

import com.util.api.TextUtil;

public class App {
    public static void main(String[] args) {
        System.out.println(TextUtil.shout("  modules  "));
    }
}
```

`Ex02_RequiresExports/src/com.app/module-info.java`

```java
module com.app {
    requires com.util;
}
```

`Ex02_RequiresExports/src/com.util/com/util/api/TextUtil.java`

```java
package com.util.api;

import com.util.internal.Helper;

public class TextUtil {
    public static String shout(String s) { return Helper.clean(s).toUpperCase() + "!"; }
}
```

`Ex02_RequiresExports/src/com.util/com/util/internal/Helper.java`

```java
package com.util.internal;

public class Helper {
    public static String clean(String s) { return s.strip(); }
}
```

`Ex02_RequiresExports/src/com.util/module-info.java`

```java
module com.util {
    exports com.util.api;          // chỉ package này được module khác dùng
    // com.util.internal KHÔNG export → bị "đóng gói mạnh" (strong encapsulation)
}
```

`Ex02_RequiresExports/run.sh`

```bash
#!/usr/bin/env bash
# objective: 7.1
# requires + exports; và lỗi khi dùng package KHÔNG được export.
source ./common.sh
run javac -d out --module-source-path src -m com.util,com.app
run java -p out -m com.app/com.app.App
echo "--- dùng package com.util.internal (không export):"
mkdir -p bad-src && cp -r src/com.util bad-src/ && cp -r bad/com.app bad-src/
run javac -d out2 --module-source-path bad-src -m com.util,com.app
```

Output thật (chạy `bash run.sh`, JDK 21.0.10):

```text
$ javac -d out --module-source-path src -m com.util,com.app
$ java -p out -m com.app/com.app.App
MODULES!
--- dùng package com.util.internal (không export):
$ javac -d out2 --module-source-path bad-src -m com.util,com.app
bad-src/com.app/com/app/App.java:3: error: package com.util.internal is not visible
import com.util.internal.Helper;     // package không được export
               ^
  (package com.util.internal is declared in module com.util, which does not export it)
1 error
```
<!-- /EX -->

### 3. requires transitive

<!-- EX:Ex03_Transitive -->
`Ex03_Transitive/common.sh`

```bash
# Helper sourced by every run.sh in ch07: prints each command, then its output with the temp path hidden.
unset JAVA_TOOL_OPTIONS
run() {
  echo "\$ $*"
  "$@" 2>&1 | sed "s|$PWD|.|g"
  return 0
}
```

`Ex03_Transitive/src/com.base/com/base/Money.java`

```java
package com.base;

public record Money(long amount) { }
```

`Ex03_Transitive/src/com.base/module-info.java`

```java
module com.base {
    exports com.base;
}
```

`Ex03_Transitive/src/com.mid/com/mid/Wallet.java`

```java
package com.mid;

import com.base.Money;

public class Wallet {
    public static Money balance() { return new Money(500); }   // API trả về kiểu của com.base
}
```

`Ex03_Transitive/src/com.mid/module-info.java`

```java
module com.mid {
    requires transitive com.base;   // ai requires com.mid cũng tự đọc được com.base
    exports com.mid;
}
```

`Ex03_Transitive/src/com.top/com/top/Main.java`

```java
package com.top;

import com.base.Money;
import com.mid.Wallet;

public class Main {
    public static void main(String[] args) {
        Money m = Wallet.balance();
        System.out.println("balance = " + m.amount());
        System.out.println("com.top reads com.base? " + Main.class.getModule()
                .canRead(Money.class.getModule()));
    }
}
```

`Ex03_Transitive/src/com.top/module-info.java`

```java
module com.top {
    requires com.mid;               // KHÔNG cần requires com.base nhờ "transitive"
}
```

`Ex03_Transitive/run.sh`

```bash
#!/usr/bin/env bash
# objective: 7.1
# requires transitive (implied readability).
source ./common.sh
run javac -d out --module-source-path src -m com.top
run java -p out -m com.top/com.top.Main
run java -p out --describe-module com.mid
```

Output thật (chạy `bash run.sh`, JDK 21.0.10):

```text
$ javac -d out --module-source-path src -m com.top
$ java -p out -m com.top/com.top.Main
balance = 500
com.top reads com.base? true
$ java -p out --describe-module com.mid
com.mid file://./out/com.mid/
exports com.mid
requires com.base transitive
requires java.base mandated
```
<!-- /EX -->

### 4. exports vs opens (reflection)

<!-- EX:Ex04_OpensReflection -->
`Ex04_OpensReflection/common.sh`

```bash
# Helper sourced by every run.sh in ch07: prints each command, then its output with the temp path hidden.
unset JAVA_TOOL_OPTIONS
run() {
  echo "\$ $*"
  "$@" 2>&1 | sed "s|$PWD|.|g"
  return 0
}
```

`Ex04_OpensReflection/src/com.inspect/com/inspect/Main.java`

```java
package com.inspect;

import com.model.Secret;
import java.lang.reflect.Field;

public class Main {
    public static void main(String[] args) throws Exception {
        Secret s = new Secret();
        System.out.println(s.hint());
        Field f = Secret.class.getDeclaredField("code");
        try {
            f.setAccessible(true);                          // đòi hỏi package phải được "opens"
            System.out.println("private code = " + f.get(s));
        } catch (RuntimeException e) {
            System.out.println(e.getClass().getSimpleName());
        }
    }
}
```

`Ex04_OpensReflection/src/com.inspect/module-info.java`

```java
module com.inspect {
    requires com.model;
}
```

`Ex04_OpensReflection/src/com.model/com/model/Secret.java`

```java
package com.model;

public class Secret {
    private String code = "42";
    public String hint() { return "public hint"; }
}
```

`Ex04_OpensReflection/src/com.model/module-info.java`

```java
module com.model {
    exports com.model;                  // compile-time + public members lúc chạy
    // "opens com.model;" sẽ cho phép reflection vào cả thành viên private
}
```

`Ex04_OpensReflection/run.sh`

```bash
#!/usr/bin/env bash
# objective: 7.1
# exports vs opens: reflection sâu (private) cần "opens".
source ./common.sh
run javac -d out --module-source-path src -m com.model,com.inspect
echo "--- chỉ exports:"
run java -p out -m com.inspect/com.inspect.Main
echo "--- thêm 'opens com.model;' vào module-info của com.model:"
sed -i 's|// "opens com.model;".*|opens com.model;|' src/com.model/module-info.java
run cat src/com.model/module-info.java
run javac -d out --module-source-path src -m com.model,com.inspect
run java -p out -m com.inspect/com.inspect.Main
```

Output thật (chạy `bash run.sh`, JDK 21.0.10):

```text
$ javac -d out --module-source-path src -m com.model,com.inspect
--- chỉ exports:
$ java -p out -m com.inspect/com.inspect.Main
public hint
InaccessibleObjectException
--- thêm 'opens com.model;' vào module-info của com.model:
$ cat src/com.model/module-info.java
module com.model {
    exports com.model;                  // compile-time + public members lúc chạy
    opens com.model;
}
$ javac -d out --module-source-path src -m com.model,com.inspect
$ java -p out -m com.inspect/com.inspect.Main
public hint
private code = 42
```
<!-- /EX -->

### 5. Service: provider và consumer

<!-- EX:Ex05_Services -->
`Ex05_Services/common.sh`

```bash
# Helper sourced by every run.sh in ch07: prints each command, then its output with the temp path hidden.
unset JAVA_TOOL_OPTIONS
run() {
  echo "\$ $*"
  "$@" 2>&1 | sed "s|$PWD|.|g"
  return 0
}
```

`Ex05_Services/src/com.shop.api/com/shop/api/PaymentService.java`

```java
package com.shop.api;

public interface PaymentService {
    String name();
    String pay(long amount);
}
```

`Ex05_Services/src/com.shop.api/module-info.java`

```java
module com.shop.api {
    exports com.shop.api;               // service interface
}
```

`Ex05_Services/src/com.shop.app/com/shop/app/Checkout.java`

```java
package com.shop.app;

import com.shop.api.PaymentService;
import java.util.ServiceLoader;

public class Checkout {
    public static void main(String[] args) {
        ServiceLoader<PaymentService> loader = ServiceLoader.load(PaymentService.class);
        long count = loader.stream().count();
        System.out.println("providers found: " + count);
        loader.findFirst().ifPresentOrElse(
                p -> System.out.println(p.pay(150_000)),
                () -> System.out.println("no payment provider"));
    }
}
```

`Ex05_Services/src/com.shop.app/module-info.java`

```java
module com.shop.app {
    requires com.shop.api;
    uses com.shop.api.PaymentService;   // consumer khai báo sẽ tìm service này
}
```

`Ex05_Services/src/com.shop.vnpay/com/shop/vnpay/VnPay.java`

```java
package com.shop.vnpay;

import com.shop.api.PaymentService;

public class VnPay implements PaymentService {
    public VnPay() { }                  // provider cần constructor public không tham số (hoặc method static provider())
    public String name() { return "VNPay"; }
    public String pay(long amount) { return "paid " + amount + " VND via " + name(); }
}
```

`Ex05_Services/src/com.shop.vnpay/module-info.java`

```java
module com.shop.vnpay {
    requires com.shop.api;
    provides com.shop.api.PaymentService with com.shop.vnpay.VnPay;   // service provider
    // KHÔNG cần exports com.shop.vnpay: consumer không biết lớp cài đặt
}
```

`Ex05_Services/run.sh`

```bash
#!/usr/bin/env bash
# objective: 7.1
# Service: interface (api) + provider (provides ... with ...) + consumer (uses + ServiceLoader).
source ./common.sh
run javac -d out --module-source-path src -m com.shop.api,com.shop.vnpay,com.shop.app
echo "--- chạy KHÔNG có provider trên module path:"
mkdir -p only && cp -r out/com.shop.api out/com.shop.app only/
run java -p only -m com.shop.app/com.shop.app.Checkout
echo "--- chạy CÓ provider:"
run java -p out -m com.shop.app/com.shop.app.Checkout
run java -p out --describe-module com.shop.vnpay
```

Output thật (chạy `bash run.sh`, JDK 21.0.10):

```text
$ javac -d out --module-source-path src -m com.shop.api,com.shop.vnpay,com.shop.app
--- chạy KHÔNG có provider trên module path:
$ java -p only -m com.shop.app/com.shop.app.Checkout
providers found: 0
no payment provider
--- chạy CÓ provider:
$ java -p out -m com.shop.app/com.shop.app.Checkout
providers found: 1
paid 150000 VND via VNPay
$ java -p out --describe-module com.shop.vnpay
com.shop.vnpay file://./out/com.shop.vnpay/
requires java.base mandated
requires com.shop.api
provides com.shop.api.PaymentService with com.shop.vnpay.VnPay
contains com.shop.vnpay
```
<!-- /EX -->

### 6. JAR modular và non-modular

<!-- EX:Ex06_Jars -->
`Ex06_Jars/common.sh`

```bash
# Helper sourced by every run.sh in ch07: prints each command, then its output with the temp path hidden.
unset JAVA_TOOL_OPTIONS
run() {
  echo "\$ $*"
  "$@" 2>&1 | sed "s|$PWD|.|g"
  return 0
}
```

`Ex06_Jars/legacy/org/old/Tool.java`

```java
package org.old;

public class Tool {
    public static void main(String[] args) {
        Module m = Tool.class.getModule();
        System.out.println("legacy tool, named module? " + m.isNamed() + " name=" + m.getName());
    }
}
```

`Ex06_Jars/src/com.calc/com/calc/Calc.java`

```java
package com.calc;

public class Calc {
    public static int add(int a, int b) { return a + b; }
    public static void main(String[] args) {
        System.out.println("2 + 3 = " + add(2, 3) + " (module " + Calc.class.getModule().getName() + ")");
    }
}
```

`Ex06_Jars/src/com.calc/module-info.java`

```java
module com.calc {
    exports com.calc;
}
```

`Ex06_Jars/run.sh`

```bash
#!/usr/bin/env bash
# objective: 7.2
# Tạo JAR modular (có module-info.class) và JAR thường (non-modular), rồi chạy.
source ./common.sh
run javac -d out/com.calc src/com.calc/module-info.java src/com.calc/com/calc/Calc.java
mkdir -p mods
run jar --create --file mods/calc.jar --main-class com.calc.Calc -C out/com.calc .
run jar --describe-module --file mods/calc.jar
run java -p mods -m com.calc                     # có Main-Class nên không cần ghi tên lớp
echo "--- JAR non-modular chạy trên classpath:"
run javac -d legacy-out legacy/org/old/Tool.java
run jar --create --file tool.jar -C legacy-out .
run java -cp tool.jar org.old.Tool
run jar --list --file mods/calc.jar
```

Output thật (chạy `bash run.sh`, JDK 21.0.10):

```text
$ javac -d out/com.calc src/com.calc/module-info.java src/com.calc/com/calc/Calc.java
$ jar --create --file mods/calc.jar --main-class com.calc.Calc -C out/com.calc .
$ jar --describe-module --file mods/calc.jar
com.calc jar:file://./mods/calc.jar!/module-info.class
exports com.calc
requires java.base mandated
main-class com.calc.Calc

$ java -p mods -m com.calc
2 + 3 = 5 (module com.calc)
--- JAR non-modular chạy trên classpath:
$ javac -d legacy-out legacy/org/old/Tool.java
$ jar --create --file tool.jar -C legacy-out .
$ java -cp tool.jar org.old.Tool
legacy tool, named module? false name=null
$ jar --list --file mods/calc.jar
META-INF/
META-INF/MANIFEST.MF
module-info.class
com/
com/calc/
com/calc/Calc.class
```
<!-- /EX -->

### 7. Automatic module và unnamed module

<!-- EX:Ex07_AutomaticModules -->
`Ex07_AutomaticModules/common.sh`

```bash
# Helper sourced by every run.sh in ch07: prints each command, then its output with the temp path hidden.
unset JAVA_TOOL_OPTIONS
run() {
  echo "\$ $*"
  "$@" 2>&1 | sed "s|$PWD|.|g"
  return 0
}
```

`Ex07_AutomaticModules/lib/org/json/lite/Json.java`

```java
package org.json.lite;

// Thư viện "cũ" không có module-info.java
public class Json {
    public static String quote(String s) { return "\"" + s + "\""; }
    public static String whoAmI() {
        Module m = Json.class.getModule();
        return "Json is in module: " + (m.isNamed() ? m.getName() : "UNNAMED");
    }
}
```

`Ex07_AutomaticModules/src/com.report/com/report/Report.java`

```java
package com.report;

import org.json.lite.Json;

public class Report {
    public static void main(String[] args) {
        System.out.println(Json.quote("report") + " | " + Json.whoAmI());
    }
}
```

`Ex07_AutomaticModules/src/com.report/module-info.java`

```java
module com.report {
    requires json.lite;     // tên automatic module suy ra từ tên file json-lite-1.2.jar
}
```

`Ex07_AutomaticModules/run.sh`

```bash
#!/usr/bin/env bash
# objective: 7.2
# Migration: JAR không có module-info đặt trên MODULE PATH → automatic module; trên CLASSPATH → unnamed module.
source ./common.sh
run javac -d lib-out lib/org/json/lite/Json.java
mkdir -p mods
run jar --create --file mods/json-lite-1.2.jar -C lib-out .
run jar --describe-module --file mods/json-lite-1.2.jar
run javac -d out -p mods --module-source-path src -m com.report
run java -p mods:out -m com.report/com.report.Report
echo "--- cùng thư viện nhưng đặt trên classpath (unnamed module), chạy code không modular:"
cat > Plain.java <<'JAVA'
public class Plain {
    public static void main(String[] args) {
        System.out.println(org.json.lite.Json.whoAmI());
    }
}
JAVA
run javac -cp mods/json-lite-1.2.jar -d plain-out Plain.java
run java -cp mods/json-lite-1.2.jar:plain-out Plain
echo "--- đặt Automatic-Module-Name trong MANIFEST để chọn tên ổn định:"
printf 'Automatic-Module-Name: org.json.lite\n' > manifest.txt
run jar --create --file mods/json-lite-1.2.jar --manifest manifest.txt -C lib-out .
run jar --describe-module --file mods/json-lite-1.2.jar
```

Output thật (chạy `bash run.sh`, JDK 21.0.10):

```text
$ javac -d lib-out lib/org/json/lite/Json.java
$ jar --create --file mods/json-lite-1.2.jar -C lib-out .
$ jar --describe-module --file mods/json-lite-1.2.jar
No module descriptor found. Derived automatic module.

json.lite@1.2 automatic
requires java.base mandated
contains org.json.lite

$ javac -d out -p mods --module-source-path src -m com.report
$ java -p mods:out -m com.report/com.report.Report
"report" | Json is in module: json.lite
--- cùng thư viện nhưng đặt trên classpath (unnamed module), chạy code không modular:
$ javac -cp mods/json-lite-1.2.jar -d plain-out Plain.java
$ java -cp mods/json-lite-1.2.jar:plain-out Plain
Json is in module: UNNAMED
--- đặt Automatic-Module-Name trong MANIFEST để chọn tên ổn định:
$ jar --create --file mods/json-lite-1.2.jar --manifest manifest.txt -C lib-out .
$ jar --describe-module --file mods/json-lite-1.2.jar
No module descriptor found. Derived automatic module.

org.json.lite@1.2 automatic
requires java.base mandated
contains org.json.lite
```
<!-- /EX -->

### 8. jlink: runtime image

<!-- EX:Ex08_Jlink -->
`Ex08_Jlink/common.sh`

```bash
# Helper sourced by every run.sh in ch07: prints each command, then its output with the temp path hidden.
unset JAVA_TOOL_OPTIONS
run() {
  echo "\$ $*"
  "$@" 2>&1 | sed "s|$PWD|.|g"
  return 0
}
```

`Ex08_Jlink/src/com.hello/com/hello/Hello.java`

```java
package com.hello;

public class Hello {
    public static void main(String[] args) {
        System.out.println("Hello from a custom runtime image! modules in boot layer: "
                + ModuleLayer.boot().modules().size());
    }
}
```

`Ex08_Jlink/src/com.hello/module-info.java`

```java
module com.hello {
}
```

`Ex08_Jlink/run.sh`

```bash
#!/usr/bin/env bash
# objective: 7.2
# jlink: tạo runtime image nhỏ chỉ chứa các module cần thiết.
source ./common.sh
run javac -d out --module-source-path src -m com.hello
run jlink --module-path out --add-modules com.hello --output image --strip-debug --no-header-files --no-man-pages
run image/bin/java --list-modules
run image/bin/java -m com.hello/com.hello.Hello
echo "\$ ls image"
ls image | sort
```

Output thật (chạy `bash run.sh`, JDK 21.0.10):

```text
$ javac -d out --module-source-path src -m com.hello
$ jlink --module-path out --add-modules com.hello --output image --strip-debug --no-header-files --no-man-pages
$ image/bin/java --list-modules
com.hello
java.base@21.0.10
$ image/bin/java -m com.hello/com.hello.Hello
Hello from a custom runtime image! modules in boot layer: 2
$ ls image
bin
conf
legal
lib
release
```
<!-- /EX -->

### 9. jdeps

Chú ý dòng cuối: `--print-module-deps` chỉ in `java.base,java.sql` vì `java.sql` đã `requires transitive java.logging`.

<!-- EX:Ex09_Jdeps -->
`Ex09_Jdeps/app/com/legacy/Db.java`

```java
package com.legacy;

import java.sql.DriverManager;
import java.util.logging.Logger;

public class Db {
    static final Logger LOG = Logger.getLogger("db");
    public static void main(String[] args) {
        int timeout = DriverManager.getLoginTimeout();   // dùng một lớp của java.sql
        LOG.fine("timeout " + timeout);
        System.out.println("needs java.sql and java.logging");
    }
}
```

`Ex09_Jdeps/common.sh`

```bash
# Helper sourced by every run.sh in ch07: prints each command, then its output with the temp path hidden.
unset JAVA_TOOL_OPTIONS
run() {
  echo "\$ $*"
  "$@" 2>&1 | sed "s|$PWD|.|g"
  return 0
}
```

`Ex09_Jdeps/run.sh`

```bash
#!/usr/bin/env bash
# objective: 7.2
# jdeps: xem JAR phụ thuộc module nào của JDK (bước đầu khi chuyển sang module).
source ./common.sh
run javac -d app-out app/com/legacy/Db.java
run jar --create --file legacy.jar -C app-out .
run jdeps -summary legacy.jar
run jdeps --list-deps legacy.jar
run jdeps --print-module-deps legacy.jar
```

Output thật (chạy `bash run.sh`, JDK 21.0.10):

```text
$ javac -d app-out app/com/legacy/Db.java
$ jar --create --file legacy.jar -C app-out .
$ jdeps -summary legacy.jar
legacy.jar -> java.base
legacy.jar -> java.logging
legacy.jar -> java.sql
$ jdeps --list-deps legacy.jar
   java.base
   java.logging
   java.sql
$ jdeps --print-module-deps legacy.jar
java.base,java.sql
```
<!-- /EX -->

### 10. Module của JDK

<!-- EX:Ex10_JdkModules -->
`Ex10_JdkModules/common.sh`

```bash
# Helper sourced by every run.sh in ch07: prints each command, then its output with the temp path hidden.
unset JAVA_TOOL_OPTIONS
run() {
  echo "\$ $*"
  "$@" 2>&1 | sed "s|$PWD|.|g"
  return 0
}
```

`Ex10_JdkModules/run.sh`

```bash
#!/usr/bin/env bash
# objective: 7.1, 7.2
# Các module của JDK: java.base là gốc; mọi module đều requires java.base ngầm.
source ./common.sh
echo "\$ java --list-modules | grep -E '^java\.(base|sql|logging|se)@'"
java --list-modules | grep -E '^java\.(base|sql|logging|se)@'
run java --describe-module java.sql
echo "\$ java --describe-module java.base | head -5"
java --describe-module java.base | head -5
```

Output thật (chạy `bash run.sh`, JDK 21.0.10):

```text
$ java --list-modules | grep -E '^java\.(base|sql|logging|se)@'
java.base@21.0.10
java.logging@21.0.10
java.se@21.0.10
java.sql@21.0.10
$ java --describe-module java.sql
java.sql@21.0.10
exports java.sql
exports javax.sql
requires java.base mandated
requires java.transaction.xa transitive
requires java.logging transitive
requires java.xml transitive
uses java.sql.Driver
$ java --describe-module java.base | head -5
java.base@21.0.10
exports java.io
exports java.lang
exports java.lang.annotation
exports java.lang.constant
```
<!-- /EX -->

### 11. Lỗi module hay gặp

<!-- EX:Ex11_ModuleErrors -->
`Ex11_ModuleErrors/common.sh`

```bash
# Helper sourced by every run.sh in ch07: prints each command, then its output with the temp path hidden.
unset JAVA_TOOL_OPTIONS
run() {
  echo "\$ $*"
  "$@" 2>&1 | sed "s|$PWD|.|g"
  return 0
}
```

`Ex11_ModuleErrors/cycle/mod.a/a/A.java`

```java
package a;
public class A { }
```

`Ex11_ModuleErrors/cycle/mod.a/module-info.java`

```java
module mod.a { requires mod.b; exports a; }
```

`Ex11_ModuleErrors/cycle/mod.b/b/B.java`

```java
package b;
public class B { }
```

`Ex11_ModuleErrors/cycle/mod.b/module-info.java`

```java
module mod.b { requires mod.a; exports b; }
```

`Ex11_ModuleErrors/missing/mod.c/c/C.java`

```java
package c;
public class C { }
```

`Ex11_ModuleErrors/missing/mod.c/module-info.java`

```java
module mod.c { requires does.not.exist; }
```

`Ex11_ModuleErrors/run.sh`

```bash
#!/usr/bin/env bash
# objective: 7.1
# Lỗi hay gặp: vòng phụ thuộc (cycle) giữa các module; requires module không tồn tại; chạy module không có trên path.
source ./common.sh
run javac -d out1 --module-source-path cycle -m mod.a,mod.b
run javac -d out2 --module-source-path missing -m mod.c
run java -p out1 -m mod.a/a.A
```

Output thật (chạy `bash run.sh`, JDK 21.0.10):

```text
$ javac -d out1 --module-source-path cycle -m mod.a,mod.b
cycle/mod.b/module-info.java:1: error: cyclic dependence involving mod.a
module mod.b { requires mod.a; exports b; }
                           ^
cycle/mod.a/module-info.java:1: error: cyclic dependence involving mod.b
module mod.a { requires mod.b; exports a; }
                           ^
2 errors
$ javac -d out2 --module-source-path missing -m mod.c
missing/mod.c/module-info.java:1: error: module not found: does.not.exist
module mod.c { requires does.not.exist; }
                                ^
1 error
$ java -p out1 -m mod.a/a.A
Error occurred during initialization of boot layer
java.lang.module.FindException: Module mod.a not found
```
<!-- /EX -->

## Đi sâu

### Các directive trong `module-info.java`

| Directive | Ý nghĩa |
|---|---|
| `requires M;` | Module này đọc (reads) M — lúc biên dịch và lúc chạy |
| `requires transitive M;` | Như trên, và ai `requires` module này cũng đọc M (implied readability) |
| `requires static M;` | Chỉ cần M lúc biên dịch; lúc chạy là tuỳ chọn |
| `exports P;` | Package P dùng được (kiểu public) lúc biên dịch và lúc chạy |
| `exports P to M1, M2;` | Qualified export: chỉ M1, M2 dùng được |
| `opens P;` / `opens P to M;` | Cho phép **deep reflection** (cả `private`) vào P lúc chạy; không mở lúc biên dịch |
| `open module X { ... }` | Mở **mọi** package cho reflection; bên trong không được viết `opens` |
| `uses S;` | Module này tiêu thụ (consume) service S qua `ServiceLoader` |
| `provides S with Impl1, Impl2;` | Module này cung cấp cài đặt cho service S |

Quy tắc: `java.base` luôn được requires ngầm (`mandated`). Không có vòng `requires`. Một package chỉ thuộc một module
(không split package). `exports` package rỗng/không tồn tại là lỗi. `module-info.java` nằm ở gốc thư mục module,
không khai báo `package`.

### Service (4 thành phần)

1. **Service interface** — trong module "api", được `exports`.
2. **Service provider** — lớp cài đặt, module của nó `requires` api và `provides Service with Impl;`. Lớp cài đặt
   không cần export; cần constructor public không tham số **hoặc** method `public static provider()`.
3. **Service locator / consumer** — module `requires` api và `uses Service;`, gọi `ServiceLoader.load(Service.class)`.
   Thiếu `uses` trong named module → `ServiceConfigurationError` lúc chạy.
4. **ServiceLoader** — `iterator()`, `stream()` (trả về `Provider` → `.get()`), `findFirst()` (trả về `Optional`).
   Không có provider → rỗng, không lỗi.

Thêm provider mới chỉ cần đặt module provider lên module path — consumer không phải biên dịch lại.

### Lệnh cần thuộc

| Việc | Lệnh |
|---|---|
| Biên dịch một module | `javac -d out/com.x src/com.x/module-info.java src/com.x/com/x/*.java` |
| Biên dịch nhiều module | `javac -d out --module-source-path src -m com.a,com.b` |
| Biên dịch với module đã có | thêm `-p mods` (`--module-path`) |
| Chạy | `java -p out -m com.x/com.x.Main` (`--module-path`, `--module`) |
| Tạo JAR modular | `jar --create --file mods/x.jar [--main-class com.x.Main] -C out/com.x .` (`-cvf` dạng ngắn) |
| Chạy JAR có Main-Class | `java -p mods -m com.x` |
| Xem mô tả module | `java -p mods --describe-module com.x` (`-d`), `jar --describe-module --file x.jar` (`-d`) |
| Liệt kê module JDK | `java --list-modules` |
| Xem phụ thuộc | `jdeps -summary x.jar` (`-s`), `jdeps --list-deps`, `jdeps --print-module-deps`, `jdeps --jdk-internals` |
| Tạo runtime image | `jlink --module-path out --add-modules com.x --output image` |
| Chẩn đoán lúc chạy | `java --show-module-resolution`, `java -p mods --validate-modules` |

### Migration (chuyển đổi sang module)

- **Bottom-up:** chuyển các thư viện "lá" (không phụ thuộc ai) thành named module trước, rồi đi dần lên. Code chưa
  chuyển vẫn chạy trên classpath (unnamed module đọc được mọi module).
- **Top-down:** chuyển ứng dụng thành named module trước; các thư viện chưa có `module-info` được đặt lên module path
  thành **automatic module** để ứng dụng `requires` được.
- Tên automatic module: `Automatic-Module-Name` trong MANIFEST nếu có; nếu không, suy ra từ tên file
  (`my-utils-2.0.1.jar` → `my.utils`, version 2.0.1).
- Named module **không** `requires` được unnamed module. Automatic module đọc được unnamed module (cầu nối).
- JAR có `module-info.class` nhưng đặt trên **classpath** → `module-info` bị bỏ qua, lớp thuộc unnamed module.

## Lỗi và bẫy thường gặp (Exam traps)

1. `public` không đủ: package phải được `exports`.
2. `exports` ≠ `opens`: reflection vào `private` cần `opens` (hoặc `open module`).
3. `requires` không truyền tiếp; cần `requires transitive`.
4. `provides Impl with Interface` (đảo thứ tự) → lỗi. Đúng: `provides Interface with Impl`.
5. Consumer thiếu `uses` → lỗi lúc **chạy** (`ServiceConfigurationError`), không phải lúc biên dịch.
6. Không có provider → `ServiceLoader` rỗng, không lỗi.
7. Vòng `requires` → lỗi biên dịch "cyclic dependence".
8. `open module` + `opens` bên trong → lỗi.
9. `-m` của `java` nhận `module/lớp`; thư mục module đưa bằng `-p`, không phải `-cp`.
10. `javac -m` cần `--module-source-path`.
11. jlink cần `--add-modules`; image gồm cả phụ thuộc bắc cầu (qua `requires transitive`).
12. Không có directive `imports`, `requires public`, `exports ... with`.

## Góc nhìn từ TypeScript

| TypeScript / npm | Java module | Ghi chú |
|---|---|---|
| `package.json` → `dependencies` | `requires` | Nhưng Java không tải thư viện; chỉ khai báo phụ thuộc giữa module có sẵn |
| `package.json` → `exports` (điểm vào công khai) | `exports` | Rất giống: chặn import "sâu" vào file nội bộ |
| Import file nội bộ `lib/dist/internal/x` (khi không có `exports`) | Không thể: package không export → lỗi biên dịch | Java chặt hơn |
| `peerDependencies` | Gần với `requires transitive` (cho người dùng thấy kiểu của phụ thuộc) | Chỉ tương đồng ý tưởng |
| Dependency injection / plugin của Angular (`InjectionToken`, `multi: true`) | `ServiceLoader` + `uses` / `provides` | Nhiều provider cho một token |
| Bundle tree-shaking (esbuild, webpack) | `jlink` (chỉ giữ module cần thiết) | Ở mức module, không mức hàm |

## Tóm tắt

- `module-info.java`: `requires` (transitive/static), `exports` (to), `opens` (to), `uses`, `provides ... with`.
- Named / automatic / unnamed: ai đọc ai, ai export gì.
- Service = interface + provider + consumer + `ServiceLoader`.
- Lệnh: `javac --module-source-path -m`, `java -p -m`, `jar --create --main-class`, `jar/java --describe-module`,
  `jdeps`, `jlink --add-modules --output`.
- Migration: bottom-up (thư viện trước), top-down (ứng dụng trước + automatic module).

## Bài tập (có lời giải)

Câu hỏi của chương này dùng nhiều file, nên script kiểm tra tạo đúng cấu trúc thư mục, chạy `javac`/`java`/`jar`/`jlink`
thật và so sánh output (code: `examples/questions/ch07/`).

### Câu hỏi

<!-- QUESTIONS:ch07 -->
#### Câu 07-01 · Dễ · objective 7.1

Hai module nằm trong thư mục `src` như dưới đây. Chạy lệnh `javac -d out --module-source-path src -m com.lib,com.app` thì điều gì xảy ra?

`src/com.lib/module-info.java`

```java
module com.lib {
    exports com.lib.api;
}
```

`src/com.lib/com/lib/api/Api.java`

```java
package com.lib.api;
public class Api { public static String hi() { return "hi"; } }
```

`src/com.lib/com/lib/impl/Impl.java`

```java
package com.lib.impl;
public class Impl { public static String secret() { return "secret"; } }
```

`src/com.app/module-info.java`

```java
module com.app {
    requires com.lib;
}
```

`src/com.app/com/app/Main.java`

```java
package com.app;
import com.lib.impl.Impl;
public class Main {
    public static void main(String[] args) { System.out.println(Impl.secret()); }
}
```

- **A.** Biên dịch thành công; chạy in ra `secret`
- **B.** Lỗi biên dịch: package `com.lib.impl` không nhìn thấy được (not visible)
- **C.** Biên dịch thành công nhưng ném `IllegalAccessError` lúc chạy
- **D.** Biên dịch thành công nhưng ném `ClassNotFoundException` lúc chạy

#### Câu 07-02 · Vừa · objective 7.1

Module `com.top` dùng kiểu `com.base.Money` do method của `com.mid` trả về, nhưng **không** `requires com.base`. Điền directive nào vào chỗ `// INSERT CODE HERE` trong `module-info.java` của `com.mid` thì cả ba module biên dịch được?

`src/com.base/module-info.java`

```java
module com.base { exports com.base; }
```

`src/com.base/com/base/Money.java`

```java
package com.base;
public record Money(long amount) { }
```

`src/com.mid/module-info.java`

```java
module com.mid {
    // INSERT CODE HERE
    exports com.mid;
}
```

`src/com.mid/com/mid/Wallet.java`

```java
package com.mid;
public class Wallet { public static com.base.Money balance() { return new com.base.Money(5); } }
```

`src/com.top/module-info.java`

```java
module com.top { requires com.mid; }
```

`src/com.top/com/top/Main.java`

```java
package com.top;
import com.base.Money;
public class Main {
    public static void main(String[] args) { Money m = com.mid.Wallet.balance(); System.out.println(m); }
}
```

- **A.** `requires com.base;`
- **B.** `requires transitive com.base;`
- **C.** `requires static com.base;`
- **D.** `exports com.base;`

#### Câu 07-03 · Vừa · objective 7.1

Hai phát biểu nào đúng về module? **(Chọn 2 đáp án.)**

- **A.** Mọi module đều ngầm `requires java.base`.
- **B.** Hai module khác nhau có thể cùng chứa một package trên module path.
- **C.** `exports` một package cho phép reflection truy cập cả thành viên `private` của nó.
- **D.** Tên module có thể chứa dấu chấm, ví dụ `com.shop.api`.
- **E.** `module-info.java` có thể khai báo `package` ở dòng đầu như lớp bình thường.

#### Câu 07-04 · Vừa · objective 7.1

Cho hai module dưới đây. Sau khi biên dịch, chạy `java -p out -m m.user/m.user.Main` thì in ra gì?

`src/m.model/module-info.java`

```java
module m.model {
    exports m.model;
    opens m.model;
}
```

`src/m.model/m/model/Config.java`

```java
package m.model;
public class Config { private String env = "prod"; }
```

`src/m.user/module-info.java`

```java
module m.user { requires m.model; }
```

`src/m.user/m/user/Main.java`

```java
package m.user;
import java.lang.reflect.Field;
public class Main {
    public static void main(String[] args) throws Exception {
        Field f = m.model.Config.class.getDeclaredField("env");
        f.setAccessible(true);
        System.out.println("env=" + f.get(new m.model.Config()));
    }
}
```

- **A.** `env=null`
- **B.** Ném `InaccessibleObjectException`
- **C.** `env=prod`
- **D.** Lỗi biên dịch: không được vừa `exports` vừa `opens` cùng một package

#### Câu 07-05 · Khó · objective 7.1

Điền directive nào vào `module-info.java` của module provider (chỗ `// INSERT CODE HERE`) để `ServiceLoader` trong module `com.app` tìm được đúng một provider?

`src/com.api/module-info.java`

```java
module com.api { exports com.api; }
```

`src/com.api/com/api/Greeter.java`

```java
package com.api;
public interface Greeter { String greet(); }
```

`src/com.impl/module-info.java`

```java
module com.impl {
    requires com.api;
    // INSERT CODE HERE
}
```

`src/com.impl/com/impl/Hi.java`

```java
package com.impl;
public class Hi implements com.api.Greeter { public String greet() { return "hi"; } }
```

`src/com.app/module-info.java`

```java
module com.app {
    requires com.api;
    uses com.api.Greeter;
}
```

`src/com.app/com/app/Main.java`

```java
package com.app;
import java.util.ServiceLoader;
public class Main {
    public static void main(String[] args) {
        System.out.println("providers=" + ServiceLoader.load(com.api.Greeter.class).stream().count());
    }
}
```

- **A.** `provides com.api.Greeter with com.impl.Hi;`
- **B.** `exports com.impl;`
- **C.** `uses com.api.Greeter;`
- **D.** `provides com.impl.Hi with com.api.Greeter;`

#### Câu 07-06 · Vừa · objective 7.1

Module `com.app` dưới đây gọi `ServiceLoader.load(...)` nhưng quên khai báo `uses`. Điều gì xảy ra khi chạy `java -p out -m com.app/com.app.Main`?

`src/com.api/module-info.java`

```java
module com.api { exports com.api; }
```

`src/com.api/com/api/Greeter.java`

```java
package com.api;
public interface Greeter { String greet(); }
```

`src/com.app/module-info.java`

```java
module com.app {
    requires com.api;
}
```

`src/com.app/com/app/Main.java`

```java
package com.app;
import java.util.ServiceLoader;
public class Main {
    public static void main(String[] args) {
        System.out.println("count=" + ServiceLoader.load(com.api.Greeter.class).stream().count());
    }
}
```

- **A.** In ra `count=0`
- **B.** Lỗi biên dịch: thiếu `uses`
- **C.** Ném `java.util.ServiceConfigurationError` lúc chạy
- **D.** In ra `count=1`

#### Câu 07-07 · Dễ · objective 7.2

File `my-utils-2.0.1.jar` **không** có `module-info.class` và không có `Automatic-Module-Name` trong MANIFEST. Khi đặt nó trên module path, tên automatic module là gì?

`lib/org/util/Tool.java`

```java
package org.util;
public class Tool { }
```

- **A.** `my-utils`
- **B.** `my.utils`
- **C.** `my.utils.2.0.1`
- **D.** `myutils`

#### Câu 07-08 · Vừa · objective 7.2

Lớp `Probe` (không thuộc module nào) được biên dịch và chạy trên **classpath** bằng `java -cp out Probe`. Chương trình in ra gì?

`Probe.java`

```java
public class Probe {
    public static void main(String[] args) {
        Module m = Probe.class.getModule();
        System.out.println(m.isNamed() + " " + m.getName() + " "
                + m.canRead(java.sql.Connection.class.getModule()));
    }
}
```

- **A.** `true Probe true`
- **B.** `false null false`
- **C.** `false unnamed true`
- **D.** `false null true`

#### Câu 07-09 · Vừa · objective 7.2

Module `com.x` (lớp chính `com.x.Main`, in ra `hi`) đã được biên dịch vào thư mục `mods`. Lệnh nào chạy được chương trình? **(Chọn 2 đáp án.)**

- **A.** `java -p mods -m com.x/com.x.Main`
- **B.** `java --module-path mods --module com.x/com.x.Main`
- **C.** `java -cp mods -m com.x/com.x.Main`
- **D.** `java -p mods com.x.Main`
- **E.** `java -m mods/com.x/com.x.Main`

#### Câu 07-10 · Khó · objective 7.2

Module `com.app` chỉ có `requires java.sql;`. Sau khi chạy `jlink --module-path out --add-modules com.app --output image`, lệnh `image/bin/java --list-modules` liệt kê những module nào?

`src/com.app/module-info.java`

```java
module com.app { requires java.sql; }
```

`src/com.app/com/app/Main.java`

```java
package com.app;
public class Main { public static void main(String[] args) { } }
```

- **A.** Chỉ `com.app`
- **B.** `com.app` và `java.base`
- **C.** `com.app`, `java.base`, `java.logging`, `java.sql`, `java.transaction.xa`, `java.xml`
- **D.** Toàn bộ module của JDK

#### Câu 07-11 · Vừa · objective 7.1

Chèn dòng nào vào chỗ `// INSERT CODE HERE` trong `module-info.java` thì làm module **không** biên dịch được? **(Chọn 2 đáp án.)**

`src/com.shop/module-info.java`

```java
module com.shop {
    // INSERT CODE HERE
}
```

`src/com.shop/com/shop/api/Cart.java`

```java
package com.shop.api;
public class Cart { }
```

- **A.** `requires java.sql;`
- **B.** `exports com.shop.api to java.sql;`
- **C.** `imports com.shop.api;`
- **D.** `opens com.shop.api;`
- **E.** `requires public java.sql;`

#### Câu 07-12 · Khó · objective 7.1

Khai báo module nào (thay cho `// INSERT CODE HERE`) làm cho việc biên dịch **thất bại**? **(Chọn 2 đáp án.)**

`src/com.m/module-info.java`

```java
// INSERT CODE HERE
```

`src/com.m/com/m/p/Data.java`

```java
package com.m.p;
public class Data { }
```

- **A.** `open module com.m { exports com.m.p; }`
- **B.** `open module com.m { opens com.m.p; }`
- **C.** `module com.m { opens com.m.p; exports com.m.p; }`
- **D.** `module com.m { opens com.m.p to java.base; }`
- **E.** `module com.m { exports com.m.missing; }`

#### Câu 07-13 · Khó · objective 7.2

Hai phát biểu nào đúng về unnamed module và automatic module? **(Chọn 2 đáp án.)**

- **A.** Code trên classpath (unnamed module) dùng được các package được export của named module.
- **B.** Named module có thể `requires` code nằm trên classpath.
- **C.** Automatic module export **tất cả** package của nó.
- **D.** Một JAR có `module-info.class` đặt trên **classpath** vẫn chạy như named module.
- **E.** Tên automatic module luôn giống hệt tên file JAR.

#### Câu 07-14 · Dễ · objective 7.2

`legacy.jar` chứa một lớp dùng `java.sql.DriverManager` và `java.util.logging.Logger`. Lệnh `jdeps --print-module-deps legacy.jar` in ra gì?

`app/com/legacy/Db.java`

```java
package com.legacy;
public class Db {
    public static void main(String[] args) {
        java.util.logging.Logger.getLogger("db").info("t=" + java.sql.DriverManager.getLoginTimeout());
    }
}
```

- **A.** `java.base,java.sql`
- **B.** `java.sql,java.logging`
- **C.** `java.base,java.logging,java.sql`
- **D.** `legacy.jar -> java.sql`

#### Câu 07-15 · Vừa · objective 7.1

Module `com.core` có `exports com.core.api to com.friend;`. Hai module `com.friend` và `com.other` đều `requires com.core` và dùng `com.core.api`. Kết quả khi biên dịch từng module là gì?

`src/com.core/module-info.java`

```java
module com.core {
    exports com.core.api to com.friend;
}
```

`src/com.core/com/core/api/Api.java`

```java
package com.core.api;
public class Api { }
```

`src/com.friend/module-info.java`

```java
module com.friend { requires com.core; }
```

`src/com.friend/com/friend/F.java`

```java
package com.friend;
public class F { com.core.api.Api api; }
```

`src/com.other/module-info.java`

```java
module com.other { requires com.core; }
```

`src/com.other/com/other/O.java`

```java
package com.other;
public class O { com.core.api.Api api; }
```

- **A.** Cả hai biên dịch được
- **B.** `com.friend` lỗi, `com.other` được
- **C.** Cả hai đều lỗi
- **D.** `com.friend` được, `com.other` lỗi

#### Câu 07-16 · Vừa · objective 7.2

Mã nguồn module `com.x` nằm ở `src/com.x/` (gồm `module-info.java` và `com/x/Main.java`, in ra `hi`). Lệnh biên dịch nào (thay cho `<LỆNH>`) cho phép sau đó chạy `java -p out -m com.x/com.x.Main`? **(Chọn 2 đáp án.)**

- **A.** `javac -d out --module-source-path src -m com.x`
- **B.** `javac -d out --module-path src -m com.x`
- **C.** `javac -d out --module-source-path src com.x`
- **D.** `javac --module-source-path src -d out $(find src -name '*.java')`
- **E.** `javac -cp src -d out -m com.x`

#### Câu 07-17 · Vừa · objective 7.1

`mod.a` có `requires mod.b;` và `mod.b` có `requires mod.a;`. Chạy `javac -d out --module-source-path src -m mod.a,mod.b` thì sao?

`src/mod.a/module-info.java`

```java
module mod.a { requires mod.b; exports a; }
```

`src/mod.a/a/A.java`

```java
package a;
public class A { }
```

`src/mod.b/module-info.java`

```java
module mod.b { requires mod.a; exports b; }
```

`src/mod.b/b/B.java`

```java
package b;
public class B { }
```

- **A.** Biên dịch thành công
- **B.** Biên dịch thành công nhưng chạy báo `FindException`
- **C.** Chỉ biên dịch được khi thêm `--add-reads`
- **D.** Lỗi biên dịch: phụ thuộc vòng (cyclic dependence)

#### Câu 07-18 · Vừa · objective 7.1

Module `com.q` chỉ có `requires java.sql;` nhưng code của nó dùng `java.util.logging.Logger`. Điều gì xảy ra?

`src/com.q/module-info.java`

```java
module com.q {
    requires java.sql;
}
```

`src/com.q/com/q/Main.java`

```java
package com.q;
import java.util.logging.Logger;
public class Main {
    public static void main(String[] args) {
        System.out.println(Logger.getLogger("q").getName());
    }
}
```

- **A.** Biên dịch và chạy được, in ra `q`
- **B.** Lỗi biên dịch: package `java.util.logging` không nhìn thấy được
- **C.** Biên dịch được nhưng lỗi lúc chạy
- **D.** Chỉ biên dịch được khi thêm `--add-modules java.logging`

#### Câu 07-19 · Dễ · objective 7.1

Consumer `com.app` có `uses com.api.Greeter;`, nhưng khi chạy chỉ có `com.api` và `com.app` trên module path (không có provider nào). Chương trình in ra gì?

`src/com.api/module-info.java`

```java
module com.api { exports com.api; }
```

`src/com.api/com/api/Greeter.java`

```java
package com.api;
public interface Greeter { String greet(); }
```

`src/com.app/module-info.java`

```java
module com.app {
    requires com.api;
    uses com.api.Greeter;
}
```

`src/com.app/com/app/Main.java`

```java
package com.app;
import java.util.ServiceLoader;
public class Main {
    public static void main(String[] args) {
        var first = ServiceLoader.load(com.api.Greeter.class).findFirst();
        System.out.println(first.isPresent() ? first.get().greet() : "no provider");
    }
}
```

- **A.** Ném `ServiceConfigurationError`
- **B.** `no provider`
- **C.** Lỗi biên dịch vì không có module nào `provides` Greeter
- **D.** Ném `NullPointerException`

#### Câu 07-20 · Vừa · objective 7.2

Module `com.app` (lớp `com.app.Main` in ra `hi`) đã được biên dịch vào `out`. Lệnh nào (thay cho `<LỆNH>`) tạo được runtime image `image` sao cho `image/bin/java -m com.app/com.app.Main` chạy được? **(Chọn 2 đáp án.)**

- **A.** `jlink --module-path out --add-modules com.app --output image`
- **B.** `jlink -p out --add-modules com.app --output image`
- **C.** `jlink --module-path out --output image`
- **D.** `jlink -p out -m com.app --output image`
- **E.** `jar --create --file image -p out com.app`
<!-- /QUESTIONS -->

### Lời giải

<!-- ANSWERS:ch07 -->
#### Câu 07-01 — Đáp án: **B**

- **Vì sao đúng:** Module chỉ cho module khác dùng các package được `exports`. `com.lib.impl` không được export nên `com.app` không thể import nó, dù lớp `Impl` là `public` — đây là **đóng gói mạnh (strong encapsulation)**. Lỗi xảy ra ngay lúc biên dịch.
- **A sai:** `public` không còn đủ: package phải được `exports`.
- **C sai:** Hệ thống module kiểm tra ngay lúc biên dịch, không đợi tới lúc chạy.
- **D sai:** Code không biên dịch được nên không có bước chạy.
- *Kiểm chứng:* `examples/questions/ch07/Q07_01/` — script output confirmed (`python3 tools/book.py questions ch07`).

#### Câu 07-02 — Đáp án: **B**

- **Vì sao đúng:** `requires transitive com.base` tạo **implied readability**: module nào đọc `com.mid` cũng tự động đọc `com.base`. Vì vậy `com.top` dùng được `Money` mà không cần tự `requires com.base`.
- **A sai:** `requires` thường chỉ cho `com.mid` đọc `com.base`; `com.top` vẫn không đọc được → lỗi ở `com.top`.
- **C sai:** `requires static` là phụ thuộc chỉ lúc biên dịch của riêng `com.mid`, không truyền sang `com.top`.
- **D sai:** `exports` nhận tên **package** thuộc chính module; `com.mid` không chứa package `com.base` → lỗi.
- *Kiểm chứng:* `examples/questions/ch07/Q07_02/` — script variants: B in ra 'OK' (`python3 tools/book.py questions ch07`).

#### Câu 07-03 — Đáp án: **A, D**

- **Vì sao đúng:** A: `java.base` được requires ngầm (hiện là `requires java.base mandated`). D: tên module theo quy tắc giống tên package, dấu chấm là bình thường (thường dùng tên "reverse DNS").
- **B sai:** Một package chỉ được thuộc **một** module (cấm "split package"): ở đây javac chưa bắt lỗi (package không được export), nhưng JVM từ chối khởi động với `LayerInstantiationException`.
- **C sai:** `exports` chỉ mở các kiểu public lúc biên dịch/chạy; reflection vào `private` cần `opens` → `InaccessibleObjectException`.
- **E sai:** `module-info.java` không thuộc package nào; khai báo `package` là lỗi biên dịch.
- *Kiểm chứng:* `examples/questions/ch07/Q07_03/` — each option proven true/false by a program (`python3 tools/book.py questions ch07`).

#### Câu 07-04 — Đáp án: **C**

- **Vì sao đúng:** `opens m.model` cho phép **deep reflection** (kể cả `private`) lúc chạy, nên `setAccessible(true)` thành công và đọc được giá trị `prod`. Một package có thể vừa `exports` (dùng lúc biên dịch) vừa `opens` (reflection).
- **A sai:** Field được khởi tạo `"prod"` khi tạo object; reflection đọc đúng giá trị đó.
- **B sai:** Exception này chỉ xảy ra khi package **không** được `opens`.
- **D sai:** `exports` và `opens` cùng một package là hợp lệ.
- *Kiểm chứng:* `examples/questions/ch07/Q07_04/` — script output confirmed (`python3 tools/book.py questions ch07`).

#### Câu 07-05 — Đáp án: **A**

- **Vì sao đúng:** Provider đăng ký cài đặt bằng `provides <service interface> with <lớp cài đặt>;`. Consumer (`com.app`) đã có `uses com.api.Greeter;`, nên `ServiceLoader` tìm thấy `Hi`. Lớp cài đặt **không** cần được export.
- **B sai:** `exports` chỉ làm package nhìn thấy được; không đăng ký service nào → `providers=0`.
- **C sai:** `uses` là việc của consumer; provider không đăng ký gì → `providers=0`.
- **D sai:** Đảo ngược thứ tự: phải là `provides Interface with Implementation` → lỗi biên dịch.
- *Kiểm chứng:* `examples/questions/ch07/Q07_05/` — script variants: A in ra 'providers=1' (`python3 tools/book.py questions ch07`).

#### Câu 07-06 — Đáp án: **C**

- **Vì sao đúng:** Code trong một **named module** chỉ được tải service mà module đó đã khai báo bằng `uses`. Compiler không kiểm tra điều này (lời gọi `ServiceLoader.load` là code bình thường), nên lỗi xảy ra lúc chạy: `ServiceConfigurationError` ("module com.app does not declare `uses`").
- **A sai:** Không có `uses` thì `ServiceLoader` không trả về rỗng mà ném lỗi.
- **B sai:** javac không bắt lỗi này; nó chỉ xảy ra lúc chạy.
- **D sai:** Không có provider nào, và thiếu `uses` còn gây lỗi.
- *Kiểm chứng:* `examples/questions/ch07/Q07_06/` — script output confirmed (`python3 tools/book.py questions ch07`).

#### Câu 07-07 — Đáp án: **B**

- **Vì sao đúng:** Tên automatic module suy ra từ tên file: bỏ `.jar`, bỏ phần phiên bản (`-2.0.1`), rồi thay ký tự không phải chữ/số (như `-`) bằng dấu chấm → `my.utils` (phiên bản 2.0.1). Nếu MANIFEST có `Automatic-Module-Name` thì dùng tên đó.
- **A sai:** Dấu `-` không hợp lệ trong tên module, nên được thay bằng `.`.
- **C sai:** Phần phiên bản ở cuối tên file bị tách ra thành version, không nằm trong tên.
- **D sai:** Ký tự không phải chữ/số được thay bằng dấu chấm, không bị xoá.
- *Kiểm chứng:* `examples/questions/ch07/Q07_07/` — script output confirmed (`python3 tools/book.py questions ch07`).

#### Câu 07-08 — Đáp án: **D**

- **Vì sao đúng:** Code trên classpath thuộc **unnamed module**: `isNamed()` là `false`, `getName()` là `null`. Unnamed module đọc được (reads) mọi module trong boot layer, nên đọc được `java.sql`.
- **A sai:** Classpath không tạo named module.
- **B sai:** Unnamed module đọc được mọi module, kể cả `java.sql`.
- **C sai:** Tên của unnamed module là `null`, không phải chuỗi `"unnamed"`.
- *Kiểm chứng:* `examples/questions/ch07/Q07_08/` — script output confirmed (`python3 tools/book.py questions ch07`).

#### Câu 07-09 — Đáp án: **A, B**

- **Vì sao đúng:** `-p` là dạng ngắn của `--module-path`, `-m` là dạng ngắn của `--module`; tham số của `-m` là `tênModule/tênLớp`.
- **C sai:** `-cp` đặt `mods` vào classpath; module `com.x` không được tìm trên module path → lỗi khởi động.
- **D sai:** Thiếu `-m`: `com.x.Main` được tìm trên classpath (không có) → không chạy được.
- **E sai:** Thư mục module phải đưa bằng `-p`; `-m` chỉ nhận `module/lớp`.
- *Kiểm chứng:* `examples/questions/ch07/Q07_09/` — script variants: AB in ra 'hi' (`python3 tools/book.py questions ch07`).

#### Câu 07-10 — Đáp án: **C**

- **Vì sao đúng:** jlink thêm module gốc và **toàn bộ phụ thuộc bắc cầu** của nó: `java.base` (luôn có), `java.sql`, và các module mà `java.sql` `requires transitive`: `java.logging`, `java.transaction.xa`, `java.xml`. Không thêm gì khác.
- **A sai:** Runtime image luôn cần `java.base` và các module được requires.
- **B sai:** Thiếu `java.sql` và các phụ thuộc của nó.
- **D sai:** Mục đích của jlink là tạo image **nhỏ**, chỉ gồm module cần thiết.
- *Kiểm chứng:* `examples/questions/ch07/Q07_10/` — script output confirmed (`python3 tools/book.py questions ch07`).

#### Câu 07-11 — Đáp án: **C, E**

- **Vì sao đúng:** Các directive hợp lệ: `requires` (kèm `transitive`/`static`), `exports` (có thể `to` module cụ thể), `opens` (có thể `to`), `uses`, `provides ... with`. Không có directive `imports`, và `requires public` không tồn tại (đúng là `requires transitive`).
- **A sai:** `requires java.sql;` là hợp lệ.
- **B sai:** Qualified export `exports ... to <module>` là hợp lệ.
- **D sai:** `opens` một package của chính module là hợp lệ.
- *Kiểm chứng:* `examples/questions/ch07/Q07_11/` — script variants: CE in ra 'FAIL' (`python3 tools/book.py questions ch07`).

#### Câu 07-12 — Đáp án: **B, E**

- **Vì sao đúng:** `open module` đã mở **mọi** package cho reflection, nên viết thêm `opens` bên trong là lỗi (B). `exports` một package rỗng hoặc không tồn tại là lỗi (E).
- **A sai:** `open module` vẫn có thể `exports` package.
- **C sai:** Một package vừa `opens` vừa `exports` là hợp lệ.
- **D sai:** Qualified opens `opens ... to <module>` là hợp lệ.
- *Kiểm chứng:* `examples/questions/ch07/Q07_12/` — script variants: BE in ra 'FAIL' (`python3 tools/book.py questions ch07`).

#### Câu 07-13 — Đáp án: **A, C**

- **Vì sao đúng:** A: unnamed module đọc mọi module và thấy mọi package được export. C: automatic module export (và open) mọi package trong JAR, nên module khác dùng được cả `org.a` lẫn `org.b`.
- **B sai:** Named module không đọc unnamed module (không có tên để `requires`) → `package org.cp does not exist`.
- **D sai:** Trên classpath, `module-info.class` bị bỏ qua: mọi lớp thuộc unnamed module → `isNamed()` là `false`.
- **E sai:** Tên được chuẩn hoá: `my-lib-1.0.jar` → `my.lib` (version 1.0).
- *Kiểm chứng:* `examples/questions/ch07/Q07_13/` — each option proven true/false by a program (`python3 tools/book.py questions ch07`).

#### Câu 07-14 — Đáp án: **A**

- **Vì sao đúng:** `--print-module-deps` in danh sách module **tối thiểu** (cách nhau dấu phẩy), dùng được cho `jlink --add-modules`. `java.logging` không cần ghi vì `java.sql` đã `requires transitive java.logging`.
- **B sai:** Danh sách luôn có `java.base`; và `java.logging` được suy ra từ `java.sql`.
- **C sai:** Đây là kiểu output của `--list-deps`; `--print-module-deps` rút gọn các module đã được kéo theo bắc cầu.
- **D sai:** Đó là dạng output của `jdeps -summary`.
- *Kiểm chứng:* `examples/questions/ch07/Q07_14/` — script output confirmed (`python3 tools/book.py questions ch07`).

#### Câu 07-15 — Đáp án: **D**

- **Vì sao đúng:** **Qualified export** `exports <package> to <module>` chỉ mở package cho các module được liệt kê. `com.other` không có trong danh sách nên không thấy `com.core.api`.
- **A sai:** `to com.friend` giới hạn chỉ `com.friend` được dùng package.
- **B sai:** Ngược lại: chỉ module được nêu tên sau `to` mới dùng được.
- **C sai:** `com.friend` được phép vì có tên trong qualified export.
- *Kiểm chứng:* `examples/questions/ch07/Q07_15/` — script output confirmed (`python3 tools/book.py questions ch07`).

#### Câu 07-16 — Đáp án: **A, D**

- **Vì sao đúng:** Với chế độ nhiều module, `--module-source-path src` cho javac biết mỗi thư mục con của `src` là một module; có thể chọn module bằng `-m com.x` (A) hoặc liệt kê các file nguồn (D). Kết quả nằm ở `out/com.x/`.
- **B sai:** `--module-path` dành cho module **đã biên dịch**, không phải mã nguồn; `-m` cần `--module-source-path`.
- **C sai:** Không có `-m`, `com.x` bị hiểu là tên file nguồn → lỗi.
- **E sai:** `-m` (module) cần `--module-source-path`; `-cp` không thay thế được.
- *Kiểm chứng:* `examples/questions/ch07/Q07_16/` — script variants: AD in ra 'hi' (`python3 tools/book.py questions ch07`).

#### Câu 07-17 — Đáp án: **D**

- **Vì sao đúng:** Đồ thị phụ thuộc giữa các module **không được có vòng** (lúc biên dịch). javac báo "cyclic dependence involving mod.a". Cách sửa thường gặp: tách phần dùng chung ra module thứ ba.
- **A sai:** Hệ thống module cấm vòng `requires`.
- **B sai:** Lỗi được phát hiện ngay lúc biên dịch.
- **C sai:** Không có tùy chọn nào làm vòng `requires` hợp lệ khi biên dịch.
- *Kiểm chứng:* `examples/questions/ch07/Q07_17/` — script output confirmed (`python3 tools/book.py questions ch07`).

#### Câu 07-18 — Đáp án: **A**

- **Vì sao đúng:** `java.sql` khai báo `requires transitive java.logging`, nên module nào `requires java.sql` cũng đọc được `java.logging` (implied readability).
- **B sai:** Nhờ `requires transitive` trong `java.sql`, `com.q` đọc được `java.logging`.
- **C sai:** Readability được giải quyết giống nhau lúc biên dịch và lúc chạy; không có lỗi.
- **D sai:** Không cần tùy chọn thêm.
- *Kiểm chứng:* `examples/questions/ch07/Q07_18/` — script output confirmed (`python3 tools/book.py questions ch07`).

#### Câu 07-19 — Đáp án: **B**

- **Vì sao đúng:** `uses` chỉ khai báo ý định dùng service. Không có provider thì `ServiceLoader` đơn giản là không tìm thấy gì: `findFirst()` trả về `Optional` rỗng. Provider có thể được thêm lúc chạy mà không cần biên dịch lại consumer.
- **A sai:** Lỗi này chỉ xảy ra khi **thiếu `uses`**, không phải khi thiếu provider.
- **C sai:** Consumer không phụ thuộc lúc biên dịch vào provider nào.
- **D sai:** `findFirst()` trả về `Optional`, không trả về `null`.
- *Kiểm chứng:* `examples/questions/ch07/Q07_19/` — script output confirmed (`python3 tools/book.py questions ch07`).

#### Câu 07-20 — Đáp án: **A, B**

- **Vì sao đúng:** jlink cần: nơi tìm module (`--module-path`/`-p`), module gốc (`--add-modules`) và thư mục đích (`--output`).
- **C sai:** Thiếu `--add-modules`: jlink không biết đưa module nào vào → lỗi.
- **D sai:** jlink không có tùy chọn `-m` để chọn module gốc; phải dùng `--add-modules`.
- **E sai:** `jar` tạo file JAR, không tạo runtime image.
- *Kiểm chứng:* `examples/questions/ch07/Q07_20/` — script variants: AB in ra 'hi' (`python3 tools/book.py questions ch07`).
<!-- /ANSWERS -->

## Đọc thêm (link chính thức — bị chặn trong sandbox nên mình chưa mở được)

- JLS §7.7 Module Declarations: https://docs.oracle.com/javase/specs/jls/se21/html/jls-7.html
- JEP 261 Module System: https://openjdk.org/jeps/261
- Hướng dẫn công cụ `jlink`, `jdeps`, `jar`: https://docs.oracle.com/en/java/javase/21/docs/specs/man/index.html

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:

- `ModuleFinder.java` (quy tắc tên automatic module, `Automatic-Module-Name`): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/lang/module/ModuleFinder.java
- `ServiceLoader.java` (yêu cầu `uses`, provider constructor / `provider()` method): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/util/ServiceLoader.java
- `module-info.java` của `java.sql` (các `requires transitive`): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.sql/share/classes/module-info.java
- Mọi lệnh trong chương đều được chạy thật bằng JDK 21.0.10 (xem output ở trên).
