# Chương 3 — Hướng đối tượng (Using Object-Oriented Concepts in Java)

## Mục tiêu

Đây là nhóm mục tiêu **lớn nhất** của đề 1Z0-830 (7 objective). Sau chương này bạn làm được:

- 3.1 Tạo object, dùng lớp lồng nhau (nested class), hiểu vòng đời object và thu gom rác (garbage collection, GC).
- 3.2 Viết class và **record**: field/method static và instance, constructor, khối khởi tạo (initializer), thứ tự khởi tạo.
- 3.3 Nạp chồng method (overloading), kể cả varargs.
- 3.4 Phạm vi biến (scope), đóng gói (encapsulation), lớp bất biến (immutable), `var`.
- 3.5 Kế thừa (inheritance), lớp `abstract` và `sealed`, ghi đè (override) kể cả method của `Object`, đa hình
  (polymorphism), ép kiểu tham chiếu, `instanceof` và pattern matching.
- 3.6 Interface: method `default`, `static`, `private`; functional interface.
- 3.7 Enum có field, constructor, method.

## Giải thích đơn giản

**Class** là bản thiết kế; **object** là "ngôi nhà" xây từ bản thiết kế đó bằng `new`. Biến kiểu class chỉ giữ
**địa chỉ** (tham chiếu) của object. Khi không còn biến nào trỏ tới một object, object đó "đủ điều kiện" bị GC dọn.

**Kế thừa** (`extends`) cho lớp con dùng lại code của lớp cha. **Đa hình**: biến kiểu cha có thể trỏ tới object
kiểu con, và khi gọi method **instance**, Java chọn bản của **object thật** (lúc chạy). Nhưng field và method
**static** thì chọn theo **kiểu của biến** (lúc biên dịch). Đây là bẫy số 1 của chương.

**Record** là class dữ liệu ngắn gọn: `record Point(int x, int y) {}` tự sinh constructor, accessor `x()`, `equals`,
`hashCode`, `toString`. **Sealed** giới hạn ai được kế thừa. **Enum** là tập hằng số cố định nhưng vẫn là class đầy đủ.

## Ví dụ

Code trong `examples/ch03/`. Chạy lại: `python3 tools/book.py examples ch03`. Output thật, JDK 21.0.10.

### 1. Vòng đời object và GC

<!-- EX:Ex01_Lifecycle -->
`examples/ch03/Ex01_Lifecycle.java`

```java
// objective: 3.1
// Vòng đời object: tạo bằng new, gán lại tham chiếu, và khi nào object "đủ điều kiện" bị GC.
public class Ex01_Lifecycle {
    static int created = 0;
    final String name;

    Ex01_Lifecycle(String name) {
        this.name = name;
        created++;
    }

    public static void main(String[] args) {
        Ex01_Lifecycle a = new Ex01_Lifecycle("A");   // object A
        Ex01_Lifecycle b = new Ex01_Lifecycle("B");   // object B
        Ex01_Lifecycle c = a;                          // c và a cùng trỏ A (không tạo object mới)
        System.out.println("created=" + created + " a==c? " + (a == c));

        a = b;          // A vẫn còn tham chiếu c
        c = null;       // bây giờ không còn tham chiếu nào tới A → A đủ điều kiện GC (eligible)
        System.out.println("a=" + a.name + " b=" + b.name + " c=" + c);

        new Ex01_Lifecycle("C");                       // tạo ra rồi bỏ ngay → đủ điều kiện GC
        System.out.println("created=" + created);
        System.gc();    // chỉ là "gợi ý"; JVM không bảo đảm sẽ chạy GC
        // Không có cách chắc chắn để biết lúc nào object bị thu hồi; finalize() đã deprecated.
    }
}
```

Output thật (JDK 21.0.10):

```text
created=2 a==c? true
a=B b=B c=null
created=3
```
<!-- /EX -->

### 2. Bốn loại lớp lồng nhau

<!-- EX:Ex02_NestedClasses -->
`examples/ch03/Ex02_NestedClasses.java`

```java
// objective: 3.1
// 4 loại lớp lồng nhau: static nested, inner (member), local, anonymous.
public class Ex02_NestedClasses {
    private int value = 10;
    private static int counter = 1;

    static class StaticNested {                 // không cần object bên ngoài
        int read() { return counter; }          // chỉ truy cập được thành viên static của lớp ngoài
    }

    class Inner {                               // gắn với một object của lớp ngoài
        int value = 20;
        int read() { return value + Ex02_NestedClasses.this.value; }   // 20 + 10
    }

    interface Greeter { String greet(String n); }

    Greeter make(String prefix) {
        int local = 1;                          // effectively final → local/anonymous class dùng được
        class LocalGreeter implements Greeter {
            public String greet(String n) { return prefix + n + local; }
        }
        return new LocalGreeter();
    }

    public static void main(String[] args) {
        StaticNested sn = new StaticNested();
        Ex02_NestedClasses outer = new Ex02_NestedClasses();
        Ex02_NestedClasses.Inner in = outer.new Inner();   // cú pháp đặc biệt: outer.new Inner()
        System.out.println(sn.read() + " " + in.read());

        Greeter anon = new Greeter() {                     // anonymous class
            @Override public String greet(String n) { return "Hi " + n; }
        };
        System.out.println(anon.greet("Nobin") + " | " + outer.make("Yo ").greet("Java"));
        System.out.println(in.getClass().getName() + " " + anon.getClass().getName());
    }
}
```

Output thật (JDK 21.0.10):

```text
1 30
Hi Nobin | Yo Java1
Ex02_NestedClasses$Inner Ex02_NestedClasses$1
```
<!-- /EX -->

### 3. Thứ tự khởi tạo

<!-- EX:Ex03_InitOrder -->
`examples/ch03/Ex03_InitOrder.java`

```java
// objective: 3.2
// Thứ tự khởi tạo: static (cha → con) một lần, rồi mỗi object: field/instance initializer → constructor, cha trước con.
class Parent {
    static { System.out.println("1. Parent static block"); }
    int p = log("3. Parent field");
    { System.out.println("4. Parent instance block"); }
    Parent() { System.out.println("5. Parent constructor"); }
    static int log(String s) { System.out.println(s); return 0; }
}

class Child extends Parent {
    static { System.out.println("2. Child static block"); }
    int c = log("6. Child field");
    { System.out.println("7. Child instance block"); }
    Child() {
        super();                    // luôn là lệnh đầu tiên (thêm ngầm nếu không viết)
        System.out.println("8. Child constructor");
    }
    Child(String s) {
        this();                     // gọi constructor khác trong cùng lớp
        System.out.println("9. Child(String) " + s);
    }
}

public class Ex03_InitOrder {
    public static void main(String[] args) {
        new Child("x");
        System.out.println("--- object thứ hai: không chạy lại static");
        new Child();
    }
}
```

Output thật (JDK 21.0.10):

```text
1. Parent static block
2. Child static block
3. Parent field
4. Parent instance block
5. Parent constructor
6. Child field
7. Child instance block
8. Child constructor
9. Child(String) x
--- object thứ hai: không chạy lại static
3. Parent field
4. Parent instance block
5. Parent constructor
6. Child field
7. Child instance block
8. Child constructor
```
<!-- /EX -->

### 4. Record

<!-- EX:Ex04_Records -->
`examples/ch03/Ex04_Records.java`

```java
// objective: 3.2, 3.5
// Record: lớp dữ liệu bất biến; compact constructor; accessor x() thay vì getX().
import java.util.List;

public class Ex04_Records {
    record Money(long amount, String currency) {
        static final String DEFAULT = "VND";            // field static: được phép
        // long cents;                                  // field instance: KHÔNG được phép

        Money {                                          // compact constructor: không có tham số, không gán this.x
            if (amount < 0) throw new IllegalArgumentException("amount < 0");
            currency = currency.toUpperCase();          // gán lại THAM SỐ trước khi field được gán
        }

        Money(long amount) { this(amount, DEFAULT); }   // constructor khác phải gọi this(...)

        Money plus(Money o) { return new Money(amount + o.amount, currency); }

        @Override public String toString() { return amount + " " + currency; }
    }

    record Team(String name, List<String> members) {
        Team {
            members = List.copyOf(members);             // bản sao bất biến: record chỉ "nông" (shallow) immutable
        }
    }

    public static void main(String[] args) {
        Money a = new Money(1000, "usd");
        Money b = new Money(1000, "USD");
        System.out.println(a + " | " + a.amount() + " | equals=" + a.equals(b) + " | sameHash=" + (a.hashCode() == b.hashCode()));
        System.out.println(new Money(5).plus(new Money(7)));
        try {
            new Money(-1, "x");
        } catch (IllegalArgumentException e) {
            System.out.println("IllegalArgumentException: " + e.getMessage());
        }
        var list = new java.util.ArrayList<>(List.of("An"));
        Team t = new Team("dev", list);
        list.add("Binh");
        System.out.println(t + " " + (t instanceof Record));
    }
}
```

Output thật (JDK 21.0.10):

```text
1000 USD | 1000 | equals=true | sameHash=true
12 VND
IllegalArgumentException: amount < 0
Team[name=dev, members=[An]] true
```
<!-- /EX -->

### 5. Overloading

<!-- EX:Ex05_Overloading -->
`examples/ch03/Ex05_Overloading.java`

```java
// objective: 3.3
// Chọn method overload: đúng kiểu > nới rộng (widening) > boxing > varargs.
public class Ex05_Overloading {
    static void m(long x)     { System.out.println("long"); }
    static void m(Integer x)  { System.out.println("Integer"); }
    static void m(int... x)   { System.out.println("int..."); }
    static void m(Object x)   { System.out.println("Object"); }

    static void s(String x)   { System.out.println("String"); }
    static void s(Object x)   { System.out.println("Object"); }

    static int sum(int... nums) {             // varargs là một mảng
        int t = 0;
        for (int n : nums) t += n;
        return t;
    }

    public static void main(String[] args) {
        int i = 5;
        m(i);            // widening int → long thắng boxing
        m(Integer.valueOf(5));
        m();             // chỉ varargs khớp
        m(5, 6);
        m("text");       // String → Object
        byte b = 1;
        m(b);            // byte → long (widening)
        char c = 'x';
        m(c);            // char → long

        s(null);         // chọn kiểu CỤ THỂ nhất: String
        s((Object) "a");

        System.out.println(sum() + " " + sum(1, 2, 3) + " " + sum(new int[]{4, 5}));
    }
}
```

Output thật (JDK 21.0.10):

```text
long
Integer
int...
int...
Object
long
long
String
Object
0 6 9
```
<!-- /EX -->

### 6. Scope, shadowing và `var`

<!-- EX:Ex06_ScopeAndVar -->
`examples/ch03/Ex06_ScopeAndVar.java`

```java
// objective: 3.4
// Phạm vi biến (scope), shadowing, và var (local variable type inference).
import java.util.ArrayList;

public class Ex06_ScopeAndVar {
    int count = 100;                           // instance field

    void show(int count) {                     // tham số che (shadow) field cùng tên
        System.out.println("param=" + count + " field=" + this.count);
        {
            int inner = count * 2;             // chỉ sống trong khối
            System.out.println("inner=" + inner);
        }
        // System.out.println(inner);          // lỗi: ngoài phạm vi
    }

    public static void main(String[] args) {
        new Ex06_ScopeAndVar().show(7);

        var n = 10;                             // int
        var list = new ArrayList<String>();     // ArrayList<String>
        list.add("a");
        var mixed = new ArrayList<>();          // ArrayList<Object> (không có thông tin kiểu)
        mixed.add(1);
        mixed.add("x");
        for (var s : list) System.out.println("for-each var: " + s);
        var arr = new int[]{1, 2};
        System.out.println(n + " " + list + " " + mixed + " " + arr.length);
        // var a;            // lỗi: phải khởi tạo
        // var b = null;     // lỗi: không suy ra được kiểu
        // var c = 1, d = 2; // lỗi: không khai báo nhiều biến
        // var e = {1, 2};   // lỗi: array initializer cần kiểu rõ ràng
        var var = "var là 'reserved type name', không phải keyword → đặt tên biến được";
        System.out.println(var);
    }
}
```

Output thật (JDK 21.0.10):

```text
param=7 field=100
inner=14
for-each var: a
10 [a] [1, x] 2
var là 'reserved type name', không phải keyword → đặt tên biến được
```
<!-- /EX -->

### 7. Lớp bất biến

<!-- EX:Ex07_Immutable -->
`examples/ch03/Ex07_Immutable.java`

```java
// objective: 3.4
// Tạo lớp bất biến (immutable) và đóng gói (encapsulation) với defensive copy.
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class Ex07_Immutable {
    static final class Order {                    // final: không cho lớp con phá vỡ bất biến
        private final String id;                  // private final
        private final List<String> items;

        Order(String id, List<String> items) {
            this.id = id;
            this.items = new ArrayList<>(items);  // copy khi nhận vào
        }

        String getId() { return id; }
        List<String> getItems() { return Collections.unmodifiableList(items); }  // không trả ra list gốc
        Order withItem(String item) {             // "thay đổi" = tạo object mới
            List<String> copy = new ArrayList<>(items);
            copy.add(item);
            return new Order(id, copy);
        }
    }

    public static void main(String[] args) {
        List<String> src = new ArrayList<>(List.of("pen"));
        Order o = new Order("O1", src);
        src.add("hack");                          // không ảnh hưởng o
        Order o2 = o.withItem("book");
        System.out.println(o.getItems() + " " + o2.getItems());
        try {
            o.getItems().add("x");
        } catch (UnsupportedOperationException e) {
            System.out.println("UnsupportedOperationException: không sửa được từ bên ngoài");
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
[pen] [pen, book]
UnsupportedOperationException: không sửa được từ bên ngoài
```
<!-- /EX -->

### 8. Đa hình: override vs hiding

<!-- EX:Ex08_Polymorphism -->
`examples/ch03/Ex08_Polymorphism.java`

```java
// objective: 3.5
// Override vs hiding: method instance chọn theo KIỂU OBJECT (lúc chạy);
// field và method static chọn theo KIỂU THAM CHIẾU (lúc biên dịch).
class Animal {
    String name = "animal";
    static String kind() { return "Animal.kind"; }
    String sound() { return "..."; }
    String describe() { return name + " says " + sound(); }   // sound() là lời gọi đa hình
}

class Dog extends Animal {
    String name = "dog";                            // che (hide) field của cha
    static String kind() { return "Dog.kind"; }     // che method static (không phải override)
    @Override String sound() { return "Woof"; }
    String fetch() { return "fetching"; }
}

public class Ex08_Polymorphism {
    public static void main(String[] args) {
        Animal a = new Dog();                       // kiểu tham chiếu Animal, kiểu object Dog
        System.out.println(a.sound());              // Woof  (override → theo object)
        System.out.println(a.name);                 // animal (field → theo tham chiếu)
        System.out.println(a.kind());               // Animal.kind (static → theo tham chiếu)
        System.out.println(a.describe());           // "animal says Woof"
        // a.fetch();                               // lỗi: Animal không có fetch()
        System.out.println(((Dog) a).fetch() + " " + ((Dog) a).name);
    }
}
```

Output thật (JDK 21.0.10):

```text
Woof
animal
Animal.kind
animal says Woof
fetching dog
```
<!-- /EX -->

### 9. Abstract và sealed

<!-- EX:Ex09_AbstractSealed -->
`examples/ch03/Ex09_AbstractSealed.java`

```java
// objective: 3.5
// Lớp abstract và sealed: permits, final / sealed / non-sealed ở lớp con.
public class Ex09_AbstractSealed {
    static abstract sealed class Vehicle permits Car, Truck, Bike {
        abstract int wheels();
        String info() { return getClass().getSimpleName() + " has " + wheels() + " wheels"; }
    }
    static final class Car extends Vehicle { int wheels() { return 4; } }
    static sealed class Truck extends Vehicle permits BigTruck { int wheels() { return 6; } }
    static final class BigTruck extends Truck { @Override int wheels() { return 18; } }
    static non-sealed class Bike extends Vehicle { int wheels() { return 2; } }
    static class EBike extends Bike { }                 // non-sealed mở lại cho mọi lớp con

    static String tax(Vehicle v) {
        return switch (v) {                              // sealed → switch đầy đủ không cần default
            case Car c -> "low";
            case Truck t -> "high";
            case Bike b -> "none";
        };
    }

    public static void main(String[] args) {
        Vehicle[] all = {new Car(), new Truck(), new BigTruck(), new Bike(), new EBike()};
        for (Vehicle v : all) System.out.println(v.info() + " / tax " + tax(v));
        // new Vehicle();   // lỗi: abstract
        System.out.println(Vehicle.class.isSealed() + " " + java.util.Arrays.toString(
                java.util.Arrays.stream(Vehicle.class.getPermittedSubclasses()).map(Class::getSimpleName).toArray()));
    }
}
```

Output thật (JDK 21.0.10):

```text
Car has 4 wheels / tax low
Truck has 6 wheels / tax high
BigTruck has 18 wheels / tax high
Bike has 2 wheels / tax none
EBike has 2 wheels / tax none
true [Car, Truck, Bike]
```
<!-- /EX -->

### 10. Ép kiểu tham chiếu

<!-- EX:Ex10_Casting -->
`examples/ch03/Ex10_Casting.java`

```java
// objective: 3.5
// Ép kiểu tham chiếu: upcast tự động, downcast cần cast và có thể ném ClassCastException.
public class Ex10_Casting {
    interface Swimmer {}
    static class Fish implements Swimmer {}
    static class Shark extends Fish {}
    static final class Rock {}

    public static void main(String[] args) {
        Fish f = new Shark();                 // upcast: không cần cast
        Shark s = (Shark) f;                  // downcast: OK vì object thật là Shark
        Object o = new Fish();
        System.out.println((o instanceof Shark) + " " + (o instanceof Swimmer) + " " + (null instanceof Object));
        try {
            Shark bad = (Shark) o;            // biên dịch được, nhưng lúc chạy object là Fish
        } catch (ClassCastException e) {
            System.out.println("ClassCastException");
        }
        Swimmer sw = (Swimmer) new Object[]{f}[0];   // cast sang interface: compiler thường cho phép
        System.out.println(sw.getClass().getSimpleName());
        // Rock r = (Rock) f;                 // lỗi biên dịch: Fish và Rock không liên quan
        // Swimmer x = (Swimmer) new Rock();  // lỗi biên dịch: Rock là final và không implements Swimmer
        if (f instanceof Shark sh && sh != null) System.out.println("pattern: " + sh.getClass().getSimpleName());
    }
}
```

Output thật (JDK 21.0.10):

```text
false true false
ClassCastException
Shark
pattern: Shark
```
<!-- /EX -->

### 11. equals / hashCode / toString

<!-- EX:Ex11_ObjectMethods -->
`examples/ch03/Ex11_ObjectMethods.java`

```java
// objective: 3.5
// Override equals/hashCode/toString của Object; ảnh hưởng tới HashSet.
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

public class Ex11_ObjectMethods {
    static class NoOverride { int id; NoOverride(int id) { this.id = id; } }

    static class User {
        final int id;
        User(int id) { this.id = id; }
        @Override public boolean equals(Object o) {
            return o instanceof User u && u.id == id;
        }
        @Override public int hashCode() { return Objects.hash(id); }
        @Override public String toString() { return "User#" + id; }
    }

    static class BadEquals {
        int id;
        BadEquals(int id) { this.id = id; }
        public boolean equals(BadEquals o) { return o.id == id; }   // OVERLOAD, không phải override!
    }

    public static void main(String[] args) {
        Set<Object> set = new HashSet<>();
        set.add(new NoOverride(1)); set.add(new NoOverride(1));
        set.add(new User(1)); set.add(new User(1));
        System.out.println("size=" + set.size());
        System.out.println(new User(7) + " " + new User(7).equals(new User(7)));
        Object x = new BadEquals(1);
        System.out.println(new BadEquals(1).equals(new BadEquals(1)) + " " + x.equals(new BadEquals(1)));
        String s = new NoOverride(3).toString();
        System.out.println(s.startsWith("Ex11_ObjectMethods$NoOverride@"));
    }
}
```

Output thật (JDK 21.0.10):

```text
size=3
User#7 true
true false
true
```
<!-- /EX -->

### 12. Interface: default, static, private

<!-- EX:Ex12_Interfaces -->
`examples/ch03/Ex12_Interfaces.java`

```java
// objective: 3.6
// Interface: method abstract, default, static, private; xung đột default giữa hai interface.
public class Ex12_Interfaces {
    interface Walker {
        int SPEED = 5;                              // ngầm public static final
        default String move() { return "walk " + helper(); }
        private String helper() { return "at " + SPEED; }   // private: chỉ dùng bên trong interface
        static String info() { return "Walker.info"; }       // static: gọi qua tên interface
    }

    interface Swimmer {
        default String move() { return "swim"; }
    }

    static class Duck implements Walker, Swimmer {
        @Override public String move() {                     // BẮT BUỘC override khi hai default trùng
            return Walker.super.move() + " & " + Swimmer.super.move();
        }
    }

    static class Robot implements Walker { }                 // dùng default có sẵn

    public static void main(String[] args) {
        System.out.println(new Duck().move());
        System.out.println(new Robot().move());
        System.out.println(Walker.info() + " " + Walker.SPEED);
        // new Robot().info();     // lỗi: static method của interface không được kế thừa
    }
}
```

Output thật (JDK 21.0.10):

```text
walk at 5 & swim
walk at 5
Walker.info 5
```
<!-- /EX -->

### 13. Functional interface

<!-- EX:Ex13_FunctionalInterface -->
`examples/ch03/Ex13_FunctionalInterface.java`

```java
// objective: 3.6
// Functional interface: đúng MỘT method abstract (không tính default, static, và method public của Object).
import java.util.function.Function;

public class Ex13_FunctionalInterface {
    @FunctionalInterface
    interface Calculator {
        int apply(int a, int b);                     // method abstract duy nhất
        default Calculator twice() { return (a, b) -> apply(apply(a, b), b); }
        static Calculator plus() { return (a, b) -> a + b; }
        boolean equals(Object o);                    // method của Object: không tính
        String toString();                           // không tính
    }

    interface NotFunctional { void a(); void b(); }  // hai method abstract → không dùng được với lambda

    public static void main(String[] args) {
        Calculator mul = (a, b) -> a * b;
        System.out.println(mul.apply(3, 4) + " " + Calculator.plus().twice().apply(1, 10));
        Function<String, Integer> len = String::length;
        System.out.println(len.apply("lambda"));
        // NotFunctional nf = () -> {};              // lỗi: không phải functional interface
    }
}
```

Output thật (JDK 21.0.10):

```text
12 21
6
```
<!-- /EX -->

### 14. Enum

<!-- EX:Ex14_Enums -->
`examples/ch03/Ex14_Enums.java`

```java
// objective: 3.7
// Enum có field, constructor (luôn private), method, và method riêng cho từng hằng số.
public class Ex14_Enums {
    enum Planet {
        MERCURY(3.7), EARTH(9.8) {
            @Override String note() { return "home"; }       // thân riêng của hằng số
        }, MARS(3.7);

        private final double gravity;
        Planet(double gravity) {                             // constructor enum ngầm private
            this.gravity = gravity;
            System.out.println("init " + name());            // chạy khi enum được nạp lần đầu
        }
        double weight(double mass) { return mass * gravity; }
        String note() { return "-"; }
    }

    enum Op {
        ADD { int apply(int a, int b) { return a + b; } },
        SUB { int apply(int a, int b) { return a - b; } };
        abstract int apply(int a, int b);                    // mỗi hằng số phải cài đặt
    }

    public static void main(String[] args) {
        System.out.println("start");
        Planet p = Planet.valueOf("EARTH");
        System.out.println(p + " " + p.ordinal() + " " + p.weight(10) + " " + p.note() + " " + Planet.MARS.note());
        System.out.println(Planet.values().length + " " + (Planet.MARS.compareTo(Planet.EARTH) > 0));
        for (Op op : Op.values()) System.out.print(op + "=" + op.apply(7, 2) + " ");
        System.out.println();
        System.out.println(Planet.EARTH.getClass() == Planet.class);   // hằng số có thân là lớp con ẩn danh
        try {
            Planet.valueOf("earth");
        } catch (IllegalArgumentException e) {
            System.out.println("IllegalArgumentException: valueOf phân biệt hoa thường");
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
start
init MERCURY
init EARTH
init MARS
EARTH 1 98.0 home -
3 true
ADD=9 SUB=5
false
IllegalArgumentException: valueOf phân biệt hoa thường
```
<!-- /EX -->

### 15. Quy tắc override (lỗi biên dịch)

<!-- EX:Ex15_OverrideRules -->
`examples/ch03/Ex15_OverrideRules.java`

```java
// objective: 3.5
// expect: compile-error
// Quy tắc override: không giảm quyền truy cập, không ném checked exception rộng hơn,
// kiểu trả về phải "covariant".
import java.io.IOException;

class Base {
    public void a() { }
    void b() throws IOException { }
    Number c() { return 1; }
    final void d() { }
}

class Sub extends Base {
    void a() { }                         // lỗi: public → package-private (yếu hơn)
    void b() throws Exception { }        // lỗi: Exception rộng hơn IOException
    Integer c() { return 2; }            // OK: Integer là lớp con của Number (covariant)
    void d() { }                         // lỗi: không override được method final
}

public class Ex15_OverrideRules {
    public static void main(String[] args) { }
}
```

Output thật của `javac` (JDK 21.0.10) — cố ý không biên dịch được:

```text
Ex15_OverrideRules.java:15: error: a() in Sub cannot override a() in Base
    void a() { }                         // lỗi: public → package-private (yếu hơn)
         ^
  attempting to assign weaker access privileges; was public
Ex15_OverrideRules.java:16: error: b() in Sub cannot override b() in Base
    void b() throws Exception { }        // lỗi: Exception rộng hơn IOException
         ^
  overridden method does not throw Exception
Ex15_OverrideRules.java:18: error: d() in Sub cannot override d() in Base
    void d() { }                         // lỗi: không override được method final
         ^
  overridden method is final
3 errors
```
<!-- /EX -->

## Đi sâu

### 3.1 Object, nested class, GC

| Loại | Khai báo | Tạo object | Truy cập lớp ngoài |
|---|---|---|---|
| Static nested | `static class N {}` trong lớp | `new Outer.N()` | Chỉ thành viên static |
| Inner (member) | `class I {}` trong lớp | `outer.new I()` | Mọi thành viên, kể cả private; `Outer.this.x` |
| Local | `class L {}` trong method | `new L()` trong method đó | Biến cục bộ phải **effectively final** |
| Anonymous | `new Type() { ... }` | ngay tại chỗ | Như local class |

- Một object **đủ điều kiện GC** khi không còn tham chiếu nào **có thể tới được** (reachable) từ code đang chạy.
  Hai object trỏ nhau nhưng không ai trỏ tới cả hai cũng đủ điều kiện (GC không đếm tham chiếu).
- `System.gc()` chỉ là gợi ý. Không bao giờ chắc chắn object bị dọn lúc nào. `finalize()` đã deprecated.

### 3.2 Class, record, khởi tạo

Thứ tự khi chạy `new Child()` lần đầu:

1. Nạp lớp: static field + static block của **cha**, rồi của **con** (theo thứ tự xuất hiện). Chỉ một lần.
2. Constructor con gọi `super(...)` (ngầm nếu không viết) → lên tới lớp cha.
3. Ở mỗi lớp (từ cha xuống con): field initializer + instance block (theo thứ tự xuất hiện) → thân constructor.

Quy tắc constructor:

- Không viết constructor nào → compiler thêm **default constructor** không tham số. Viết một constructor bất kỳ →
  không còn default constructor.
- Dòng đầu của constructor là `this(...)` **hoặc** `super(...)` (không cả hai). Nếu lớp cha không có constructor
  không tham số, lớp con phải gọi `super(args)` rõ ràng.
- Field `final` phải được gán đúng một lần: tại chỗ khai báo, trong instance block, hoặc trong **mọi** constructor.
  `static final` phải gán tại chỗ hoặc trong static block.

Record:

- Component → field `private final` + accessor `public` cùng tên (`x()`, không phải `getX()`).
- Không có field instance khác; được có field/method **static**, method instance, nested type, implements interface.
- Record ngầm `final`, ngầm `extends java.lang.Record` → không `extends` được lớp khác.
- **Compact constructor** `Point { ... }`: không có danh sách tham số, dùng để kiểm tra/chuẩn hoá; gán lại **tham số**
  (`x = 0;`), **không** được viết `this.x = ...`.
- Canonical/compact constructor phải có quyền truy cập **ít nhất bằng** record: `public record R(...)` thì
  constructor phải là `public`.
- Constructor khác (không canonical) phải gọi `this(...)` ở dòng đầu.

### 3.3 Overloading

Compiler chọn method theo 3 giai đoạn, dừng ở giai đoạn đầu tiên tìm được ứng viên:

1. Khớp đúng kiểu hoặc **nới rộng** (widening): `int → long → float → double`.
2. Cho phép **boxing/unboxing**.
3. Cho phép **varargs**.

Trong một giai đoạn, nếu nhiều ứng viên thì chọn cái **cụ thể nhất** (most specific); không có → *ambiguous*.
Không có "nới rộng rồi boxing" (`int` → `Long` là không thể) nhưng có "boxing rồi nới rộng tham chiếu"
(`int` → `Integer` → `Object`). Overloading chỉ phụ thuộc **danh sách tham số**; kiểu trả về khác nhau không đủ.

### 3.4 Scope, encapsulation, immutable, `var`

- Phạm vi: field (cả lớp), tham số (cả method), biến cục bộ (từ chỗ khai báo tới hết khối `{}`).
  Biến cục bộ không được trùng tên với biến cục bộ khác còn trong phạm vi, nhưng **được** che field.
- Encapsulation: field `private`, truy cập qua method.
- Lớp bất biến: lớp `final` (hoặc constructor private), field `private final`, không có setter,
  copy dữ liệu mutable khi nhận vào và khi trả ra.
- `var`: chỉ cho **biến cục bộ** có initializer (kể cả trong `for`, for-each, try-with-resources).
  Không dùng cho field, tham số method, kiểu trả về. Không `var x = null;`, không `var a = 1, b = 2;`,
  không `var arr = {1, 2};`, không `var f = () -> 1;`. `var` không phải keyword: đặt tên biến `var` được.

### 3.5 Kế thừa, override, sealed, casting

Quy tắc **override** (method instance cùng tên, cùng danh sách tham số):

1. Quyền truy cập **không hẹp hơn** (public > protected > package-private > private).
2. Kiểu trả về giống hoặc là **kiểu con** (covariant) — với primitive thì phải giống hệt.
3. Không ném checked exception **mới hoặc rộng hơn** (unchecked thì tuỳ ý).
4. Không override được method `final`, `static` (static cùng chữ ký = hiding), hay `private` (không được kế thừa).

`@Override` giúp compiler bắt lỗi (ví dụ viết nhầm `equals(User o)` — là overload, không phải override).

Hợp đồng `equals`/`hashCode`: hai object `equals` thì phải cùng `hashCode`. Override `equals` mà không override
`hashCode` → `HashSet`/`HashMap` hoạt động sai.

Sealed:

- `sealed class A permits B, C` — chỉ B, C được kế thừa trực tiếp. Lớp con phải là `final`, `sealed` hoặc
  `non-sealed`. Record và enum ngầm `final`.
- Lớp con phải cùng module (hoặc cùng package nếu không dùng module). Nếu tất cả ở cùng file, có thể bỏ `permits`.

Ép kiểu tham chiếu:

- Upcast (con → cha): tự động. Downcast: cần cast; sai kiểu thật → `ClassCastException` lúc chạy.
- Compiler **báo lỗi** khi hai lớp chắc chắn không liên quan (ví dụ `(String) someInteger`). Cast sang interface
  thường được cho phép, trừ khi lớp nguồn là `final` và không implements interface đó.
- `x instanceof T` với `x == null` → `false`. `instanceof` giữa hai lớp không liên quan → lỗi biên dịch.

### 3.6 Interface

| Thành viên | Modifier ngầm | Ghi chú |
|---|---|---|
| Field | `public static final` | Phải gán giá trị |
| Method không thân | `public abstract` | |
| `default` method | `public` | Có thân; lớp implements có thể override |
| `static` method | `public` (hoặc `private static`) | Gọi qua tên interface; **không** kế thừa sang lớp implements |
| `private` method | — | Có thân; dùng chung giữa các default/static method |

- Hai interface cùng default method → lớp implements **phải** override; gọi bản cụ thể bằng `X.super.m()`.
- Lớp thắng interface: method của lớp cha (kể cả abstract) được ưu tiên hơn default method.
- Functional interface: đúng một method abstract (không tính default/static/private và method public của `Object`).
  `@FunctionalInterface` chỉ là kiểm tra thêm, không bắt buộc.

### 3.7 Enum

- Constructor ngầm `private` (viết `public` là lỗi). Hằng số phải đứng **đầu** thân enum; nếu có thêm thành viên,
  danh sách hằng số kết thúc bằng `;`.
- `values()`, `valueOf(String)` (phân biệt hoa thường, sai → `IllegalArgumentException`), `name()`, `ordinal()`,
  `compareTo()` (theo ordinal). Enum so sánh được bằng `==`.
- Enum có thể có method abstract, khi đó mỗi hằng số phải có thân `{ }` cài đặt nó.
- Enum implements interface được; không `extends` được; không `new` được.

## Lỗi và bẫy thường gặp (Exam traps)

1. Field/static method theo kiểu **biến**; method instance theo kiểu **object**.
2. Method được gọi từ constructor lớp cha nhưng override ở lớp con → thấy field của con còn giá trị mặc định.
3. `equals(MyType o)` là overload → collection không dùng nó.
4. Instance initializer không chạy lại khi constructor gọi `this(...)`.
5. Viết constructor có tham số → mất default constructor → `new X()` lỗi, và lớp con `super()` ngầm cũng lỗi.
6. Record: không field instance; compact constructor không gán `this.x`; canonical constructor không được hẹp quyền hơn record.
7. `m(1, 2)` với `m(Integer, long)` và `m(long, Integer)` → ambiguous.
8. `var` trong field hoặc tham số → lỗi; `var x = null;` → lỗi.
9. Lớp con của sealed class quên `final`/`sealed`/`non-sealed` → lỗi.
10. `static` method của interface không gọi được qua object hay lớp implements.
11. Hai default method trùng tên mà không override → lỗi.
12. Enum constructor `public` → lỗi; `valueOf("earth")` với hằng `EARTH` → exception.
13. `new Outer.Inner()` từ static context khi `Inner` không static → lỗi; cần `new Outer().new Inner()`.
14. Local/anonymous class dùng biến cục bộ không effectively final → lỗi.

## Góc nhìn từ TypeScript

| TypeScript | Java | Ghi chú |
|---|---|---|
| Structural typing: cùng "hình dạng" là tương thích | **Nominal typing**: phải `extends`/`implements` rõ ràng | Hai lớp giống hệt nhau vẫn không gán cho nhau được |
| `class A { constructor(public x: number) {} }` | `record A(int x) {}` | Record gần với "data class" |
| `readonly` field | `final` field | `final` chỉ khoá tham chiếu, giống `readonly` |
| Union type `Circle \| Square` | `sealed interface Shape permits Circle, Square` | Kiểm tra đầy đủ bằng switch |
| Method overloading bằng nhiều chữ ký + một cài đặt | Nhiều method thật sự khác nhau | Java chọn lúc biên dịch theo kiểu tham số |
| Interface chỉ tồn tại lúc biên dịch | Interface là kiểu thật lúc chạy, có `default`/`static`/`private` method | `instanceof` interface được |
| `enum` là số/chuỗi | `enum` là class: field, constructor, method | Mạnh hơn nhiều |
| Mọi property/method đều "virtual" | Field **không** đa hình; static method không đa hình | Nguồn gốc của nhiều câu bẫy |

## Tóm tắt

- Tham chiếu vs object; GC khi không còn tham chiếu reachable; `System.gc()` chỉ là gợi ý.
- Khởi tạo: static (cha → con, một lần) → mỗi object: cha (field/block → constructor) → con.
- Overloading: exact/widening → boxing → varargs; không nới rộng-rồi-boxing.
- Override: không hẹp quyền, trả về covariant, không thêm checked exception rộng hơn.
- Record: field `private final`, accessor `x()`, compact constructor gán tham số.
- Sealed: `permits` + lớp con `final`/`sealed`/`non-sealed`; switch đầy đủ không cần `default`.
- Interface: `default`/`static`/`private` method; xung đột default → override + `X.super.m()`.
- Enum: constructor private, `values()`, `valueOf()`, `ordinal()`, thân riêng cho từng hằng.

## Bài tập (có lời giải)

Mọi đáp án đã được `tools/book.py` biên dịch và chạy để xác nhận (code: `examples/questions/ch03/`).
Với câu hỏi "lỗi biên dịch ở dòng nào", script còn kiểm tra **từng dòng** riêng lẻ: sửa các dòng còn lại thì dòng
đó vẫn lỗi, và sửa tất cả thì code biên dịch được.

### Câu hỏi

<!-- QUESTIONS:ch03 -->
#### Câu 03-01 · Vừa · objective 3.1

Khi chương trình chạy tới dòng `// line X`, có bao nhiêu object đủ điều kiện bị thu gom rác (eligible for garbage collection)?

```java
public class Gc {
    public static void main(String[] args) {
        Object a = new Object();   // obj1
        Object b = new Object();   // obj2
        Object c = new Object();   // obj3
        a = b;
        c = a;
        b = null;
        // line X
    }
}
```

- **A.** `0`
- **B.** `1`
- **C.** `2`
- **D.** `3`

#### Câu 03-02 · Vừa · objective 3.1

Chèn dòng nào vào chỗ `// INSERT CODE HERE` thì chương trình biên dịch được? **(Chọn 2 đáp án.)**

```java
public class Outer {
    class Inner { }
    static class Nested { }

    public static void main(String[] args) {
        // INSERT CODE HERE
    }
}
```

- **A.** `Inner i = new Inner();`
- **B.** `Outer.Inner i = new Outer().new Inner();`
- **C.** `Nested n = new Outer.Nested();`
- **D.** `Outer.Nested n = new Outer().new Nested();`
- **E.** `Inner i = Outer.new Inner();`

#### Câu 03-03 · Vừa · objective 3.2

Chương trình sau in ra gì?

```java
public class Init {
    static String log = "";
    static { log += "S"; }
    { log += "I"; }
    Init() { log += "C"; }
    Init(int x) { this(); log += "X"; }

    public static void main(String[] args) {
        new Init(1);
        new Init();
        System.out.println(log);
    }
}
```

- **A.** `SICXIC`
- **B.** `SIICXIC`
- **C.** `SICXSIC`
- **D.** `SIXCIC`

#### Câu 03-04 · Khó · objective 3.2, 3.5

Chương trình sau in ra gì?

```java
class A {
    A() { print(); }
    void print() { System.out.print("A "); }
}

class B extends A {
    int x = 5;
    B() { print(); }
    @Override void print() { System.out.print("B" + x + " "); }
}

public class Ctor {
    public static void main(String[] args) {
        new B();
    }
}
```

- **A.** `A B5`
- **B.** `B0 B5`
- **C.** `B5 B5`
- **D.** `A B0`

#### Câu 03-05 · Vừa · objective 3.2, 3.5

Những dòng nào gây lỗi biên dịch?

```java
record Point(int x, int y) {
    static int count;                       // L1
    int z;                                  // L2
    Point {
        if (x < 0) x = 0;                   // L3
    }
    public int x() { return x; }            // L4
    void reset() { this.y = 0; }            // L5

    public static void main(String[] args) { }
}
```

- **A.** Chỉ L2
- **B.** L2 và L5
- **C.** L3 và L5
- **D.** L2, L3 và L5
- **E.** L4 và L5

#### Câu 03-06 · Vừa · objective 3.3

Chương trình sau in ra gì?

```java
public class Over {
    static String f(Object o)  { return "O"; }
    static String f(long l)    { return "L"; }
    static String f(Integer i) { return "I"; }
    static String f(int... is) { return "V"; }

    public static void main(String[] args) {
        short s = 1;
        Integer boxed = 2;
        System.out.println(f(s) + f(boxed) + f(3L) + f() + f('c') + f(4.0));
    }
}
```

- **A.** `OIVLLO`
- **B.** `LILVIO`
- **C.** `IILVLO`
- **D.** `LILVLO`

#### Câu 03-07 · Khó · objective 3.3

Dòng nào gây lỗi biên dịch?

```java
public class Amb {
    static void m(Integer a, long b) { }
    static void m(long a, Integer b) { }

    public static void main(String[] args) {
        m(1, 2);      // L1
        m(1L, 2);     // L2
        m(1, 2L);     // L3
    }
}
```

- **A.** L1
- **B.** L2
- **C.** L3
- **D.** L1 và L2
- **E.** Không dòng nào

#### Câu 03-08 · Vừa · objective 3.4

Chèn dòng nào vào chỗ `// INSERT CODE HERE` thì chương trình biên dịch được? **(Chọn 2 đáp án.)**

```java
public class Infer {
    public static void main(String[] args) {
        // INSERT CODE HERE
    }
}
```

- **A.** `var a = 1, b = 2;`
- **B.** `var list = new java.util.ArrayList<>();`
- **C.** `var x; x = 5;`
- **D.** `var n = null;`
- **E.** `var arr = new int[]{1, 2};`
- **F.** `var f = () -> 1;`

#### Câu 03-09 · Dễ · objective 3.4

Chương trình sau in ra gì?

```java
public class Shadow {
    static int x = 1;
    int y = 2;

    void run(int x) {
        int y = x + this.y;
        x = 10;
        System.out.println(x + " " + y + " " + Shadow.x + " " + this.y);
    }

    public static void main(String[] args) {
        new Shadow().run(5);
    }
}
```

- **A.** `10 7 10 2`
- **B.** `5 7 1 7`
- **C.** `10 12 1 2`
- **D.** `10 7 1 2`

#### Câu 03-10 · Khó · objective 3.4

Hai phát biểu nào đúng? **(Chọn 2 đáp án.)**

- **A.** Nội dung của một component kiểu `List` trong record vẫn có thể bị thay đổi qua accessor, nếu record không copy list.
- **B.** Khai báo `final StringBuilder sb` làm cho nội dung của `sb` không thể thay đổi.
- **C.** Một lớp có mọi field `private final` nhưng không phải lớp `final` vẫn có thể bị lớp con làm thay đổi hành vi quan sát được.
- **D.** `String.toUpperCase()` thay đổi chính object `String` gọi nó.
- **E.** `List.of(...)` trả về list cho phép thêm phần tử.

#### Câu 03-11 · Vừa · objective 3.5

Chương trình sau in ra gì?

```java
class P {
    String n = "P";
    String get() { return n; }
    static String s() { return "sP"; }
}

class C extends P {
    String n = "C";
    @Override String get() { return n; }
    static String s() { return "sC"; }
}

public class Poly {
    public static void main(String[] args) {
        P p = new C();
        System.out.println(p.n + " " + p.get() + " " + p.s() + " " + ((C) p).n);
    }
}
```

- **A.** `C C sC C`
- **B.** `P P sP C`
- **C.** `P C sC C`
- **D.** `P C sP C`

#### Câu 03-12 · Khó · objective 3.5

Dòng nào gây lỗi biên dịch?

```java
public class Seal {
    sealed interface Shape permits Circle, Square { }
    record Circle(double r) implements Shape { }              // L1
    final class Square implements Shape { }                   // L2
    class Triangle implements Shape { }                       // L3

    static String name(Shape s) {
        return switch (s) {
            case Circle c -> "circle";
            case Square q -> "square";
        };                                                    // L4
    }

    public static void main(String[] args) { }
}
```

- **A.** L1
- **B.** L2
- **C.** L3
- **D.** L4
- **E.** L3 và L4

#### Câu 03-13 · Vừa · objective 3.5

Kết quả của chương trình là gì?

```java
public class Cast {
    static class Animal { }
    static class Cat extends Animal { }
    static class Dog extends Animal { }

    public static void main(String[] args) {
        Animal a = new Cat();
        Object o = a;
        System.out.print((o instanceof Animal) + " ");
        Dog d = (Dog) a;
        System.out.println("done");
    }
}
```

- **A.** In ra `true done`
- **B.** Không biên dịch được ở dòng `(Dog) a`
- **C.** In ra `false` rồi ném `ClassCastException`
- **D.** In ra `true` rồi ném `ClassCastException`

#### Câu 03-14 · Vừa · objective 3.5

Chương trình sau in ra gì?

```java
import java.util.*;

public class Eq {
    static class Id {
        final int v;
        Id(int v) { this.v = v; }
        public boolean equals(Id o) { return o != null && o.v == v; }
        @Override public int hashCode() { return v; }
    }

    public static void main(String[] args) {
        Id a = new Id(1), b = new Id(1);
        Object ob = b;
        List<Id> list = new ArrayList<>(List.of(a));
        System.out.println(a.equals(b) + " " + a.equals(ob) + " " + list.contains(b));
    }
}
```

- **A.** `true true true`
- **B.** `true false true`
- **C.** `true false false`
- **D.** `false false false`

#### Câu 03-15 · Vừa · objective 3.6

Chương trình sau in ra gì?

```java
public class Iface {
    interface A { default String hi() { return "A"; } }
    interface B extends A { default String hi() { return "B" + A.super.hi(); } }
    interface C extends A { }
    static class X implements B, C { }

    public static void main(String[] args) {
        System.out.println(new X().hi());
    }
}
```

- **A.** `A`
- **B.** `BA`
- **C.** `Không biên dịch được: X phải override hi()`
- **D.** `B`

#### Câu 03-16 · Khó · objective 3.6

Khai báo nào, chèn vào chỗ `// INSERT CODE HERE`, làm cho chương trình biên dịch và in ra `3`? **(Chọn 3 đáp án.)**

```java
public class Func {
    // INSERT CODE HERE

    public static void main(String[] args) {
        F f = s -> s.length();
        System.out.println(f.apply("abc"));
    }
}
```

- **A.** `interface F { int apply(String s); }`
- **B.** `interface F { int apply(String s); default int twice(String s) { return 2 * apply(s); } }`
- **C.** `interface F { int apply(String s); int other(); }`
- **D.** `interface F { int apply(String s); boolean equals(Object o); }`
- **E.** `abstract class F { abstract int apply(String s); }`

#### Câu 03-17 · Vừa · objective 3.6

Dòng nào gây lỗi biên dịch?

```java
public class Members {
    interface Shape {
        int SIDES = 0;                         // L1
        private void log() { }                 // L2
        protected double area();               // L3
        static Shape unit() { return null; }   // L4
        default void print() { log(); }        // L5
    }

    public static void main(String[] args) { }
}
```

- **A.** L1
- **B.** L2
- **C.** L3
- **D.** L4
- **E.** L2 và L3

#### Câu 03-18 · Dễ · objective 3.7

Chương trình sau in ra gì?

```java
public class Sizes {
    enum Size {
        S(1), M(2), L(3);
        private final int n;
        Size(int n) { this.n = n; }
        Size next() { return values()[(ordinal() + 1) % values().length]; }
    }

    public static void main(String[] args) {
        Size s = Size.valueOf("M");
        System.out.println(s.next() + " " + s.next().next().n + " "
                + s.compareTo(Size.L) + " " + Size.L.name().toLowerCase());
    }
}
```

- **A.** `L 1 -1 l`
- **B.** `L 3 -1 l`
- **C.** `L 1 1 L`
- **D.** `S 1 -1 l`

#### Câu 03-19 · Khó · objective 3.7

Hai phát biểu nào đúng về enum? **(Chọn 2 đáp án.)**

- **A.** Constructor của enum có thể khai báo `public`.
- **B.** Enum có thể implements interface.
- **C.** Có thể tạo thêm hằng số enum lúc chạy bằng `new`.
- **D.** Mỗi hằng số enum có thể có thân lớp riêng để override method.
- **E.** Enum có thể `extends` một lớp khác.

#### Câu 03-20 · Vừa · objective 3.5

Những dòng nào gây lỗi biên dịch?

```java
public class Abs {
    abstract static class Shape {
        abstract double area();                    // L1
        abstract void draw() { }                   // L2
        Shape() { }                                // L3
    }

    static class Sq extends Shape {                // L4
        double area() { return 1; }
    }

    public static void main(String[] args) {
        Shape s = new Sq();
    }
}
```

- **A.** Chỉ L2
- **B.** L2 và L4
- **C.** L3 và L4
- **D.** L1 và L2
- **E.** Chỉ L4
<!-- /QUESTIONS -->

### Lời giải

<!-- ANSWERS:ch03 -->
#### Câu 03-01 — Đáp án: **C** (Vừa · objective 3.1)

- **Vì sao đúng:** `a = b` làm obj1 mất tham chiếu cuối cùng. `c = a` làm obj3 mất tham chiếu. obj2 vẫn được `a` và `c` trỏ tới (`b = null` chỉ xoá một trong ba tham chiếu). Vậy obj1 và obj3 đủ điều kiện GC. Script kiểm chứng bằng `WeakReference` + `System.gc()` và đếm được 2 object bị thu hồi.
- **A sai:** obj1 và obj3 không còn biến nào trỏ tới sau hai phép gán.
- **B sai:** Cả obj1 (sau `a = b`) và obj3 (sau `c = a`) đều mất tham chiếu.
- **D sai:** obj2 vẫn được `a` và `c` trỏ tới.
- *Kiểm chứng:* `examples/questions/ch03/Q03_01/` — output confirmed (check_code: bản code có thêm lệnh đo, xem thư mục) (`python3 tools/book.py questions ch03`).

#### Câu 03-02 — Đáp án: **B, C** (Vừa · objective 3.1)

- **Vì sao đúng:** Inner class (không `static`) cần một object của lớp ngoài: `new Outer().new Inner()`. Static nested class tạo như lớp bình thường: `new Outer.Nested()` (hoặc `new Nested()` bên trong `Outer`).
- **A sai:** `main` là static, không có `this` của `Outer`, nên không tạo trực tiếp `Inner` được.
- **D sai:** Không dùng cú pháp `outer.new` với static nested class → lỗi "qualified new of static class".
- **E sai:** Cần một **object** trước `.new`, không phải tên lớp.
- *Kiểm chứng:* `examples/questions/ch03/Q03_02/` — variants: BC satisfy compiles (`python3 tools/book.py questions ch03`).

#### Câu 03-03 — Đáp án: **A** (Vừa · objective 3.2)

- **Vì sao đúng:** Khối static chạy **một lần** khi lớp được nạp (S). `new Init(1)` gọi `this()`; instance initializer chỉ chạy trong constructor gọi `super()` (ở đây là `Init()`), nên chạy đúng một lần: I, C, rồi X. `new Init()` thêm I, C.
- **B sai:** Instance initializer không chạy hai lần khi có `this()`: nó chỉ chạy trong constructor gọi `super()`.
- **C sai:** Khối static chỉ chạy một lần cho cả chương trình.
- **D sai:** Instance initializer chạy **trước** thân constructor `Init()`, và `X` được thêm sau cùng.
- *Kiểm chứng:* `examples/questions/ch03/Q03_03/` — output confirmed (`python3 tools/book.py questions ch03`).

#### Câu 03-04 — Đáp án: **B** (Khó · objective 3.2, 3.5)

- **Vì sao đúng:** Constructor `A()` chạy trước (do `super()` ngầm). Lời gọi `print()` là đa hình nên gọi bản override của `B`. Lúc đó field `x` của `B` chưa được khởi tạo (initializer của `B` chạy sau `super()`), nên `x = 0`. Sau đó `x = 5` và `B()` in `B5`.
- **A sai:** Method instance được chọn theo kiểu object thật (`B`), kể cả khi gọi từ constructor của lớp cha.
- **C sai:** Khi constructor cha chạy, field của lớp con vẫn mang giá trị mặc định 0.
- **D sai:** Như A — bản override của `B` được gọi.
- *Kiểm chứng:* `examples/questions/ch03/Q03_04/` — output confirmed (`python3 tools/book.py questions ch03`).

#### Câu 03-05 — Đáp án: **B** (Vừa · objective 3.2, 3.5)

- **Vì sao đúng:** Record không được khai báo field **instance** ngoài các component (L2). Field của record là `final`, không gán lại được trong method (L5). L3 hợp lệ: trong compact constructor ta gán lại **tham số** `x`, trước khi field được gán tự động. L4 hợp lệ: accessor viết tay phải `public`, đúng tên và kiểu.
- **A sai:** L5 cũng lỗi: `y` là field `final`.
- **C sai:** L3 hợp lệ — gán tham số trong compact constructor là cách chuẩn hoá dữ liệu.
- **D sai:** L3 hợp lệ (xem C).
- **E sai:** L4 là accessor hợp lệ; L2 thì lỗi.
- *Kiểm chứng:* `examples/questions/ch03/Q03_05/` — compile error confirmed at ['L2', 'L5'] (`python3 tools/book.py questions ch03`).

#### Câu 03-06 — Đáp án: **D** (Vừa · objective 3.3)

- **Vì sao đúng:** Thứ tự ưu tiên: khớp đúng/nới rộng (widening) → boxing → varargs. `short` và `char` nới rộng thành `long` (L). `Integer` khớp đúng (I). `3L` → L. Không tham số → chỉ varargs (V). `4.0` là `double`: không nới rộng sang `long` được, nên boxing thành `Double` rồi thành `Object` (O).
- **A sai:** `short` nới rộng thành `long` ở bước đầu tiên, không cần boxing thành `Object`.
- **B sai:** `char` nới rộng sang `long` (widening) được ưu tiên hơn boxing sang `Integer` — và `char` cũng không boxing thành `Integer`.
- **C sai:** `short` không boxing thành `Integer`; widening sang `long` thắng.
- *Kiểm chứng:* `examples/questions/ch03/Q03_06/` — output confirmed (`python3 tools/book.py questions ch03`).

#### Câu 03-07 — Đáp án: **A** (Khó · objective 3.3)

- **Vì sao đúng:** L1: không method nào khớp mà không cần boxing; ở bước có boxing thì **cả hai** đều khớp và không cái nào cụ thể hơn → "reference to m is ambiguous". L2: `1L` không boxing thành `Integer` được, nên chỉ `m(long, Integer)` khớp. L3: tương tự, chỉ `m(Integer, long)` khớp.
- **B sai:** `1L` là `long`, chỉ khớp tham số `long a` → chỉ một ứng viên, không mơ hồ.
- **C sai:** `2L` chỉ khớp tham số `long b` → chỉ `m(Integer, long)`.
- **D sai:** L2 có đúng một ứng viên.
- **E sai:** L1 mơ hồ (ambiguous).
- *Kiểm chứng:* `examples/questions/ch03/Q03_07/` — compile error confirmed at ['L1'] (`python3 tools/book.py questions ch03`).

#### Câu 03-08 — Đáp án: **B, E** (Vừa · objective 3.4)

- **Vì sao đúng:** `var` cần một initializer để suy ra kiểu. B suy ra `ArrayList<Object>`. E suy ra `int[]`.
- **A sai:** `var` không dùng để khai báo nhiều biến trên một dòng.
- **C sai:** `var` phải được khởi tạo ngay khi khai báo.
- **D sai:** Không suy ra được kiểu từ `null`.
- **F sai:** Lambda cần kiểu đích (target type) rõ ràng; `var` không cung cấp được.
- *Kiểm chứng:* `examples/questions/ch03/Q03_08/` — variants: BE satisfy compiles (`python3 tools/book.py questions ch03`).

#### Câu 03-09 — Đáp án: **D** (Dễ · objective 3.4)

- **Vì sao đúng:** Tham số `x` che field static `x`; biến cục bộ `y` che field `y`. `y = 5 + this.y = 7`. Gán `x = 10` chỉ đổi tham số. `Shadow.x` vẫn là 1 và `this.y` vẫn là 2.
- **A sai:** `x = 10` gán cho tham số, không phải field static `Shadow.x`.
- **B sai:** Tham số `x` đã bị gán 10 trước khi in; và `this.y` là field (2), không phải biến cục bộ.
- **C sai:** `y` được tính **trước** khi gán `x = 10`, nên `y = 5 + 2`.
- *Kiểm chứng:* `examples/questions/ch03/Q03_09/` — output confirmed (`python3 tools/book.py questions ch03`).

#### Câu 03-10 — Đáp án: **A, C** (Khó · objective 3.4)

- **Vì sao đúng:** A: record chỉ bất biến "nông" (shallow): field `items` là `final`, nhưng object list bên trong vẫn sửa được. C: lớp con có thể override getter và trả về giá trị khác, phá vỡ tính bất biến → lớp bất biến nên là `final`.
- **B sai:** `final` chỉ khoá **tham chiếu** (không gán `sb` sang object khác), không khoá nội dung object.
- **D sai:** `String` bất biến; `toUpperCase()` trả về chuỗi mới.
- **E sai:** `List.of` trả về list không sửa được (unmodifiable) → `UnsupportedOperationException`.
- *Kiểm chứng:* `examples/questions/ch03/Q03_10/` — each option proven true/false by a program (`python3 tools/book.py questions ch03`).

#### Câu 03-11 — Đáp án: **D** (Vừa · objective 3.5)

- **Vì sao đúng:** Field và method static được chọn theo **kiểu tham chiếu** lúc biên dịch (`P`): `p.n` = "P", `p.s()` = "sP". Method instance được override nên chọn theo **kiểu object** lúc chạy (`C`): `p.get()` trả về field `n` của `C`. Sau khi cast sang `C`, `((C) p).n` = "C".
- **A sai:** Field không đa hình: `p.n` dùng kiểu tham chiếu `P`.
- **B sai:** `get()` được override trong `C` và trả về `n` của `C`.
- **C sai:** Method static không override được (chỉ bị che - hiding), chọn theo kiểu tham chiếu `P`.
- *Kiểm chứng:* `examples/questions/ch03/Q03_11/` — output confirmed (`python3 tools/book.py questions ch03`).

#### Câu 03-12 — Đáp án: **C** (Khó · objective 3.5)

- **Vì sao đúng:** `Shape` chỉ cho phép (`permits`) `Circle` và `Square`. `Triangle` không có trong danh sách nên không được implements `Shape`. L1: record ngầm là `final` → hợp lệ. L2: `final` → hợp lệ. L4: switch đã phủ đủ các lớp được permit nên đầy đủ.
- **A sai:** Record luôn ngầm `final`, nên là lớp con hợp lệ của sealed interface.
- **B sai:** Lớp con được permit phải là `final`, `sealed` hoặc `non-sealed` — `Square` là `final`.
- **D sai:** Switch trên sealed type phủ hết `Circle` và `Square` là đầy đủ, không cần `default`.
- **E sai:** L4 hợp lệ (xem D).
- *Kiểm chứng:* `examples/questions/ch03/Q03_12/` — compile error confirmed at ['L3'] (`python3 tools/book.py questions ch03`).

#### Câu 03-13 — Đáp án: **D** (Vừa · objective 3.5)

- **Vì sao đúng:** `o` trỏ tới một `Cat`, là `Animal` → in `true `. Cast `(Dog) a` biên dịch được vì `Dog` là lớp con của `Animal` (có thể đúng lúc chạy), nhưng object thật là `Cat` → `ClassCastException`.
- **A sai:** Object thật là `Cat`, không phải `Dog`, nên cast thất bại lúc chạy.
- **B sai:** Compiler chỉ cấm cast giữa hai lớp không liên quan; `Animal` → `Dog` là downcast hợp lệ về cú pháp.
- **C sai:** `Cat` là lớp con của `Animal`, nên `instanceof Animal` là `true`.
- *Kiểm chứng:* `examples/questions/ch03/Q03_13/` — output confirmed (`python3 tools/book.py questions ch03`).

#### Câu 03-14 — Đáp án: **C** (Vừa · objective 3.5)

- **Vì sao đúng:** `equals(Id)` là **overload**, không phải override `equals(Object)`. `a.equals(b)`: tham số kiểu `Id` → gọi bản overload → `true`. `a.equals(ob)`: tham số kiểu `Object` → gọi `Object.equals` (so sánh tham chiếu) → `false`. `list.contains` gọi `equals(Object)` → `false`.
- **A sai:** Chỉ lời gọi với tham số kiểu `Id` mới dùng bản overload.
- **B sai:** Collection luôn gọi `equals(Object)`, nên `contains` không thấy bản overload.
- **D sai:** `a.equals(b)` với `b` kiểu `Id` chọn bản overload `equals(Id)` → `true`.
- *Kiểm chứng:* `examples/questions/ch03/Q03_14/` — output confirmed (`python3 tools/book.py questions ch03`).

#### Câu 03-15 — Đáp án: **B** (Vừa · objective 3.6)

- **Vì sao đúng:** `C` chỉ kế thừa `hi()` của `A`, còn `B` override nó. Bản của `B` cụ thể hơn (B là interface con của A), nên không có xung đột và `X` dùng bản của `B`. `A.super.hi()` hợp lệ vì `B` kế thừa trực tiếp `A`.
- **A sai:** `B.hi()` override `A.hi()` và được chọn vì cụ thể hơn.
- **C sai:** Chỉ bắt buộc override khi hai default **không liên quan** cùng tên; ở đây `B` đã override `A`.
- **D sai:** `B.hi()` gọi thêm `A.super.hi()` nên kết quả là `BA`.
- *Kiểm chứng:* `examples/questions/ch03/Q03_15/` — output confirmed (`python3 tools/book.py questions ch03`).

#### Câu 03-16 — Đáp án: **A, B, D** (Khó · objective 3.6)

- **Vì sao đúng:** Lambda cần một **functional interface**: interface có đúng một method abstract. Method `default`/`static` không tính (B). Method trùng với method public của `Object` như `equals(Object)` cũng không tính (D).
- **C sai:** Có hai method abstract (`apply`, `other`) → không phải functional interface.
- **E sai:** Lambda chỉ dùng được với interface, không dùng với abstract class.
- *Kiểm chứng:* `examples/questions/ch03/Q03_16/` — variants: ABD satisfy output (`python3 tools/book.py questions ch03`).

#### Câu 03-17 — Đáp án: **C** (Vừa · objective 3.6)

- **Vì sao đúng:** Thành viên của interface chỉ có thể là `public` hoặc `private` (method); `protected` không được phép. L1: field ngầm `public static final`. L2: method `private` có thân (Java 9+). L4: method `static`. L5: `default` gọi method `private` → hợp lệ.
- **A sai:** Field trong interface là hằng số `public static final` ngầm định — hợp lệ.
- **B sai:** Interface được có method `private` (có thân) từ Java 9.
- **D sai:** Interface được có method `static` (có thân) từ Java 8.
- **E sai:** L2 hợp lệ (xem B).
- *Kiểm chứng:* `examples/questions/ch03/Q03_17/` — compile error confirmed at ['L3'] (`python3 tools/book.py questions ch03`).

#### Câu 03-18 — Đáp án: **A** (Dễ · objective 3.7)

- **Vì sao đúng:** `M.next()` là `L`. `L.next()` quay vòng về `S`, có `n = 1`. `compareTo` so sánh `ordinal`: 1 - 2 = -1. `name()` trả về `"L"`, `toLowerCase()` → `"l"`.
- **B sai:** `next()` gọi hai lần từ `M`: M → L → S, và `S.n` là 1.
- **C sai:** `M` đứng trước `L` nên `compareTo` âm; `toLowerCase()` cho `l`.
- **D sai:** `ordinal()` của `M` là 1, nên `next()` là `values()[2]` = `L`.
- *Kiểm chứng:* `examples/questions/ch03/Q03_18/` — output confirmed (`python3 tools/book.py questions ch03`).

#### Câu 03-19 — Đáp án: **B, D** (Khó · objective 3.7)

- **Vì sao đúng:** B: enum là lớp đặc biệt, có thể implements một hay nhiều interface. D: hằng số enum có thể có thân `{ ... }` riêng (thực chất là lớp con ẩn danh) để override method.
- **A sai:** Constructor enum ngầm `private`; khai báo `public` hoặc `protected` là lỗi biên dịch.
- **C sai:** Không thể `new` một enum; tập hằng số cố định lúc biên dịch.
- **E sai:** Enum đã ngầm `extends java.lang.Enum`, nên không `extends` được lớp khác.
- *Kiểm chứng:* `examples/questions/ch03/Q03_19/` — each option proven true/false by a program (`python3 tools/book.py questions ch03`).

#### Câu 03-20 — Đáp án: **B** (Vừa · objective 3.5)

- **Vì sao đúng:** L2: method `abstract` không được có thân `{ }`. L4: `Sq` không phải abstract nên phải cài đặt **mọi** method abstract kế thừa, nhưng thiếu `draw()`. L1 hợp lệ; L3 hợp lệ vì lớp abstract vẫn có constructor (được gọi qua `super()` từ lớp con).
- **A sai:** `Sq` cũng lỗi vì không cài đặt `draw()`.
- **C sai:** Lớp abstract được phép có constructor.
- **D sai:** L1 là method abstract hợp lệ (không có thân).
- **E sai:** L2 cũng lỗi: method abstract không có thân.
- *Kiểm chứng:* `examples/questions/ch03/Q03_20/` — compile error confirmed at ['L2', 'L4'] (`python3 tools/book.py questions ch03`).
<!-- /ANSWERS -->

## Đọc thêm (link chính thức — bị chặn trong sandbox nên mình chưa mở được)

- JLS Chương 8 (Classes, gồm §8.10 Record Classes), Chương 9 (Interfaces), §8.9 Enum Classes:
  https://docs.oracle.com/javase/specs/jls/se21/html/jls-8.html
- JLS §15.12 Method Invocation (chọn overload): https://docs.oracle.com/javase/specs/jls/se21/html/jls-15.html

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:

- `Record.java` (Javadoc về hợp đồng equals/hashCode của record): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/lang/Record.java
- `Object.java` (hợp đồng `equals`/`hashCode`): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/lang/Object.java
- `Enum.java` (`valueOf`, `ordinal`, `compareTo`): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/lang/Enum.java
- `FunctionalInterface.java` (định nghĩa functional interface): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/lang/FunctionalInterface.java
