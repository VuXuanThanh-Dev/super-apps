// objective: 4.1
// try-with-resources: đóng tài nguyên theo thứ tự NGƯỢC, trước khi catch/finally chạy.
public class Ex04_TryWithResources {
    record Res(String name) implements AutoCloseable {
        Res { System.out.println("open " + name); }
        @Override public void close() { System.out.println("close " + name); }
    }

    public static void main(String[] args) {
        try (Res a = new Res("A"); Res b = new Res("B")) {
            System.out.println("body");
            throw new IllegalStateException("boom");
        } catch (IllegalStateException e) {
            System.out.println("catch " + e.getMessage());
        } finally {
            System.out.println("finally");
        }

        Res c = new Res("C");                 // Java 9+: dùng biến effectively final có sẵn
        try (c) {
            System.out.println("using " + c.name());
        }
        // c = null;                          // nếu có dòng này, try (c) sẽ lỗi biên dịch
    }
}
