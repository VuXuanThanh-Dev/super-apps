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
