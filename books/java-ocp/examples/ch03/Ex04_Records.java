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
